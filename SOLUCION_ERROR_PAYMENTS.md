# 🔧 Solución: Error NoResourceFoundException en /api/payments

## ❌ Error Encontrado

```
NoResourceFoundException: No static resource api/payments.
```

## 🔍 Diagnóstico

El error ocurrió porque:

1. ❌ **Endpoint incorrecto**: El controller tenía `@PostMapping("/create-intent")` en lugar de `@PostMapping`
2. ❌ **URL incorrecta en Flutter**: Flutter llamaba a `POST /api/payments` pero el endpoint era `POST /api/payments/create-intent`
3. ⚠️ **Servidor no actualizado**: Los cambios no se habían compilado/reiniciado

---

## ✅ Solución Aplicada

### 1. Corrección del Controller

**ANTES** (Incorrecto):
```java
@RestController
@RequestMapping("/api/payments")
public class PaymentController {
    
    @PostMapping("/create-intent")  // ❌ URL incorrecta
    public ResponseEntity<PaymentIntentResponse> createPaymentIntent(...) {
        // ...
    }
}
```

**AHORA** (Correcto):
```java
@RestController
@RequestMapping("/api/payments")
public class PaymentController {
    
    @PostMapping  // ✅ URL correcta: POST /api/payments
    public ResponseEntity<PaymentIntentResponse> createPaymentIntent(
            @RequestBody PaymentIntentRequest request,
            Authentication authentication) {  // ← JWT requerido
        // ...
    }
}
```

### 2. Endpoint Final

✅ **URL correcta**: `POST http://localhost:8080/api/payments`

---

## 🚀 Cómo Iniciar el Servidor

### Opción 1: Maven Wrapper (Recomendado)
```bash
.\mvnw spring-boot:run
```

### Opción 2: JAR empaquetado
```bash
# Compilar
.\mvnw clean package -DskipTests

# Ejecutar
java -jar target\restaurant-0.0.1-SNAPSHOT.jar
```

---

## 📱 Integración con Flutter - IMPORTANTE

### ✅ URL Correcta para el Request

```dart
// ✅ CORRECTO
final response = await http.post(
  Uri.parse('http://localhost:8080/api/payments'),  // Sin /create-intent
  headers: {
    'Authorization': 'Bearer $token',  // ← JWT OBLIGATORIO
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'amount': 15000,      // En centavos
    'currency': 'pen',    // Moneda
    'orderId': orderId,
  }),
);
```

```dart
// ❌ INCORRECTO (URL antigua)
Uri.parse('http://localhost:8080/api/payments/create-intent')  // ❌ Ya no existe
```

### ⚠️ Autenticación JWT Obligatoria

El endpoint **REQUIERE** autenticación. Si no envías el token JWT, recibirás error `401 Unauthorized`:

```dart
// ✅ Obtener token antes de hacer la solicitud
final token = await _authService.getToken();

if (token == null || token.isEmpty) {
  throw Exception('Usuario no autenticado. Por favor inicia sesión.');
}

// Usar token en el request
headers: {
  'Authorization': 'Bearer $token',  // ← OBLIGATORIO
  'Content-Type': 'application/json',
}
```

---

## 🧪 Testing del Endpoint

### 1. Obtener Token JWT

Primero necesitas autenticarte para obtener un token válido:

```bash
# Login para obtener JWT
curl -X POST http://localhost:8080/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\": \"customer@example.com\", \"password\": \"password123\"}"
```

**Respuesta esperada**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJjdXN0b21lckBleGFtcGxlLmNvbSIsImlhdCI6MTczMTM3NDEyMCwiZXhwIjoxNzMxMzc3NzIwfQ.abc123xyz"
}
```

### 2. Crear Payment Intent con JWT

Usa el token obtenido en el paso anterior:

```bash
curl -X POST http://localhost:8080/api/payments ^
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..." ^
  -H "Content-Type: application/json" ^
  -d "{\"amount\": 15000, \"currency\": \"pen\", \"orderId\": 42}"
```

**Respuesta esperada** (200 OK):
```json
{
  "clientSecret": "pi_3QHBtGFQrDKWPh9Z0k8xvQyR_secret_vYx7NzJk3mLp9sR2qWnE4tA",
  "paymentIntentId": "pi_3QHBtGFQrDKWPh9Z0k8xvQyR",
  "amount": 15000,
  "currency": "pen"
}
```

### 3. Test Sin Autenticación (Esperando Error 401)

```bash
# Sin Authorization header
curl -X POST http://localhost:8080/api/payments ^
  -H "Content-Type: application/json" ^
  -d "{\"amount\": 15000, \"currency\": \"pen\"}"
