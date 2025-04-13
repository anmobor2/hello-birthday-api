from fastapi import APIRouter, Depends, HTTPException, status, Path
from sqlalchemy.orm import Session
from typing import Dict

from app.database import get_db
from app.models.user import User, UserCreate, validate_username
from app.services.date_service import DateService

router = APIRouter()


@router.put("/hello/{username}", status_code=status.HTTP_204_NO_CONTENT)
async def update_user(
        username: str = Path(..., description="Nombre de usuario (solo letras)"),
        user_data: UserCreate = None,
        db: Session = Depends(get_db)
):
    """
    Guarda o actualiza la fecha de nacimiento de un usuario.

    - username: Debe contener solo letras
    - dateOfBirth: Debe ser una fecha en formato YYYY-MM-DD anterior a hoy
    """
    # Validar el nombre de usuario
    if not validate_username(username):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El nombre de usuario debe contener solo letras"
        )

    # Verificar si el usuario ya existe
    db_user = db.query(User).filter(User.username == username).first()

    if db_user:
        # Actualizar usuario existente
        db_user.date_of_birth = user_data.dateOfBirth
    else:
        # Crear nuevo usuario
        db_user = User(username=username, date_of_birth=user_data.dateOfBirth)
        db.add(db_user)

    db.commit()
    db.refresh(db_user)
    return None  # Retorna 204 No Content


@router.get("/hello/{username}", response_model=Dict[str, str])
async def get_birthday_message(
        username: str = Path(..., description="Nombre de usuario"),
        db: Session = Depends(get_db)
):
    """
    Retorna un mensaje de cumpleaños para el usuario.

    - Si el cumpleaños es hoy: "Hello, <username>! Happy birthday!"
    - Si no es hoy: "Hello, <username>! Your birthday is in N day(s)"
    """
    # Validar el nombre de usuario
    if not validate_username(username):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El nombre de usuario debe contener solo letras"
        )

    # Buscar el usuario en la base de datos
    db_user = db.query(User).filter(User.username == username).first()

    if db_user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Usuario '{username}' no encontrado"
        )

    # Calcular los días restantes hasta el cumpleaños
    is_birthday_today, days_until_birthday = DateService.calculate_days_until_birthday(db_user.date_of_birth)

    # Crear el mensaje apropiado
    if is_birthday_today:
        message = f"Hello, {username}! Happy birthday!"
    else:
        message = f"Hello, {username}! Your birthday is in {days_until_birthday} day(s)"

    return {"message": message}