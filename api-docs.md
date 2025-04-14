# Hello Birthday API Documentation

## Overview

The Hello Birthday API is a RESTful service that manages user birthdays and provides personalized birthday messages. This document provides detailed information on how to use the API, including request/response formats, error handling, and examples.

## Base URL

When running locally, the base URL is:
```
http://localhost:8000
```

## Authentication

This API does not require authentication.

## API Endpoints

### 1. Save or Update User Birthday

Stores a user's name and date of birth in the database.

**Endpoint:** `PUT /hello/{username}`

**Path Parameters:**
| Parameter | Type   | Required | Description                                    |
|-----------|--------|----------|------------------------------------------------|
| username  | string | Yes      | User's name (must contain only letters a-z, A-Z) |

**Request Body:**
```json
{
  "dateOfBirth": "YYYY-MM-DD"
}
```

**Request Body Parameters:**
| Parameter   | Type   | Required | Description                                    |
|-------------|--------|----------|------------------------------------------------|
| dateOfBirth | string | Yes      | User's date of birth in ISO format (YYYY-MM-DD). Must be a date in the past. |

**Response Status Codes:**
| Status Code | Description             | Condition                                |
|-------------|-------------------------|------------------------------------------|
| 204         | No Content              | User created/updated successfully        |
| 400         | Bad Request             | Invalid username format                  |
| 422         | Unprocessable Entity    | Invalid date format or date is not in the past |

**Example Request:**
```bash
curl -X PUT http://localhost:8000/hello/john \
  -H "Content-Type: application/json" \
  -d '{"dateOfBirth": "1990-05-15"}'
```

**Example Response:**
```
204 No Content
```

### 2. Get Birthday Message

Returns a personalized birthday message for a user.

**Endpoint:** `GET /hello/{username}`

**Path Parameters:**
| Parameter | Type   | Required | Description                                    |
|-----------|--------|----------|------------------------------------------------|
| username  | string | Yes      | User's name (must contain only letters a-z, A-Z) |

**Response Status Codes:**
| Status Code | Description             | Condition                                |
|-------------|-------------------------|------------------------------------------|
| 200         | OK                      | Success                                  |
| 400         | Bad Request             | Invalid username format                  |
| 404         | Not Found               | User not found                           |

**Response Body:**
```json
{
  "message": "string"
}
```

**Response Body Parameters:**
| Parameter | Type   | Description                                    |
|-----------|--------|------------------------------------------------|
| message   | string | Birthday message for the user                  |

**Example Request:**
```bash
curl http://localhost:8000/hello/john
```

**Example Response (Birthday is in the future):**
```json
{
  "message": "Hello, john! Your birthday is in 42 day(s)"
}
```

**Example Response (Birthday is today):**
```json
{
  "message": "Hello, john! Happy birthday!"
}
```

## Error Handling

### Error Responses

The API returns appropriate HTTP status codes and error messages for different error conditions:

**Example (Invalid Username):**
```json
{
  "detail": "El nombre de usuario debe contener solo letras"
}
```

**Example (User Not Found):**
```json
{
  "detail": "Usuario 'username' no encontrado"
}
```

**Example (Date in the Future):**
```json
{
  "detail": [
    {
      "loc": ["body", "dateOfBirth"],
      "msg": "La fecha de nacimiento debe ser anterior a la fecha actual",
      "type": "value_error"
    }
  ]
}
```

## Date Handling

### Birthday Calculation Logic

The API implements the following logic to calculate the number of days until the next birthday:

1. If the birthday is today, a special "Happy birthday!" message is returned
2. If the birthday is in the future this year, it calculates the days until that date
3. If the birthday has already passed this year, it calculates the days until the same date next year
4. Leap years are properly handled, including for February 29th birthdates

## Health Check

The API includes a health check endpoint to verify the service is up and running.

**Endpoint:** `GET /health`

**Example Request:**
```bash
curl http://localhost:8000/health
```

**Example Response:**
```json
{
  "status": "OK"
}
```

## API Rate Limiting

This API does not implement rate limiting in the current version.

## Versioning

This documentation applies to API version 1.0.0.

## Additional Resources

- Interactive API documentation: `/docs` (Swagger UI)
- Alternative API documentation: `/redoc` (ReDoc)
