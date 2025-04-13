import pytest
from datetime import date, timedelta
from fastapi import status


class TestHelloAPI:
    def test_health_check(self, client):
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json() == {"status": "OK"}

    def test_update_user_new(self, client, db_session):
        # Probar la creación de un nuevo usuario
        response = client.put(
            "/hello/john",
            json={"dateOfBirth": "1990-01-15"}
        )

        assert response.status_code == 204

        # Verificar que el usuario fue creado en la base de datos
        from app.models.user import User
        user = db_session.query(User).filter(User.username == "john").first()
        assert user is not None
        assert user.date_of_birth == date(1990, 1, 15)

    def test_update_user_existing(self, client, sample_user, db_session):
        # Probar la actualización de un usuario existente
        response = client.put(
            f"/hello/{sample_user.username}",
            json={"dateOfBirth": "1995-05-20"}
        )

        assert response.status_code == 204

        # Verificar que el usuario fue actualizado en la base de datos
        db_session.refresh(sample_user)
        assert sample_user.date_of_birth == date(1995, 5, 20)

    def test_update_user_invalid_username(self, client):
        # Probar nombre de usuario inválido (con números)
        response = client.put(
            "/hello/john123",
            json={"dateOfBirth": "1990-01-15"}
        )

        assert response.status_code == 400
        assert "El nombre de usuario debe contener solo letras" in response.json()["detail"]

    def test_update_user_future_date(self, client):
        # Probar fecha de nacimiento en el futuro
        tomorrow = date.today() + timedelta(days=1)
        response = client.put(
            "/hello/john",
            json={"dateOfBirth": tomorrow.isoformat()}
        )

        assert response.status_code == 422  # Validación de Pydantic

    def test_get_birthday_message_today(self, client, db_session):
        # Crear un usuario con cumpleaños hoy
        today = date.today()
        from app.models.user import User
        user = User(username="birthdayuser", date_of_birth=date(1990, today.month, today.day))
        db_session.add(user)
        db_session.commit()

        # Obtener el mensaje de cumpleaños
        response = client.get("/hello/birthdayuser")

        assert response.status_code == 200
        assert response.json() == {"message": "Hello, birthdayuser! Happy birthday!"}

    def test_get_birthday_message_future(self, client, db_session):
        # Crear un usuario con cumpleaños en 5 días
        today = date.today()
        future_date = today + timedelta(days=5)

        # Si el mes cambia, ajustar
        if future_date.month != today.month:
            # Usar el primer día del siguiente mes
            future_date = date(today.year, today.month + 1, 1)

        from app.models.user import User
        user = User(username="futureuser", date_of_birth=date(1990, future_date.month, future_date.day))
        db_session.add(user)
        db_session.commit()

        # Obtener el mensaje de cumpleaños
        response = client.get("/hello/futureuser")

        assert response.status_code == 200
        assert response.json() == {"message": "Hello, futureuser! Your birthday is in 5 day(s)"}

    def test_get_birthday_message_not_found(self, client):
        # Intentar obtener el mensaje para un usuario que no existe
        response = client.get("/hello/nonexistent")

        assert response.status_code == 404
        assert "no encontrado" in response.json()["detail"]