# ✅ Implementación Completada: Estados de Órdenes con Payment Intent

## 📋 Cambios Implementados

### 1️⃣ Entity Order - Nuevos Campos

**Archivo**: `Order.java`

✅ **Campos agregados**:
- `paymentIntentId` - ID del Payment Intent de Stripe
- `paymentMethod` - Método de pago (card, cash, etc.)
- `paymentStatus` - Estado del pago (completed, pending, failed)
- `cancellationReason` - Razón de cancelación (si aplica)

**Estados disponibles**:
```java
enum Status {
    PENDING,      // Orden creada (pago efectivo)
    CONFIRMED,    // Orden confirmada (pago con tarjeta exitoso) ✅
    PREPARING,    // Restaurante preparando
    READY,        // Listo para recoger
    DELIVERED,    // Entregado ✅
    CANCELLED     // Cancelado ✅
}
```

---

### 2️⃣ DTO CreateOrderRequest - Nuevos Campos

**Archivo**: `CreateOrderRequest.java`

✅ **Campos agregados**:
```java
private String paymentIntentId;   // ID del Payment Intent
private String paymentMethod;      // card, cash, etc.
private String paymentStatus;      // completed, pending
```

**Uso desde Flutter**:
```dart
await orderService.createOrder(
  restaurantId: 1,
  items: [...],
  totalAmount: 41.80,
  deliveryAddress: "Av. Los Incas 123",
  paymentIntentId: "pi_3SSVJFFQrDKWPh9Z1pRiFDUK", // ✅ Nuevo
  paymentMethod: "card",                           // ✅ Nuevo
  paymentStatus: "completed",                      // ✅ Nuevo
);
```

---

### 3️⃣ OrderService - Lógica de Estados

**Archivo**: `OrderService.java`

✅ **Nuevo comportamiento en `createOrder()`**:

```java
// Si tiene Payment Intent ID → CONFIRMED (pago exitoso)
if (request.getPaymentIntentId() != null && !request.getPaymentIntentId().isEmpty()) {
    order.setStatus(Order.Status.CONFIRMED);  // ✅ Estado CONFIRMED
    order.setPaymentStatus("completed");
    order.setPaymentIntentId(request.getPaymentIntentId());
    order.setPaymentMethod("card");
} else {
    // Sin pago con tarjeta → PENDING (pago efectivo)
    order.setStatus(Order.Status.PENDING);
    order.setPaymentStatus("pending");
    order.setPaymentMethod("cash");
}
```

✅ **Nuevos métodos**:

1. **`updateOrderStatus(Long id, String status, String userEmail)`**
   - Actualiza el estado de una orden
   - Valida que el estado sea válido
   - Guarda la hora de actualización

2. **`cancelOrder(Long id, String reason, String userEmail)`**
   - Cancela una orden
   - Guarda la razón de cancelación
   - No permite cancelar órdenes ya entregadas

3. **`updatePaymentStatus(String paymentIntentId, String newStatus)`**
   - Actualiza el estado de pago usando el Payment Intent ID
   - Si el pago es exitoso, cambia a CONFIRMED

---

### 4️⃣ OrderController - Nuevos Endpoints

**Archivo**: `OrderController.java`

✅ **Endpoints agregados**:

#### 1. Actualizar estado de orden
```http
PUT /api/orders/{id}/status?status=PREPARING
Authorization: Bearer {JWT_TOKEN}
```

**Ejemplo cURL**:
```bash
curl -X PUT "http://localhost:8080/api/orders/5/status?status=CONFIRMED" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### 2. Marcar como entregada
```http
POST /api/orders/{id}/deliver
Authorization: Bearer {JWT_TOKEN}
```

**Ejemplo cURL**:
```bash
curl -X POST http://localhost:8080/api/orders/5/deliver \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Respuesta**:
```json
{
  "success": true,
  "message": "Orden marcada como entregada",
  "data": {
    "id": 5,
    "status": "DELIVERED",
    "paymentIntentId": "pi_3SSVJFFQrDKWPh9Z1pRiFDUK",
    "totalAmount": 41.80,
    "updatedAt": "2025-11-11T23:45:00"
  }
}
```

#### 3. Cancelar orden
```http
POST /api/orders/{id}/cancel?reason=Cliente solicitó cancelación
Authorization: Bearer {JWT_TOKEN}
```

