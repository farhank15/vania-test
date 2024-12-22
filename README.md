# Documentation Rest API

#

## ===> Authentication <===

### Create Users

Method : Post

```bash
http://127.0.0.1:8000/api/v1/users
```

Body :

```js
{
  "name" : "John Doe",
  "username":"JohnDoe",
  "email": "JohnDoe@example.com",
  "password": "@Password123"
}
```

### Get All Users

Method : Get

```bash
http://127.0.0.1:8000/api/v1/users
```

### Get Users By Id

Method : Get

```bash
http://127.0.0.1:8000/api/v1/users/{id}
```

### Update Users

Method : Put

```bash
http://127.0.0.1:8000/api/v1/users/{id}
```

Body :

```js
{
  "name" : "John Doe1",
  "username":"JohnDoe1",
  "email": "JohnDoe1@example.com",
  "password": "@Password123"
}
```

### Delete Users

Method : Delete

```bash
http://127.0.0.1:8000/api/v1/users/{id}
```

### Login Users

Method : Post

```bash
http://127.0.0.1:8000/api/v1/users/login
```

```js
{
  "identifier":"John2", // email or username
  "password": "@Password123",
}
```

#

## ===> Customers <===

### Create Customers

Method : Post

```bash
http://127.0.0.1:8000/api/v1/customers
```

Body :

```js
{
    "cust_name": "John h",
    "cust_address": "123 Elm Street",
    "cust_city": "New York",
    "cust_state": "NY",
    "cust_zip": "10001",
    "cust_country": "Indonesia",
    "cust_telp": "1234567890"
}
```

### Get All Customers

Method : Get

```bash
http://127.0.0.1:8000/api/v1/customers
```

### Get Customers By Id

Method : Get

```bash
http://127.0.0.1:8000/api/v1/customers/{id}
```

### Update Customers

Method : Put

```bash
http://127.0.0.1:8000/api/v1/customers/{id}
```

Body :

```js
{
    "cust_name": "John h",
    "cust_address": "123 Elm Street",
    "cust_city": "New York",
    "cust_state": "NY",
    "cust_zip": "10001",
    "cust_country": "Indonesia",
    "cust_telp": "1234567890"
}
```

### Delete Customers

Method : Delete

```bash
http://127.0.0.1:8000/api/v1/customers/{id}
```

#

## ===> Orders <===

### Create Orders

Method : Post

```bash
http://127.0.0.1:8000/api/v1/orders
```

Body :

```js
{
  "order_date": "2024-12-21T00:00:00Z",
  "cust_id": 1
}
```

### Get All Orders

Method : Get

```bash
http://127.0.0.1:8000/api/v1/orders
```

### Get Orders By Id

Method : Get

```bash
http://127.0.0.1:8000/api/v1/orders/{id}
```

### Update Orders

Method : Put

```bash
http://127.0.0.1:8000/api/v1/orders{id}
```

Body :

```js
{
  "order_date": "2024-12-21T00:00:00Z",
  "cust_id": 1
}
```

### Delete Orders

Method : Delete

```bash
http://127.0.0.1:8000/api/v1/orders/{id}
```

#

## ===> Vendors <===

### Create Vendors

Method : Post

```bash
http://127.0.0.1:8000/api/v1/vendors
```

Body :

```js
{
  "vend_name": "Vendor ABC",
  "vend_address": "Jl. Raya No. 123",
  "vend_kota": "Jakarta",
  "vend_state": "JKT",
  "vend_zip": "12345",
  "vend_country": "Indonesia"
}
```

### Get All Vendors

Method : Get

```bash
http://127.0.0.1:8000/api/v1/vendors
```

### Get Vendors By Id

Method : Get

```bash
http://127.0.0.1:8000/api/v1/orders/{id}
```

### Update Vendors

Method : Put

```bash
http://127.0.0.1:8000/api/v1/vendors/{id}
```

Body :

```js
{
  "vend_name": "Vendor XYZ",
  "vend_address": "Jl. Baru No. 456",
  "vend_kota": "Bandung",
  "vend_state": "BDG",
  "vend_zip": "67890",
  "vend_country": "Indonesia"
}
```

### Delete Vendors

Method : Delete

```bash
http://127.0.0.1:8000/api/v1/orders/{id}
```