```

**Respuesta esperada** (401 Unauthorized):
```json
{
  "timestamp": "2025-11-11T22:10:00.000+00:00",
  "status": 401,
  "error": "Unauthorized",
  "message": "Full authentication is required to access this resource",
  "path": "/api/payments"
}
```

---

## 🔐 Configuración de Spring Security

El endpoint `/api/payments` está protegido por Spring Security:

```java
// SecurityConfig.java
@Bean
public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http
        .authorizeHttpRequests(auth -> auth
            // Endpoints públicos
            .requestMatchers("/api/auth/**").permitAll()
            .requestMatchers("/api/restaurants/**").permitAll()
            // Todos los demás requieren autenticación
            .anyRequest().authenticated()  // ← /api/payments requiere JWT
        )
        .addFilterBefore(jwtAuthenticationFilter, 
                UsernamePasswordAuthenticationFilter.class);
    
    return http.build();
}
```

---

## 📋 Checklist de Verificación

### Backend
- [x] Endpoint cambiado de `/create-intent` a raíz (`@PostMapping`)
- [x] URL final: `POST /api/payments`
- [x] Authentication parameter presente
- [x] Compilación exitosa (BUILD SUCCESS)
- [ ] Servidor iniciado (`.\mvnw spring-boot:run`)
- [ ] Verificar logs: "Started RestaurantApplication"

### Frontend (Flutter)
- [ ] URL actualizada a `http://localhost:8080/api/payments` (sin `/create-intent`)
- [ ] Token JWT obtenido del AuthService
- [ ] Header `Authorization: Bearer $token` incluido
- [ ] Manejo de error 401 (usuario no autenticado)
- [ ] Manejo de error 500 (error de Stripe)

---

## 🚨 Errores Comunes y Soluciones

### Error 1: `NoResourceFoundException`
**Causa**: Servidor no iniciado o endpoint incorrecto  
**Solución**: 
1. Verificar que el servidor esté corriendo
2. Verificar que la URL sea `POST /api/payments` (sin `/create-intent`)

### Error 2: `401 Unauthorized`
**Causa**: Token JWT no enviado o inválido  
**Solución**:
1. Verificar que el token se obtiene correctamente del AuthService
2. Verificar que el header sea `Authorization: Bearer $token`
3. Verificar que el token no haya expirado (duración: 1 hora)

### Error 3: `500 Internal Server Error - Amount must be at least 50 cents`
**Causa**: Monto menor a 50 centavos  
**Solución**: Enviar un monto >= 50 (centavos)

### Error 4: `Connection refused`
**Causa**: Servidor no está corriendo en puerto 8080  
**Solución**: Ejecutar `.\mvnw spring-boot:run` y esperar a "Started RestaurantApplication"

---

## 📊 Estructura de Endpoints de Pagos

| Método | URL | Autenticación | Descripción |
|--------|-----|---------------|-------------|
| POST | `/api/payments` | ✅ JWT Requerido | Crear Payment Intent |
| GET | `/api/payments/status/{id}` | ✅ JWT Requerido | Consultar estado de pago |
| POST | `/api/payments/cancel/{id}` | ✅ JWT Requerido | Cancelar Payment Intent |

---

## 🎯 Ejemplo Completo en Flutter

```dart
class PaymentService {
  final String baseUrl = 'http://localhost:8080';
  final AuthService _authService;
  
  PaymentService(this._authService);
  
  Future<PaymentIntentResponse> createPaymentIntent({
    required int amount,
    required String currency,
    required int orderId,
  }) async {
    try {
      // 1. Obtener token JWT
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Usuario no autenticado');
      }
      
      // 2. Hacer request a /api/payments (sin /create-intent)
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments'),  // ✅ URL correcta
        headers: {
          'Authorization': 'Bearer $token',  // ✅ JWT incluido
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'orderId': orderId,
        }),
      );
      
      // 3. Manejar respuesta
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentIntentResponse.fromJson(data);
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
}

// Model
class PaymentIntentResponse {
  final String clientSecret;
  final String paymentIntentId;
  final int amount;
  final String currency;
  
  PaymentIntentResponse({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.amount,
    required this.currency,
  });
  
  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentIntentResponse(
      clientSecret: json['clientSecret'],
      paymentIntentId: json['paymentIntentId'],
      amount: json['amount'],
      currency: json['currency'],
    );
  }
}
```

---

## ✅ Próximos Pasos

1. **Iniciar el servidor**:
   ```bash
   .\mvnw spring-boot:run
   ```

2. **Esperar a que inicie** (ver logs):
   ```
   Started RestaurantApplication in X.XXX seconds
   ```

3. **Actualizar Flutter**:
   - Cambiar URL a `http://localhost:8080/api/payments`
   - Verificar que se envíe el token JWT
   - Manejar errores 401 y 500

4. **Probar con cURL** (opcional):
   - Login para obtener token
   - Crear Payment Intent con el token

---

## 📝 Resumen de Cambios

| Aspecto | Antes | Ahora |
|---------|-------|-------|
| **Endpoint URL** | `/api/payments/create-intent` | `/api/payments` |
| **Anotación** | `@PostMapping("/create-intent")` | `@PostMapping` |
| **Autenticación** | JWT Requerido ✅ | JWT Requerido ✅ |
| **Formato Respuesta** | PaymentIntentResponse directo | PaymentIntentResponse directo |
| **Compilación** | ✅ BUILD SUCCESS | ✅ BUILD SUCCESS |

---

## 🎉 Estado Final

✅ **Código corregido y compilado**  
✅ **Endpoint en la URL correcta**: `POST /api/payments`  
✅ **Autenticación JWT configurada**  
⏳ **Pendiente**: Iniciar servidor y probar desde Flutter

**¡El backend está listo para recibir solicitudes de pago desde Flutter!** 🚀

---

**Fecha**: 11 de noviembre de 2025  
**Estado**: ✅ Corregido y compilado  
**Próximo paso**: Iniciar servidor con `.\mvnw spring-boot:run`
