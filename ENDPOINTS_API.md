# 📡 Documentación de Endpoints - Backend Restaurant API

## 🌐 URL Base
```
http://localhost:8080/api
```

---

## 📑 Índice de Endpoints

1. [Autenticación](#autenticación)
2. [Restaurantes](#restaurantes)
3. [Productos/Menú](#productosmenú)
4. [Órdenes](#órdenes)
5. [Reseñas](#reseñas)
6. [Favoritos](#favoritos)
7. [Pagos (Stripe)](#pagos-stripe)

---

## 🔐 Autenticación

### 1. Registrar Usuario
```http
POST /api/auth/register
```

**Body:**
```json
{
  "name": "Juan Pérez",
  "email": "juan@example.com",
  "password": "password123",
  "phone": "+51987654321",
  "role": "CUSTOMER"
}
```

**Roles disponibles:**
- `CUSTOMER` - Cliente
- `RESTAURANT_OWNER` - Dueño de restaurante
- `ADMIN` - Administrador

**Respuesta exitosa (201):**
```json
{
  "success": true,
  "message": "Usuario registrado exitosamente",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "name": "Juan Pérez",
      "email": "juan@example.com",
      "role": "CUSTOMER"
    }
  }
}
```

---

### 2. Iniciar Sesión
```http
POST /api/auth/login
```

**Body:**
```json
{
  "email": "juan@example.com",
  "password": "password123"
}
```

**Respuesta exitosa (200):**
```json
{
  "success": true,
  "message": "Login exitoso",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "name": "Juan Pérez",
      "email": "juan@example.com",
      "role": "CUSTOMER"
    }
  }
}
```

---

### 3. Obtener Perfil del Usuario
```http
GET /api/auth/profile
```

**Headers:**
```
Authorization: Bearer {token}
```

**Respuesta exitosa (200):**
```json
{
  "success": true,
  "message": "Perfil obtenido exitosamente",
  "data": {
    "id": 1,
    "name": "Juan Pérez",
    "email": "juan@example.com",
    "phone": "+51987654321",
    "role": "CUSTOMER",
    "createdAt": "2025-11-01T10:00:00"
  }
}
```

---

## 🍽️ Restaurantes

### 1. Listar Todos los Restaurantes
```http
GET /api/restaurants
```

**Query Parameters (opcionales):**
- `search` - Búsqueda por nombre (ej: `?search=pizza`)
- `category` - Filtrar por categoría (ej: `?category=italiana`)

**Respuesta exitosa (200):**
```json
{
  "success": true,
  "message": "Restaurantes obtenidos exitosamente",
  "data": [
    {
      "id": 1,
      "name": "Pizza Deliciosa",
      "description": "Las mejores pizzas artesanales",
      "address": "Av. Prolongación Inca Manco Cápac, Ñaña",
      "phone": "+51987654321",
      "rating": 4.8,
      "imageUrl": "https://...",
      "coverImageUrl": "https://...",
      "deliveryFee": 2.5,
      "deliveryTime": 30,
      "latitude": -12.0431,
      "longitude": -76.9582,
      "hasPromotion": true,
      "promotionTitle": "2x1 en Pizzas Familiares",
      "promotionDescription": "Válido de lunes a viernes",
      "discountPercentage": 50,
      "promotionStartDate": "2025-11-01",
      "promotionEndDate": "2025-11-30",
      "priceRange": "$$",
      "minPrice": 15.0,
      "maxPrice": 45.0,
      "averagePrice": 25.0,
      "isOpenNow": true,
      "todaySchedule": "11:00 AM - 10:00 PM",
      "reviewCount": 25,
      "categories": ["Italiana", "Pizza", "Fast Food"],
      "isFavorite": false,
      "totalProducts": 15
    }
  ]
}
```

---

### 2. Obtener Restaurante por ID
```http
GET /api/restaurants/{id}
```

**Ejemplo:**
```http
GET /api/restaurants/1
```

**Respuesta:** Igual que el objeto individual anterior.

---

### 3. Buscar Restaurantes
```http
GET /api/restaurants/search?query={texto}
```

**Ejemplo:**
```http
GET /api/restaurants/search?query=pizza
```

**Respuesta:** Lista de restaurantes que coinciden con la búsqueda.

---

### 4. Restaurantes con Promociones Activas
```http
GET /api/restaurants/promotions
```

**Respuesta:** Lista de restaurantes que tienen `hasPromotion = true` y están dentro del rango de fechas.

---

### 5. Restaurantes por Rango de Precio
```http
GET /api/restaurants/price-range/{range}
```

**Rangos disponibles:**
- `$` - Económico (hasta $15)
- `$$` - Moderado ($15-$30)
- `$$$` - Caro ($30-$60)
- `$$$$` - Muy caro (más de $60)

**Ejemplo:**
```http
GET /api/restaurants/price-range/$$
```

---

### 6. Restaurantes Abiertos Ahora
```http
GET /api/restaurants/open-now
```

**Respuesta:** Lista de restaurantes con `isOpenNow = true` (calculado en tiempo real).

---

### 7. Restaurantes por Categoría
```http
GET /api/restaurants?category={categoria}
```

**Ejemplo:**
```http
GET /api/restaurants?category=italiana
```

**Búsqueda:** Case-insensitive, coincidencia parcial.

---

## 🍕 Productos/Menú

### 1. Listar Productos de un Restaurante
```http
GET /api/products/restaurant/{restaurantId}
```

**Ejemplo:**
```http
GET /api/products/restaurant/1
```

**Respuesta exitosa (200):**
```json
{
  "success": true,
  "message": "Productos obtenidos exitosamente",
  "data": [
    {
      "id": 1,
      "name": "Pizza Margarita",
      "description": "Pizza clásica con albahaca fresca",
      "price": 25.50,
      "category": "Pizzas",
      "imageUrl": "https://...",
      "isAvailable": true,
      "restaurantId": 1,
      "createdAt": "2025-11-01T10:00:00"
    }
  ]
}
```

---

### 2. Obtener Producto por ID
```http
GET /api/products/{id}
```

**Ejemplo:**
```http
GET /api/products/1
```

---

### 3. Crear Producto (Requiere autenticación)
```http
POST /api/products
```

**Headers:**
```
Authorization: Bearer {token}
```

**Body:**
```json
{
  "name": "Pizza Hawaiana",
  "description": "Pizza con piña y jamón",
  "price": 28.00,
  "category": "Pizzas",
  "imageUrl": "https://...",
  "restaurantId": 1
}
```

---

### 4. Actualizar Producto
```http
PUT /api/products/{id}
```

**Headers:**
```
Authorization: Bearer {token}
```

**Body:** Igual que crear.

---

### 5. Eliminar Producto
```http
DELETE /api/products/{id}
```

**Headers:**
```
Authorization: Bearer {token}
```

---

## 📦 Órdenes

### 1. Crear Orden
```http
POST /api/orders
```

**Headers:**
```
Authorization: Bearer {token}
```

**Body:**
```json
{
  "restaurantId": 1,
  "deliveryAddress": "Av. Los Olivos 456, Ñaña",
  "notes": "Sin cebolla por favor",
  "items": [
    {
      "menuItemId": 1,
      "quantity": 2,
      "price": 25.50
    },
    {
      "menuItemId": 2,
      "quantity": 1,
      "price": 15.00
    }
  ]
}
```

**Respuesta exitosa (201):**
```json
{
  "success": true,
  "message": "Orden creada exitosamente",
  "data": {
    "id": 1,
    "userId": 1,
    "restaurantId": 1,
    "restaurantName": "Pizza Deliciosa",
    "totalAmount": 66.00,
    "status": "PENDING",
    "deliveryAddress": "Av. Los Olivos 456, Ñaña",
    "notes": "Sin cebolla por favor",
    "items": [
      {
        "id": 1,
        "menuItemName": "Pizza Margarita",
        "quantity": 2,
        "price": 25.50
      }
    ],
    "createdAt": "2025-11-11T16:30:00"
  }
}
```

---

### 2. Listar Órdenes del Usuario
```http
GET /api/orders
```

**Alias:**
```http
GET /api/orders/my
```

**Headers:**
```
Authorization: Bearer {token}
```

**Respuesta:** Lista de órdenes del usuario autenticado, ordenadas por fecha (más recientes primero).

---

### 3. Obtener Orden por ID
```http
GET /api/orders/{id}
```

**Headers:**
```
Authorization: Bearer {token}
```

---

### 4. Actualizar Estado de Orden
```http
PUT /api/orders/{id}/status
```

**Headers:**
```
Authorization: Bearer {token}
```

**Body:**
```json
{
  "status": "CONFIRMED"
}
```

**Estados disponibles:**
- `PENDING` - Pendiente
- `CONFIRMED` - Confirmada
- `PREPARING` - En preparación
- `READY` - Lista
- `DELIVERING` - En camino
- `DELIVERED` - Entregada
- `CANCELLED` - Cancelada

---

### 5. Listar Órdenes de un Restaurante (Dueño)
```http
GET /api/orders/restaurant/{restaurantId}
```

**Headers:**
```
Authorization: Bearer {token}
```

---

## ⭐ Reseñas

### 1. Crear Reseña
```http
POST /api/reviews
```

**Headers:**
```
Authorization: Bearer {token}
```

**Body (con orden):**
```json
{
  "restaurantId": 1,
  "orderId": 5,
  "rating": 5,
  "comment": "Excelente servicio y comida deliciosa!",
  "images": ["https://image1.jpg", "https://image2.jpg"]
}
```

**Body (sin orden):**
```json
{
  "restaurantId": 1,
  "rating": 4,
  "comment": "Buen ambiente y atención",
  "images": []
}
```

**Respuesta exitosa (201):**
```json
{
  "success": true,
  "message": "Reseña creada exitosamente",
  "data": {
    "id": 1,
    "userId": 1,
    "userName": "Juan Pérez",
    "restaurantId": 1,
    "restaurantName": "Pizza Deliciosa",
    "orderId": 5,
    "rating": 5,
    "comment": "Excelente servicio!",
    "images": ["https://..."],
    "createdAt": "2025-11-11T16:30:00"
  }
}
```

---

### 2. Listar Reseñas de un Restaurante
```http
GET /api/reviews/restaurant/{restaurantId}
```

**Ejemplo:**
```http
GET /api/reviews/restaurant/1
```

**Respuesta:** Lista de reseñas ordenadas por fecha (más recientes primero).

---

### 3. Verificar si el Usuario puede Reseñar una Orden
```http
GET /api/reviews/order/{orderId}/check
```

**Headers:**
```
Authorization: Bearer {token}
```

**Respuesta:**
```json
{
  "success": true,
  "message": "Verificación completada",
  "data": {
    "canReview": true,
    "hasReview": false,
    "orderStatus": "DELIVERED"
  }
}
```

---

### 4. Listar Reseñas del Usuario
```http
GET /api/reviews/user
```

**Headers:**
```
Authorization: Bearer {token}
```

---

### 5. Reseñas Sin Orden Asociada
```http
GET /api/reviews/no-order
```

**Respuesta:** Reseñas donde `orderId IS NULL`.

---

### 6. Reseñas Con Orden Asociada
```http
GET /api/reviews/with-order
```

**Respuesta:** Reseñas donde `orderId IS NOT NULL`.

---

## ❤️ Favoritos

### 1. Agregar a Favoritos
```http
POST /api/favorites
```

**Headers:**
```
Authorization: Bearer {token}
```

**Body:**
```json
{
  "restaurantId": 1
}
```

**Respuesta exitosa (201):**
```json
{
  "success": true,
  "message": "Restaurante agregado a favoritos",
  "data": {
    "id": 1,
    "userId": 1,
    "restaurantId": 1,
    "createdAt": "2025-11-11T16:30:00"
  }
}
```

---

### 2. Listar Favoritos del Usuario
```http
GET /api/favorites
```

**Headers:**
```
Authorization: Bearer {token}
```

**Respuesta:** Lista de restaurantes favoritos del usuario.

---

### 3. Eliminar de Favoritos
```http
DELETE /api/favorites/restaurant/{restaurantId}
```

**Headers:**
```
Authorization: Bearer {token}
```

**Ejemplo:**
```http
DELETE /api/favorites/restaurant/1
```

---

### 4. Verificar si es Favorito
```http
GET /api/favorites/check/{restaurantId}
```

**Headers:**
```
Authorization: Bearer {token}
```

**Respuesta:**
```json
{
  "success": true,
  "message": "Verificación completada",
  "data": {
    "isFavorite": true
  }
}
```

---

## 💳 Pagos (Stripe)

### 1. Crear Payment Intent
```http
POST /api/payments/create-intent
```

**Body:**
```json
{
  "amount": 5000,
  "currency": "pen",
  "orderId": 1,
  "metadata": {
    "customerName": "Juan Pérez",
    "customerEmail": "juan@example.com",
    "restaurantName": "Pizza Deliciosa"
  }
}
```

**Campos:**
- `amount` (requerido): Monto en **centavos** (5000 = S/50.00)
- `currency` (opcional): Código ISO de moneda (default: "usd")
  - `"usd"` - Dólares estadounidenses
  - `"pen"` - Soles peruanos
  - `"mxn"` - Pesos mexicanos
  - `"eur"` - Euros
- `orderId` (opcional): ID de la orden en tu base de datos
- `metadata` (opcional): Cualquier dato adicional

**Respuesta exitosa (200):**
```json
{
  "success": true,
  "message": "Payment Intent creado exitosamente",
  "data": {
    "clientSecret": "pi_3QCXXXXXX_secret_YYYYYY",
    "paymentIntentId": "pi_3QCXXXXXX",
    "status": "requires_payment_method"
  }
}
```

**El `clientSecret` se envía a Flutter para completar el pago.**

---

### 2. Obtener Estado de un Pago
```http
GET /api/payments/status/{paymentIntentId}
```

**Ejemplo:**
```http
GET /api/payments/status/pi_3QCXXXXXX
```

**Respuesta exitosa (200):**
```json
{
  "success": true,
  "message": "Estado del pago obtenido exitosamente",
  "data": "succeeded"
}
```

**Estados posibles:**
- `requires_payment_method` - Esperando método de pago
- `requires_confirmation` - Esperando confirmación
- `requires_action` - Requiere acción del usuario (3D Secure)
- `processing` - Procesando
- `succeeded` - ✅ Pago exitoso
- `canceled` - Cancelado

---

### 3. Cancelar Payment Intent
```http
POST /api/payments/cancel/{paymentIntentId}
```

**Ejemplo:**
```http
POST /api/payments/cancel/pi_3QCXXXXXX
```

**Respuesta exitosa (200):**
```json
{
  "success": true,
  "message": "Payment Intent cancelado exitosamente",
  "data": true
}
```

---

## 🔒 Autenticación con JWT

### Cómo usar el token:

1. **Login o Register** devuelve un token
2. **Guarda el token** en el almacenamiento local de tu app
3. **Envía el token** en el header de cada petición protegida:

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Endpoints públicos (no requieren token):
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/restaurants` (todos los endpoints de restaurantes)
- `GET /api/products`
- `GET /api/reviews`

### Endpoints protegidos (requieren token):
- `GET /api/auth/profile`
- `POST /api/orders`
- `GET /api/orders`
- `POST /api/reviews`
- `POST /api/favorites`
- Todos los endpoints de creación/actualización/eliminación

---

## 📊 Códigos de Respuesta HTTP

| Código | Significado | Cuándo ocurre |
|--------|-------------|---------------|
| 200 | OK | Petición exitosa |
| 201 | Created | Recurso creado exitosamente |
| 400 | Bad Request | Datos inválidos en el body |
| 401 | Unauthorized | Token inválido o no enviado |
| 403 | Forbidden | No tienes permisos |
| 404 | Not Found | Recurso no encontrado |
| 500 | Internal Server Error | Error del servidor |

---

## 🧪 Testing con cURL (PowerShell)

### Crear Payment Intent
```powershell
curl -X POST http://localhost:8080/api/payments/create-intent `
  -H "Content-Type: application/json" `
  -d '{\"amount\": 5000, \"currency\": \"pen\", \"orderId\": 1}'
```

### Registrar Usuario
```powershell
$body = @{
    name = "Juan Pérez"
    email = "juan@example.com"
    password = "password123"
    phone = "+51987654321"
    role = "CUSTOMER"
} | ConvertTo-Json

curl -X POST http://localhost:8080/api/auth/register `
  -H "Content-Type: application/json" `
  -d $body
```

### Listar Restaurantes
```powershell
curl http://localhost:8080/api/restaurants
```

### Buscar Restaurantes
```powershell
curl "http://localhost:8080/api/restaurants?category=pizza"
```

---

## 🔗 URLs Útiles

- **Backend Local:** http://localhost:8080
- **Swagger (si está configurado):** http://localhost:8080/swagger-ui.html
- **Actuator Health:** http://localhost:8080/actuator/health
- **Stripe Dashboard:** https://dashboard.stripe.com/payments

---

## 📱 Configuración para Flutter

### Android Emulator
```dart
static const String baseUrl = 'http://10.0.2.2:8080/api';
```

### Dispositivo Real (misma red WiFi)
```dart
static const String baseUrl = 'http://192.168.X.X:8080/api';
```

**Para encontrar tu IP:**
```cmd
ipconfig
```
Busca "Dirección IPv4"

---

## 🛡️ Seguridad

### Stripe
- ✅ Secret Key solo en backend
- ✅ Publishable Key puede estar en frontend
- ✅ Modo test: `sk_test_...` y `pk_test_...`
- ✅ Modo producción: `sk_live_...` y `pk_live_...`

### JWT
- ✅ Token expira en 7 días
- ✅ Secret key configurable en `application.properties`
- ✅ Verificación automática en cada petición protegida

---

## 📊 Resumen de Endpoints

| Categoría | Endpoints | Públicos | Protegidos |
|-----------|-----------|----------|------------|
| Autenticación | 3 | 2 | 1 |
| Restaurantes | 7 | 7 | 0 |
| Productos | 5 | 2 | 3 |
| Órdenes | 5 | 0 | 5 |
| Reseñas | 6 | 3 | 3 |
| Favoritos | 4 | 0 | 4 |
| Pagos | 3 | 3 | 0 |
| **TOTAL** | **33** | **17** | **16** |

---

**Última actualización:** 11 de noviembre de 2025
**Backend:** Spring Boot 3.5.7 + PostgreSQL 18.0 + Stripe API
**Estado:** ✅ Completamente funcional y documentado
