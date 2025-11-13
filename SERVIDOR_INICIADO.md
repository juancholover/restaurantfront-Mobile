# ✅ Servidor Iniciado - Guía de Integración Flutter

## 🎉 Estado Actual

✅ **Servidor Spring Boot corriendo exitosamente**  
✅ **Puerto**: 8080  
✅ **Stripe API inicializada**  
✅ **Endpoint disponible**: `POST http://localhost:8080/api/payments`

---

## 📱 Actualización Requerida en Flutter

### ❌ URL Incorrecta (Causa del Error)

Tu app Flutter está llamando a:
```dart
POST http://localhost:8080/api/payments
```

Pero estaba configurada para:
```dart
POST http://localhost:8080/api/payments/create-intent  // ❌ Ya no existe
```

### ✅ Solución en Flutter

**Archivo**: `lib/services/payment_service.dart` (o similar)

**Cambio 1: Actualizar URL**
```dart
// ❌ ANTES (Incorrecto)
Uri.parse('$baseUrl/api/payments/create-intent')

// ✅ AHORA (Correcto)
Uri.parse('$baseUrl/api/payments')
```

**Cambio 2: Verificar que se envíe el token JWT**
```dart
Future<Map<String, dynamic>> createPaymentIntent({
  required int amount,
  required String currency,
  required int orderId,
}) async {
  try {
    // 1. Obtener token JWT del usuario autenticado
    final token = await _authService.getToken();
    
    if (token == null || token.isEmpty) {
      throw Exception('Usuario no autenticado. Por favor inicia sesión.');
    }
    
    // 2. Hacer request con JWT
    final response = await http.post(
      Uri.parse('$baseUrl/api/payments'),  // ✅ SIN /create-intent
      headers: {
        'Authorization': 'Bearer $token',  // ✅ JWT OBLIGATORIO
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': amount,      // En centavos: 15000 = S/150.00
        'currency': currency,  // 'pen' o 'usd'
        'orderId': orderId,
      }),
    );
    
    // 3. Manejar respuesta
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // ✅ Respuesta directa (sin wrapper)
      return {
        'clientSecret': data['clientSecret'],
        'paymentIntentId': data['paymentIntentId'],
        'amount': data['amount'],
        'currency': data['currency'],
      };
    } else if (response.statusCode == 401) {
      throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
    } else {
      final error = jsonDecode(response.body);
      throw Exception('Error: ${error['message']}');
    }
    
  } catch (e) {
    print('Error al crear Payment Intent: $e');
    rethrow;
  }
}
```

---

## 🧪 Testing Rápido

### Test 1: Sin Autenticación (Debe fallar con 401)

```bash
curl -X POST http://localhost:8080/api/payments ^
  -H "Content-Type: application/json" ^
  -d "{\"amount\": 15000, \"currency\": \"pen\"}"
```

**Resultado esperado**: 401 Unauthorized
```json
{
  "timestamp": "2025-11-11T22:15:00.000+00:00",
  "status": 401,
  "error": "Unauthorized",
  "message": "Full authentication is required"
}
```

### Test 2: Con Autenticación (Debe funcionar)

**Paso 1 - Obtener token:**
```bash
curl -X POST http://localhost:8080/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\": \"customer@example.com\", \"password\": \"password123\"}"
```

**Paso 2 - Usar token en pago:**
```bash
curl -X POST http://localhost:8080/api/payments ^
  -H "Authorization: Bearer <TOKEN_DEL_PASO_1>" ^
  -H "Content-Type: application/json" ^
  -d "{\"amount\": 15000, \"currency\": \"pen\", \"orderId\": 42}"
```

**Resultado esperado**: 200 OK
```json
{
  "clientSecret": "pi_3QHBtG..._secret_vYx7Nz...",
  "paymentIntentId": "pi_3QHBtGFQrDKWPh9Z0k8xvQyR",
  "amount": 15000,
  "currency": "pen"
}
```

---

## 🔍 Verificación en Logs del Servidor

Cuando Flutter haga una solicitud válida, verás en la consola del servidor:

```
INFO  [PaymentController] Solicitud de Payment Intent de usuario: customer@example.com, amount=15000, currency=pen, orderId=42
INFO  [PaymentService] Creando Payment Intent para orden: 42, monto: 15000
INFO  [PaymentService] Payment Intent creado exitosamente: pi_3QHBtG...
INFO  [PaymentController] Payment Intent creado exitosamente para usuario: customer@example.com
```

Si ves error 401 sin autenticación:
```
WARN  [JwtAuthenticationFilter] No se encontró token JWT en el header Authorization
ERROR [AuthenticationEntryPoint] Acceso denegado: Full authentication is required
```

---

## 📋 Checklist de Integración Flutter

### Antes de probar:
- [ ] Servidor Spring Boot corriendo (✅ Ya está corriendo)
- [ ] URL actualizada en Flutter: `POST /api/payments` (sin `/create-intent`)
- [ ] AuthService funcionando para obtener token JWT
- [ ] Usuario autenticado en la app (login exitoso)

### En el código Flutter:
- [ ] Importar `package:http/http.dart` o similar
- [ ] Obtener token con `await _authService.getToken()`
- [ ] Verificar que token no sea null/empty
- [ ] Incluir header: `Authorization: Bearer $token`
- [ ] URL correcta: `$baseUrl/api/payments`
- [ ] Manejar status 200 (éxito)
- [ ] Manejar status 401 (sesión expirada)
- [ ] Manejar status 500 (error de Stripe)

