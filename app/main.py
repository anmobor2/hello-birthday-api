from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import logging
from app.api import hello
from app.database import init_db
from app.config import get_settings

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

# Obtener configuración
settings = get_settings()

# Crear la aplicación FastAPI
app = FastAPI(
    title=settings.APP_NAME,
    description="API Hello Birthday - Una API simple para guardar y consultar cumpleaños",
    version="1.0.0",
)

# Manejador de excepciones global
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Error no manejado: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "Se ha producido un error interno en el servidor."},
    )

# Incluir rutas
app.include_router(hello.router, tags=["hello"])

# Evento de inicio
@app.on_event("startup")
async def startup_event():
    logger.info(f"Iniciando aplicación en entorno: {settings.ENVIRONMENT}")
    init_db()
    logger.info("Base de datos inicializada")

# Evento de cierre
@app.on_event("shutdown")
async def shutdown_event():
    logger.info("Cerrando aplicación")

# Ruta de healthcheck
@app.get("/health", tags=["health"])
async def health_check():
    return {"status": "OK"}

# Para ejecutar localmente con uvicorn
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)