# 🧪 Testing: Estados de Órdenes con Payment Intent

## 📋 Pre-requisitos

✅ Backend Spring Boot ejecutándose en `http://localhost:8080`
✅ Flutter app ejecutándose (ya está corriendo)
✅ Cambios implementados en OrderService, OrderController, Order entity
✅ Base de datos actualizada con nuevos campos

---

## 🎯 Escenarios de Prueba

### Escenario 1: Crear Orden con Pago con Tarjeta ✅

**Objetivo**: Verificar que la orden se crea con estado `CONFIRMED` automáticamente

**Pasos**:
1. En la app Flutter, agrega productos al carrito
2. Ve a "Checkout"
3. Selecciona método de pago: **Tarjeta de crédito/débito**
4. Ingresa datos de tarjeta de prueba Stripe:
   ```
   Número: 4242 4242 4242 4242
   Fecha: 12/25
   CVV: 123
   ZIP: 12345
   ```
5. Completa el pago
6. Observa los logs en Debug Console

**Resultado esperado en logs**:
```
✅ Pago procesado exitosamente
   Payment Intent ID: pi_xxxxxxxxxxxxx
✅ Orden creada exitosamente: #6
   Payment Intent ID: pi_xxxxxxxxxxxxx
```

**Verificar en Backend** (logs de Spring Boot):
```
Orden creada: ID=6, Estado=CONFIRMED, Payment Intent=pi_xxxxxxxxxxxxx
```

**Verificar en Base de Datos**:
```sql
SELECT id, status, payment_method, payment_status, payment_intent_id, total_amount
FROM orders
WHERE id = 6;
```

**Resultado esperado**:
```
| id | status    | payment_method | payment_status | payment_intent_id     | total_amount |
|----|-----------|----------------|----------------|-----------------------|--------------|
| 6  | CONFIRMED | card           | completed      | pi_xxxxxxxxxxxxx      | 41.80        |
```

✅ **Estado inicial debe ser `CONFIRMED` (no `PENDING`)**

---

### Escenario 2: Crear Orden con Pago en Efectivo 💵

**Objetivo**: Verificar que la orden se crea con estado `PENDING`

**Pasos**:
1. Agrega productos al carrito
2. Ve a "Checkout"
3. Selecciona método de pago: **Efectivo en entrega**
4. Confirma la orden

**Resultado esperado en logs**:
```
✅ Orden creada exitosamente: #7
   Payment Intent ID: null
```

**Verificar en Base de Datos**:
```sql
SELECT id, status, payment_method, payment_status, payment_intent_id
FROM orders
WHERE id = 7;
```

**Resultado esperado**:
```
| id | status  | payment_method | payment_status | payment_intent_id |
|----|---------|----------------|----------------|-------------------|
| 7  | PENDING | cash           | pending        | null              |
```

✅ **Estado inicial debe ser `PENDING` para pagos en efectivo**

---

### Escenario 3: Actualizar Estado de Orden (Admin) 🔄

**Objetivo**: Probar que los endpoints de actualización funcionan

#### 3.1 - Cambiar a PREPARING

**Usar Postman o cURL**:
```bash
curl -X PUT "http://localhost:8080/api/orders/6/status?status=PREPARING" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

**Respuesta esperada**:
```json
{
  "success": true,
  "message": "Estado actualizado exitosamente",
  "data": {
    "id": 6,
    "status": "PREPARING",
    "updatedAt": "2025-11-11T23:55:00"
  }
}
```

#### 3.2 - Cambiar a READY

```bash
curl -X PUT "http://localhost:8080/api/orders/6/status?status=READY" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### 3.3 - Cambiar a ON_THE_WAY

```bash
curl -X PUT "http://localhost:8080/api/orders/6/status?status=ON_THE_WAY" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### Escenario 4: Marcar como Entregada ✅

**Objetivo**: Verificar que la orden aparece en "Entregados"

**Usar cURL**:
```bash
curl -X POST "http://localhost:8080/api/orders/6/deliver" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Respuesta esperada**:
```json
{
  "success": true,
  "message": "Orden marcada como entregada",
  "data": {
    "id": 6,
    "status": "DELIVERED",
    "paymentIntentId": "pi_xxxxxxxxxxxxx",
    "totalAmount": 41.80,
    "updatedAt": "2025-11-11T23:56:00"
  }
}
```

**Verificar en Flutter**:
1. Ve a "Mis Pedidos"
2. Pull to refresh (desliza hacia abajo)
3. Selecciona filtro **"Entregados"**
4. ✅ La orden #6 debe aparecer ahí

---

### Escenario 5: Cancelar Orden ❌

**Objetivo**: Verificar que la orden aparece en "Cancelados"

