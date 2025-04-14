import os
from pydantic_settings import BaseSettings
from enum import Enum


class EnvironmentType(str, Enum):
    DEV = "development"
    TEST = "test"
    PROD = "production"

class Settings(BaseSettings):
    APP_NAME: str = "hello-api"
    ENVIRONMENT: EnvironmentType = EnvironmentType.DEV

    # Configuración de base de datos
    DATABASE_URL: str = "sqlite:///./hello-api.db"

    # Test environment, it uses an in-memory SQLite database
    @property
    def db_url(self) -> str:
        if self.ENVIRONMENT == EnvironmentType.TEST:
            return "sqlite:///:memory:"
        return self.DATABASE_URL

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


def get_settings() -> Settings:
    env = os.getenv("APP_ENVIRONMENT", "development")
    return Settings(ENVIRONMENT=env)