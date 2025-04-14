from sqlalchemy import Column, String, Date
from app.database import Base
from datetime import date
from pydantic import BaseModel, Field, validator
import re

class User(Base):
    """Modelo SQLAlchemy para la tabla de usuarios en la base de datos."""
    __tablename__ = "users"

    username = Column(String, primary_key=True, index=True)
    date_of_birth = Column(Date)

class UserCreate(BaseModel):
    """Esquema Pydantic para validar los datos de entrada al crear un usuario."""
    dateOfBirth: date = Field(..., description="Fecha de nacimiento en formato YYYY-MM-DD")

    @validator('dateOfBirth')
    def date_must_be_in_past(cls, v):
        if v >= date.today():
            raise ValueError('La fecha de nacimiento debe ser anterior a la fecha actual')
        return v

def validate_username(username: str) -> bool:
    """Validar que el nombre de usuario solo contenga letras."""
    return bool(re.match(r'^[a-zA-Z]+$', username))