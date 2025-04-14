import os
import pytest
from datetime import date  # Añadir esta importación
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from datetime import date

from app.main import app
from app.database import Base, get_db
from app.models.user import User

# Establecer el entorno de prueba
os.environ["APP_ENVIRONMENT"] = "test"

# Crear una conexión a la base de datos en memoria
TEST_SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine = create_engine(
    TEST_SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)

TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture
def db_session():
    # Crear las tablas en la base de datos de prueba
    Base.metadata.create_all(bind=engine)

    # Crear una nueva sesión para los tests
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()
        # Limpiar la base de datos después de cada test
        Base.metadata.drop_all(bind=engine)


@pytest.fixture
def client(db_session):
    # Reemplazar la dependencia de obtener DB en la app
    def override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db

    # Crear un cliente de prueba
    with TestClient(app) as c:
        yield c

    # Restaurar la dependencia original
    app.dependency_overrides.clear()


@pytest.fixture
def sample_user(db_session):
    # Crear un usuario de ejemplo
    user = User(username="testuser", date_of_birth=date(1990, 1, 15))  # Usar objeto date
    db_session.add(user)
    db_session.commit()
    return user