# Base Python image
FROM python:3.11-slim AS base

# Establecer variables de entorno
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

# Establecer directorio de trabajo
WORKDIR /app

# Etapa de compilación
FROM base AS builder

# Instalar dependencias para compilación
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Instalar poetry
RUN pip install --no-cache-dir poetry

# Copiar los archivos de dependencias
COPY requirements.txt .

# Instalar dependencias
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt

# Etapa final
FROM base

# Crear usuario no root
RUN addgroup --system app && adduser --system --ingroup app app

# Copiar las ruedas Python y los requirements desde la etapa de compilación
COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .

# Instalar las dependencias
RUN pip install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt \
    && rm -rf /wheels

# Copiar el código de la aplicación
COPY ./app /app/app

# Cambiar propiedad de los archivos de la aplicación al usuario no root
RUN chown -R app:app /app

# Cambiar al usuario no root
USER app

# Definir punto de entrada
ENTRYPOINT ["uvicorn", "app.main:app"]

# Comando por defecto
CMD ["--host", "0.0.0.0", "--port", "8000"]

# Metadatos de la imagen
LABEL org.opencontainers.image.title="Hello API" \
      org.opencontainers.image.description="API Hello Birthday"