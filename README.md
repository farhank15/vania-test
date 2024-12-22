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