**Ejemplo cURL**:
```bash
curl -X POST "http://localhost:8080/api/orders/5/cancel?reason=Cliente%20solicitó%20cancelación" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Respuesta**:
```json
{
  "success": true,
  "message": "Orden cancelada exitosamente",
  "data": {
    "id": 5,
    "status": "CANCELLED",
    "cancellationReason": "Cliente solicitó cancelación",
    "updatedAt": "2025-11-11T23:46:00"
  }
}
```

---

### 5️⃣ OrderDTO - Campos Actualizados

**Archivo**: `OrderDTO.java`

✅ **Campos agregados**:
```java
private String paymentIntentId;
private String paymentMethod;
private String paymentStatus;
private String cancellationReason;
private LocalDateTime updatedAt;
```

**Respuesta de GET /api/orders**:
```json
{
  "success": true,
  "data": [
    {
      "id": 5,
      "status": "CONFIRMED",
      "paymentIntentId": "pi_3SSVJFFQrDKWPh9Z1pRiFDUK",
      "paymentMethod": "card",
      "paymentStatus": "completed",
      "totalAmount": 41.80,
      "createdAt": "2025-11-11T23:05:29",
      "updatedAt": "2025-11-11T23:05:29"
    },
    {
      "id": 4,
      "status": "PENDING",
      "paymentMethod": "cash",
      "paymentStatus": "pending",
      "totalAmount": 125.40,
      "createdAt": "2025-11-10T18:30:00"
    }
  ]
}
```

---

## 🗄️ Base de Datos - Actualización

### Script SQL

**Archivo**: `UPDATE_ORDERS_PAYMENT.sql`

```sql
-- Agregar columnas nuevas
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS payment_intent_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS payment_method VARCHAR(50),
ADD COLUMN IF NOT EXISTS payment_status VARCHAR(50),
ADD COLUMN IF NOT EXISTS cancellation_reason VARCHAR(500);

-- Crear índice
CREATE INDEX IF NOT EXISTS idx_payment_intent_id 
ON orders(payment_intent_id);

-- Actualizar órdenes existentes con pago
UPDATE orders 
SET status = 'CONFIRMED', 
    payment_status = 'completed'
WHERE payment_intent_id IS NOT NULL 
  AND status = 'PENDING';
```

### Ejecutar el Script

**Opción 1: pgAdmin**
1. Conectar a PostgreSQL
2. Abrir Query Tool
3. Copiar y ejecutar el script

**Opción 2: psql (Terminal)**
```bash
psql -U postgres -d restaurant_db -f UPDATE_ORDERS_PAYMENT.sql
```

---

## 🧪 Testing

### 1. Crear Orden con Pago con Tarjeta

**Flutter → Backend**:
```dart
// 1. Procesar pago
final paymentResult = await paymentService.processPaymentWithCard(
  amount: 41.80,
  currency: 'usd',
);

// 2. Crear orden con Payment Intent ID
final order = await orderService.createOrder(
  restaurantId: 1,
  items: [...],
  totalAmount: 41.80,
  paymentIntentId: paymentResult.paymentIntentId, // ✅
  paymentMethod: 'card',
  paymentStatus: 'completed',
);
```

**Verificar en Backend**:
```sql
SELECT id, status, payment_method, payment_status, payment_intent_id
FROM orders
ORDER BY created_at DESC
LIMIT 5;
```

**Resultado esperado**:
```
| id | status    | payment_method | payment_status | payment_intent_id              |
|----|-----------|----------------|----------------|--------------------------------|
| 5  | CONFIRMED | card           | completed      | pi_3SSVJFFQrDKWPh9Z1pRiFDUK  |
```

✅ **Estado inicial: CONFIRMED (no PENDING)**

---

### 2. Actualizar Estado de Orden

```bash
# Cambiar a PREPARING
curl -X PUT "http://localhost:8080/api/orders/5/status?status=PREPARING" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Cambiar a READY
curl -X PUT "http://localhost:8080/api/orders/5/status?status=READY" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Cambiar a ON_THE_WAY
curl -X PUT "http://localhost:8080/api/orders/5/status?status=ON_THE_WAY" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### 3. Marcar como Entregada

```bash
curl -X POST http://localhost:8080/api/orders/5/deliver \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Verificar en Flutter**:
- Ve a "Mis Pedidos"
- Selecciona filtro "Entregados"
- ✅ Debe aparecer la orden #5

---

### 4. Cancelar Orden

```bash
curl -X POST "http://localhost:8080/api/orders/4/cancel?reason=No tengo dinero" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Verificar en Flutter**:
- Ve a "Mis Pedidos"
- Selecciona filtro "Cancelados"
- ✅ Debe aparecer la orden #4