**Usar cURL**:
```bash
curl -X POST "http://localhost:8080/api/orders/7/cancel?reason=Cliente%20solicit%C3%B3%20cancelaci%C3%B3n" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Respuesta esperada**:
```json
{
  "success": true,
  "message": "Orden cancelada exitosamente",
  "data": {
    "id": 7,
    "status": "CANCELLED",
    "cancellationReason": "Cliente solicitó cancelación",
    "updatedAt": "2025-11-11T23:57:00"
  }
}
```

**Verificar en Flutter**:
1. Ve a "Mis Pedidos"
2. Pull to refresh
3. Selecciona filtro **"Cancelados"**
4. ✅ La orden #7 debe aparecer ahí

---

### Escenario 6: Intentar Cancelar Orden Entregada (Error) 🚫

**Objetivo**: Verificar que NO se puede cancelar una orden ya entregada

**Usar cURL**:
```bash
curl -X POST "http://localhost:8080/api/orders/6/cancel?reason=Ya%20no%20lo%20quiero" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Respuesta esperada**:
```json
{
  "success": false,
  "message": "No se puede cancelar una orden ya entregada"
}
```

✅ **Debe rechazar la cancelación**

---

## 📊 Verificación de Filtros en Flutter

### Después de completar todos los escenarios:

1. **"Todos"** - Debe mostrar:
   - Orden #6 (DELIVERED)
   - Orden #7 (CANCELLED)
   - Orden #5 (CONFIRMED)

2. **"En curso"** - Debe mostrar:
   - Orden #5 (CONFIRMED)
   - (Todas las que NO sean DELIVERED ni CANCELLED)

3. **"Entregados"** - Debe mostrar:
   - Orden #6 (DELIVERED)

4. **"Cancelados"** - Debe mostrar:
   - Orden #7 (CANCELLED)

---

## 🔍 Queries SQL Útiles para Debugging

### Ver todas las órdenes con sus estados:
```sql
SELECT 
    id,
    status,
    payment_method,
    payment_status,
    payment_intent_id,
    total_amount,
    created_at,
    updated_at
FROM orders
ORDER BY created_at DESC;
```

### Contar órdenes por estado:
```sql
SELECT 
    status,
    COUNT(*) as total,
    SUM(total_amount) as ventas_totales
FROM orders
GROUP BY status
ORDER BY total DESC;
```

### Ver órdenes con pago con tarjeta:
```sql
SELECT id, status, payment_method, payment_intent_id, total_amount
FROM orders
WHERE payment_intent_id IS NOT NULL
ORDER BY created_at DESC;
```

### Actualizar manualmente una orden (solo para testing):
```sql
-- Marcar orden #4 como entregada
UPDATE orders 
SET status = 'DELIVERED', updated_at = NOW() 
WHERE id = 4;

-- Marcar orden #2 como cancelada
UPDATE orders 
SET status = 'CANCELLED', 
    cancellation_reason = 'Testing',
    updated_at = NOW()
WHERE id = 2;
```

---

## 🛠️ Obtener JWT Token para Testing

### Opción 1: Desde los logs de Flutter
Cuando haces login, busca en los logs:
```
🔐 Token JWT: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Opción 2: Login con cURL
```bash
curl -X POST "http://localhost:8080/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario@test.com",
    "password": "password123"
  }'
```

**Respuesta**:
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": { ... }
  }
}
```

Copia el `token` y úsalo en los headers de las peticiones.

---

## ✅ Checklist Final de Testing

- [ ] **Escenario 1**: Orden con tarjeta → Estado CONFIRMED ✅
- [ ] **Escenario 2**: Orden efectivo → Estado PENDING 💵
- [ ] **Escenario 3**: Actualizar estado (PREPARING → READY → ON_THE_WAY) 🔄
- [ ] **Escenario 4**: Marcar como entregada → Aparece en "Entregados" ✅
- [ ] **Escenario 5**: Cancelar orden → Aparece en "Cancelados" ❌
- [ ] **Escenario 6**: No se puede cancelar orden entregada 🚫
- [ ] **Verificación**: Filtros en Flutter muestran órdenes correctamente 📱
- [ ] **Verificación**: Payment Intent ID se guarda en BD 💳
- [ ] **Verificación**: Logs muestran información correcta 📋

---

## 🚨 Errores Comunes y Soluciones

### Error: "Orden no encontrada"
- **Causa**: El ID de orden no existe
- **Solución**: Verifica que el ID existe en la base de datos

### Error: "401 Unauthorized"
- **Causa**: Token JWT expirado o inválido
- **Solución**: Genera un nuevo token con login

### Error: "Estado inválido"
- **Causa**: El estado enviado no es válido
- **Solución**: Usa solo: PENDING, CONFIRMED, PREPARING, READY, ON_THE_WAY, DELIVERED, CANCELLED

### Error: "Something went wrong" en Flutter
- **Causa**: Backend no está corriendo o hay error CORS
- **Solución**: 
  1. Verifica que Spring Boot esté corriendo
  2. Revisa los logs del backend
  3. Verifica configuración CORS

---

**Fecha**: 11 de noviembre de 2025  
**Estado**: ✅ Listo para testing  
**Próximo paso**: Ejecutar cada escenario y verificar resultados
