#!/bin/bash
set -e

# Script para realizar un despliegue sin tiempo de inactividad

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Variables
IMAGE_NAME="hello-api"
AWS_ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"
CLUSTER_NAME="hello-api-cluster"
SERVICE_NAME="hello-api-service"
VERSION=$(cat version.json | jq -r '.version')

echo -e "${YELLOW}Iniciando despliegue para ${IMAGE_NAME}:${VERSION} en el servicio ${SERVICE_NAME}${NC}"

# Obtener la definición actual de la tarea
echo -e "${YELLOW}Obteniendo definición de tarea actual...${NC}"
TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition ${SERVICE_NAME} --region ${AWS_REGION})
TASK_DEFINITION_ARN=$(echo $TASK_DEFINITION | jq -r '.taskDefinition.taskDefinitionArn')

# Crear nueva definición de tarea con la nueva imagen
echo -e "${YELLOW}Creando nueva definición de tarea...${NC}"
NEW_TASK_DEFINITION=$(echo $TASK_DEFINITION | jq --arg IMAGE "${AWS_ECR_REPO}:${VERSION}" \
    '.taskDefinition.containerDefinitions[0].image = $IMAGE | .taskDefinition')

# Registrar la nueva definición de tarea
echo -e "${YELLOW}Registrando nueva definición de tarea...${NC}"
NEW_TASK_INFO=$(aws ecs register-task-definition --region ${AWS_REGION} \
    --family ${SERVICE_NAME} \
    --container-definitions "$(echo $NEW_TASK_DEFINITION | jq -c '.containerDefinitions')" \
    --task-role-arn "$(echo $NEW_TASK_DEFINITION | jq -r '.taskRoleArn')" \
    --execution-role-arn "$(echo $NEW_TASK_DEFINITION | jq -r '.executionRoleArn')" \
    --network-mode "$(echo $NEW_TASK_DEFINITION | jq -r '.networkMode')" \
    --volumes "$(echo $NEW_TASK_DEFINITION | jq -c '.volumes')" \
    --placement-constraints "$(echo $NEW_TASK_DEFINITION | jq -c '.placementConstraints')")

NEW_TASK_DEFINITION_ARN=$(echo $NEW_TASK_INFO | jq -r '.taskDefinition.taskDefinitionArn')

# Actualizar el servicio con la nueva definición de tarea
echo -e "${YELLOW}Actualizando servicio con la nueva definición de tarea...${NC}"
UPDATE_SERVICE_RESULT=$(aws ecs update-service --cluster ${CLUSTER_NAME} \
    --service ${SERVICE_NAME} \
    --task-definition ${NEW_TASK_DEFINITION_ARN} \
    --region ${AWS_REGION})

# Esperar a que el servicio alcance un estado estable
echo -e "${YELLOW}Esperando a que el servicio alcance un estado estable...${NC}"
aws ecs wait services-stable --cluster ${CLUSTER_NAME} \
    --services ${SERVICE_NAME} \
    --region ${AWS_REGION}

# Verificar que el despliegue se haya completado correctamente
echo -e "${YELLOW}Verificando estado del despliegue...${NC}"
DEPLOYMENT_STATUS=$(aws ecs describe-services --cluster ${CLUSTER_NAME} \
    --services ${SERVICE_NAME} \
    --region ${AWS_REGION} | \
    jq -r '.services[0].deployments[] | select(.status == "PRIMARY") | .rolloutState')

if [ "$DEPLOYMENT_STATUS" == "COMPLETED" ]; then
    echo -e "${GREEN}Despliegue completado exitosamente.${NC}"
else
    echo -e "${RED}Despliegue no completado correctamente. Estado: ${DEPLOYMENT_STATUS}${NC}"
    exit 1
fi

# Registro del despliegue exitoso
echo -e "${GREEN}Despliegue de ${IMAGE_NAME}:${VERSION} completado en ${SERVICE_NAME}.${NC}"
echo "Despliegue exitoso: ${IMAGE_NAME}:${VERSION} en ${SERVICE_NAME} a las $(date)" >> deploy_history.log