---

## 📱 Integración con Flutter

### En OrderService (Flutter)

```dart
// Actualizar estado
Future<void> updateOrderStatus(int orderId, String status) async {
  final token = await _authService.getToken();
  
  await http.put(
    Uri.parse('$baseUrl/api/orders/$orderId/status?status=$status'),
    headers: {'Authorization': 'Bearer $token'},
  );
}

// Marcar como entregada
Future<void> markAsDelivered(int orderId) async {
  final token = await _authService.getToken();
  
  await http.post(
    Uri.parse('$baseUrl/api/orders/$orderId/deliver'),
    headers: {'Authorization': 'Bearer $token'},
  );
}

// Cancelar orden
Future<void> cancelOrder(int orderId, String reason) async {
  final token = await _authService.getToken();
  
  await http.post(
    Uri.parse('$baseUrl/api/orders/$orderId/cancel?reason=$reason'),
    headers: {'Authorization': 'Bearer $token'},
  );
}
```

---

## 🎯 Ciclo de Vida Completo de una Orden

```
1. Usuario hace pago con tarjeta
   └─> Flutter: processPaymentWithCard()
   └─> Stripe: Payment Intent creado
   └─> Result: paymentIntentId = "pi_xxx"

2. Usuario crea orden
   └─> Flutter: createOrder(paymentIntentId: "pi_xxx")
   └─> Backend: OrderService.createOrder()
   └─> Estado: CONFIRMED (automático) ✅
   
3. Restaurante prepara
   └─> Admin: updateOrderStatus(id, "PREPARING")
   └─> Estado: PREPARING
   
4. Pedido listo
   └─> Admin: updateOrderStatus(id, "READY")
   └─> Estado: READY
   
5. Repartidor en camino
   └─> Admin: updateOrderStatus(id, "ON_THE_WAY")
   └─> Estado: ON_THE_WAY
   
6. Entregado
   └─> Admin: markAsDelivered(id)
   └─> Estado: DELIVERED ✅
   └─> Aparece en "Entregados" en Flutter
```

---

## ✅ Checklist de Verificación

### Backend
- [x] Agregar campos a entity Order
- [x] Actualizar CreateOrderRequest DTO
- [x] Actualizar OrderDTO
- [x] Modificar OrderService.createOrder()
- [x] Agregar método updateOrderStatus()
- [x] Agregar método cancelOrder()
- [x] Crear endpoint PUT /api/orders/{id}/status
- [x] Crear endpoint POST /api/orders/{id}/deliver
- [x] Crear endpoint POST /api/orders/{id}/cancel
- [x] Compilación exitosa
- [ ] Ejecutar script SQL para actualizar base de datos
- [ ] Reiniciar servidor

### Testing
- [ ] Crear orden con pago → Verificar estado CONFIRMED
- [ ] Crear orden efectivo → Verificar estado PENDING
- [ ] Actualizar estado a DELIVERED → Verificar en Flutter "Entregados"
- [ ] Cancelar orden → Verificar en Flutter "Cancelados"
- [ ] Verificar que Payment Intent ID se guarda correctamente

---

## 🚀 Próximos Pasos

1. **Ejecutar script SQL** para actualizar la base de datos
2. **Reiniciar el servidor** para aplicar los cambios
3. **Probar desde Flutter** haciendo un pago real
4. **Verificar** que el estado cambia automáticamente a CONFIRMED

---

## 📊 Estadísticas de Órdenes

```sql
-- Ver distribución de órdenes por estado
SELECT 
    status,
    COUNT(*) as total,
    SUM(total_amount) as ventas_totales
FROM orders
GROUP BY status
ORDER BY total DESC;
```

**Resultado esperado**:
```
| status    | total | ventas_totales |
|-----------|-------|----------------|
| CONFIRMED | 3     | 125.40         |
| DELIVERED | 2     | 87.30          |
| PENDING   | 1     | 41.80          |
| CANCELLED | 1     | 23.50          |
```

---

**Fecha**: 11 de noviembre de 2025  
**Estado**: ✅ Implementado y compilado  
**Pendiente**: Ejecutar script SQL y reiniciar servidor  
**Próximo paso**: Testing desde Flutter
