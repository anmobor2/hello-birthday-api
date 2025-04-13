#!/bin/bash
set -e

# Script para construir y subir la imagen Docker de la aplicación

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Variables
IMAGE_NAME="hello-api"
AWS_ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"
VERSION=$(date +%Y%m%d%H%M%S)
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "development")

echo -e "${YELLOW}Iniciando proceso de construcción para ${IMAGE_NAME}:${VERSION}${NC}"

# Ejecutar pruebas unitarias
echo -e "${YELLOW}Ejecutando pruebas...${NC}"
pytest -v

# Si las pruebas fallan, detener el script
if [ $? -ne 0 ]; then
    echo -e "${RED}Las pruebas fallaron. Abortando el proceso de construcción.${NC}"
    exit 1
fi

echo -e "${GREEN}Las pruebas pasaron correctamente.${NC}"

# Construir la imagen Docker
echo -e "${YELLOW}Construyendo imagen Docker...${NC}"
docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest -f docker/Dockerfile .

# Hacer login en AWS ECR
echo -e "${YELLOW}Iniciando sesión en AWS ECR...${NC}"
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Etiquetar la imagen para ECR
echo -e "${YELLOW}Etiquetando imagen para ECR...${NC}"
docker tag ${IMAGE_NAME}:${VERSION} ${AWS_ECR_REPO}:${VERSION}
docker tag ${IMAGE_NAME}:${VERSION} ${AWS_ECR_REPO}:latest

# Subir la imagen a ECR
echo -e "${YELLOW}Subiendo imagen a ECR...${NC}"
docker push ${AWS_ECR_REPO}:${VERSION}
docker push ${AWS_ECR_REPO}:latest

echo -e "${GREEN}Imagen construida y subida exitosamente:${NC}"
echo -e "${GREEN}${AWS_ECR_REPO}:${VERSION}${NC}"
echo -e "${GREEN}${AWS_ECR_REPO}:latest${NC}"

# Crear archivo de versión para el despliegue
echo "{\"version\": \"${VERSION}\", \"commit\": \"${COMMIT_HASH}\", \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"}" > version.json

echo -e "${GREEN}Proceso de construcción completado exitosamente.${NC}"