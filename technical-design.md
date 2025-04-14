# Hello Birthday API: Technical Design Document

## 1. Architecture Overview

The Hello Birthday API is built using a clean architecture approach, separating concerns into distinct layers:

```
┌────────────────┐      ┌────────────────┐      ┌────────────────┐
│                │      │                │      │                │
│  Presentation  │──────▶    Business    │──────▶     Data       │
│     Layer      │      │     Layer      │      │     Layer      │
│                │◀─────│                │◀─────│                │
└────────────────┘      └────────────────┘      └────────────────┘
```

### Layers

1. **Presentation Layer**
   - FastAPI routes and controllers
   - Request/response handling
   - Input validation

2. **Business Layer**
   - Date calculation service
   - Business rules and validation

3. **Data Layer**
   - Database models and schemas
   - Database access and persistence

## 2. Component Design

### 2.1 Database Schema

```
┌─────────────────────┐
│       users         │
├─────────────────────┤
│ username (PK)       │
│ date_of_birth       │
└─────────────────────┘
```

SQLAlchemy ORM is used to interact with the database. The User model maps to the 'users' table.

### 2.2 API Routes

| Method | Endpoint        | Description                     |
|--------|----------------|---------------------------------|
| PUT    | /hello/{username} | Create/update user birthday    |
| GET    | /hello/{username} | Get user birthday message      |
| GET    | /health        | Health check endpoint           |

### 2.3 Services

The DateService contains the core business logic for calculating days until birthday:

```python
def calculate_days_until_birthday(birth_date, reference_date) -> (bool, int):
    """
    Calculate days until next birthday from reference date
    Returns (is_today, days_until)
    """
```

## 3. Data Validation

Pydantic is used for request/response validation:

1. **UserCreate** - Validates the PUT request body:
   - dateOfBirth: Must be a valid date format (YYYY-MM-DD)
   - dateOfBirth: Must be a date in the past

2. **Username Validation**:
   - Must contain only letters (a-z, A-Z)
   - Performed using regex pattern matching

## 4. Design Decisions

### 4.1 Clean Architecture

The application follows clean architecture principles to ensure:
- Separation of concerns
- Testability
- Maintainability
- Dependency inversion

### 4.2 Database Choice

SQLite is used for development simplicity, but the design supports any SQL database through SQLAlchemy's ORM layer. This allows for easy migration to PostgreSQL, MySQL, or other databases in production.

### 4.3 Error Handling

A consistent error handling approach is implemented:
- HTTP status codes align with REST best practices
- Error responses follow a standardized format
- Validation errors provide clear guidance on how to correct issues

### 4.4 Dependency Injection

FastAPI's dependency injection system is used to:
- Manage database connections
- Ensure proper resource cleanup
- Facilitate testing through mocking

```python
@app.get("/hello/{username}")
async def get_birthday_message(
    username: str,
    db: Session = Depends(get_db)  # Dependency injection
):
```

### 4.5 Configuration Management

Environment-specific configuration is handled through Pydantic's BaseSettings:

```python
class Settings(BaseSettings):
    APP_NAME: str = "hello-api"
    ENVIRONMENT: EnvironmentType = EnvironmentType.DEV
    DATABASE_URL: str = "sqlite:///./hello-api.db"
    
    class Config:
        env_file = ".env"
```

This allows for easy configuration through environment variables or .env files.

## 5. Leap Year Handling

The application correctly handles leap years in birthday calculations:

1. A dedicated method `is_leap_year(year)` determines if a given year is a leap year
2. For February 29 birthdays in non-leap years, the birthday is considered to be March 1
3. The calculation accounts for different month lengths when determining days until birthday

## 6. Performance Considerations

### 6.1 Database Optimization

- SQL indexes on username (primary key)
- Connection pooling for efficient database access
- Proper session management to avoid connection leaks

### 6.2 Request Processing

- Validation is performed early to fail fast on invalid requests
- Database queries are optimized to fetch only required data
- Async handlers are used to maximize throughput

## 7. Scalability

The application is designed to be horizontally scalable:

1. **Stateless Design**: No server-side session state
2. **Database Scalability**: Support for database clustering and replication
3. **Container-Ready**: Can be packaged and deployed in containers

## 8. Testing Strategy

The testing approach covers multiple levels:

1. **Unit Tests**:
   - Test individual components in isolation
   - Mock external dependencies
   - Focus on business logic and edge cases

2. **Integration Tests**:
   - Test interactions between components
   - Use test database for data persistence

3. **API Tests**:
   - Test the API endpoints
   - Validate request/response formats
   - Check error handling

## 9. Security Considerations

The API implements several security best practices:

1. **Input Validation**: All user inputs are strictly validated
2. **Parameter Binding**: SQL injection is prevented through ORM parameter binding
3. **Error Handling**: Errors reveal minimal information about the system

## 10. Monitoring and Logging

The application includes:

1. **Health Check Endpoint**: For monitoring service availability
2. **Structured Logging**: For tracking application events
3. **Error Tracking**: For capturing and reporting exceptions

## 11. Future Improvements

Potential enhancements for future versions:

1. **Caching**: Implement response caching for frequently accessed resources
2. **Rate Limiting**: Add rate limiting to prevent abuse
3. **Authentication**: Add optional authentication for private deployments
4. **Metrics**: Expose metrics endpoint for Prometheus integration
5. **Expanded API**: Add additional birthday-related functionality
