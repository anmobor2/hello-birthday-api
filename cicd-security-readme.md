# Security Scanning in CI/CD Pipeline

Este documento describe las herramientas de seguridad integradas en el pipeline de CI/CD para la aplicación Hello API, su configuración y cómo interpretar los resultados.

## Herramientas Integradas

El pipeline implementa múltiples capas de análisis de seguridad:

### 1. SonarQube / SonarCloud

**Propósito**: Análisis estático de código para detectar problemas de calidad y seguridad.

**Configuración**:
- Integrado en el pipeline a través de `sonar-buildspec.yml`
- Configurado para analizar el código Python
- Incluye análisis de cobertura de código

**Resultados**:
- Panel de control en SonarCloud: https://sonarcloud.io/dashboard?id=your-organization_hello-api
- Detección de "code smells", vulnerabilidades y bugs
- Aplicación de reglas OWASP Top 10

### 2. Bandit

**Propósito**: Analizador estático específico para Python que encuentra problemas de seguridad comunes.

**Configuración**:
- Ejecutado dentro del job de seguridad
- Analiza todo el código en el directorio `/app`
- Genera un informe JSON para revisión

**Resultados**:
- Detecta problemas como inyecciones SQL, contraseñas hard-coded, etc.
- Clasifica los problemas por severidad (HIGH, MEDIUM, LOW)

### 3. Safety

**Propósito**: Verifica las dependencias Python contra una base de datos de vulnerabilidades conocidas.

**Configuración**:
- Analiza los archivos `requirements.txt`
- Genera un informe JSON detallado

**Resultados**:
- Identifica dependencias con vulnerabilidades conocidas
- Proporciona recomendaciones para actualizar a versiones seguras

### 4. Trivy

**Propósito**: Escáner de vulnerabilidades para contenedores y sistemas de archivos.

**Configuración**:
- Escanea la imagen Docker construida
- Configurado para detectar vulnerabilidades CRÍTICAS y ALTAS
- Genera informe en formato SARIF y JSON

**Resultados**:
- Identifica vulnerabilidades en el sistema operativo base
- Detecta problemas en paquetes y dependencias
- Proporciona información sobre CVEs específicos

### 5. OWASP ZAP

**Propósito**: Prueba de seguridad dinámica (DAST) para encontrar vulnerabilidades en la aplicación en ejecución.

**Configuración**:
- Ejecuta un escaneo básico contra la aplicación
- Configurado con reglas de exclusión en `.zap/rules.tsv`
- Genera un informe HTML para revisión

**Resultados**:
- Identifica problemas como XSS, CSRF, etc.
- Prueba la seguridad de la API en tiempo de ejecución

## Gestión de Resultados

### Política de Fallos

Por defecto, el pipeline está configurado con las siguientes políticas:

1. **Entorno de Desarrollo (dev)**:
   - Alertas de problemas de seguridad, pero no bloquea el despliegue
   - Todos los resultados se guardan como artefactos para revisión

2. **Entorno de Pre-producción (pre)**:
   - Fallos CRÍTICOS bloquean el despliegue
   - Resultados de severidad ALTA generan alertas

3. **Entorno de Producción (pro)**:
   - Cualquier problema de seguridad de severidad ALTA o CRÍTICA bloquea el despliegue
   - Requiere revisión manual y aprobación

### Revisión de Resultados

Los resultados de los escaneos se almacenan como artefactos en cada ejecución del pipeline:

- **GitHub Actions**: Disponibles en la pestaña "Artifacts" de la ejecución del workflow
- **AWS CodePipeline**: Almacenados en el bucket S3 configurado para artefactos

## Configuración Personalizada

### SonarQube

Puedes personalizar el análisis editando el archivo `sonar-buildspec.yml`:

```yaml
sonar-scanner \
  -Dsonar.projectKey=hello-api \
  -Dsonar.organization=your-organization \
  # Añadir o modificar parámetros aquí
```

### OWASP ZAP

Puedes excluir reglas específicas editando el archivo `.zap/rules.tsv`:

```
10096	IGNORE	Timestamp Disclosure
# Añadir reglas adicionales para ignorar
```

### Trivy

Para modificar la configuración de Trivy, edita los parámetros en `security-buildspec.yml`:

```yaml
trivy image --format json --severity HIGH,CRITICAL --output trivy-results.json
```

## Mejores Prácticas

1. **Revisar resultados regularmente**: No esperes a un despliegue en producción para revisar los problemas de seguridad.

2. **Actualizar dependencias**: Programa actualizaciones regulares de dependencias para corregir vulnerabilidades.

3. **Añadir pruebas para vulnerabilidades**: Cuando se identifica una vulnerabilidad, añade una prueba para asegurarte de que no vuelva a aparecer.

4. **Personalizar umbrales por entorno**: Ajusta la severidad de los fallos según el entorno, siendo más estricto en producción.

5. **Implementar escaneos programados**: Considera ejecutar escaneos de seguridad periódicos incluso sin cambios en el código.

## Recursos Adicionales

- [Documentación de SonarQube](https://docs.sonarqube.org/)
- [Documentación de Bandit](https://bandit.readthedocs.io/)
- [Documentación de Trivy](https://aquasecurity.github.io/trivy/)
- [Documentación de OWASP ZAP](https://www.zaproxy.org/docs/)