### Después de recibir respuesta:
- [ ] Extraer `clientSecret` de la respuesta
- [ ] Inicializar Stripe Payment Sheet con el `clientSecret`
- [ ] Confirmar pago con `Stripe.instance.presentPaymentSheet()`

---

## 🚨 Posibles Errores y Soluciones

### Error 1: "Connection refused" en Flutter
**Causa**: Servidor no está corriendo  
**Solución**: Verificar que veas "Tomcat started on port 8080" en consola

### Error 2: "401 Unauthorized"
**Causa**: Token JWT no enviado o inválido  
**Solución**:
1. Verificar que el usuario haya iniciado sesión
2. Verificar que `_authService.getToken()` retorne un token válido
3. Verificar formato del header: `Authorization: Bearer $token` (con espacio)

### Error 3: "NoResourceFoundException"
**Causa**: URL incorrecta en Flutter  
**Solución**: Cambiar de `/api/payments/create-intent` a `/api/payments`

### Error 4: "Amount must be at least 50 cents"
**Causa**: Monto menor a 50 centavos  
**Solución**: Enviar amount >= 50

---

## 📊 Formato de Respuesta Esperado

### Solicitud (Request)
```json
{
  "amount": 15000,
  "currency": "pen",
  "orderId": 42,
  "metadata": {
    "restaurantId": "5",
    "customerName": "Juan Pérez"
  }
}
```

### Respuesta Exitosa (Response 200)
```json
{
  "clientSecret": "pi_3QHBtGFQrDKWPh9Z0k8xvQyR_secret_vYx7NzJk3mLp9sR2qWnE4tA",
  "paymentIntentId": "pi_3QHBtGFQrDKWPh9Z0k8xvQyR",
  "amount": 15000,
  "currency": "pen"
}
```

### Respuesta de Error 401 (No autenticado)
```json
{
  "timestamp": "2025-11-11T22:15:00.000+00:00",
  "status": 401,
  "error": "Unauthorized",
  "message": "Full authentication is required to access this resource",
  "path": "/api/payments"
}
```

### Respuesta de Error 500 (Error de Stripe)
```json
{
  "timestamp": "2025-11-11T22:16:00.000+00:00",
  "status": 500,
  "error": "Internal Server Error",
  "message": "Error al procesar el pago: Amount must be at least 50 cents",
  "path": "/api/payments"
}
```

---

## 🎯 Pasos para Probar en Flutter

1. **Asegurar que el usuario esté autenticado**:
   ```dart
   final isLoggedIn = await _authService.isLoggedIn();
   if (!isLoggedIn) {
     // Redirigir a login
     Navigator.pushNamed(context, '/login');
     return;
   }
   ```

2. **Crear el Payment Intent**:
   ```dart
   final paymentData = await _paymentService.createPaymentIntent(
     amount: 15000,      // S/ 150.00
     currency: 'pen',
     orderId: order.id,
   );
   ```

3. **Confirmar con Stripe**:
   ```dart
   await Stripe.instance.initPaymentSheet(
     paymentSheetParameters: SetupPaymentSheetParameters(
       paymentIntentClientSecret: paymentData['clientSecret'],
       merchantDisplayName: 'Restaurant App',
     ),
   );
   
   await Stripe.instance.presentPaymentSheet();
   ```

4. **Manejar resultado**:
   ```dart
   try {
     // Pago confirmado
     print('✅ Pago exitoso!');
   } catch (e) {
     // Pago cancelado/fallido
     print('❌ Error: $e');
   }
   ```

---

## 📝 Resumen de URLs

| Descripción | URL | Método | Auth |
|-------------|-----|--------|------|
| **Login** | `/api/auth/login` | POST | ❌ No |
| **Register** | `/api/auth/register` | POST | ❌ No |
| **Crear Payment Intent** | `/api/payments` | POST | ✅ JWT |
| **Estado de Pago** | `/api/payments/status/{id}` | GET | ✅ JWT |
| **Cancelar Pago** | `/api/payments/cancel/{id}` | POST | ✅ JWT |
| **Listar Restaurantes** | `/api/restaurants` | GET | ❌ No |

---

## ✅ Estado Final

🟢 **Servidor**: Corriendo en `http://localhost:8080`  
🟢 **Stripe**: API inicializada con claves de test  
🟢 **Endpoint**: `POST /api/payments` (requiere JWT)  
🟢 **Base de datos**: Conectada a PostgreSQL en puerto 5433  
🟢 **Seguridad**: JWT authentication habilitado

---

## 🚀 Próximos Pasos

1. ✅ **Backend listo** - Servidor corriendo
2. ⏳ **Actualizar Flutter** - Cambiar URL y verificar token JWT
3. ⏳ **Probar pago** - Hacer transacción de prueba
4. ⏳ **Verificar en Stripe Dashboard** - Ver Payment Intent creado

**¡El backend está 100% listo para recibir solicitudes de pago desde Flutter!** 🎉

---

**Fecha**: 11 de noviembre de 2025  
**Hora**: 22:10:40  
**Estado**: 🟢 Servidor activo  
**Puerto**: 8080  
**URL Base**: http://localhost:8080
