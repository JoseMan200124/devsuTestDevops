# Imagen base ligera de Python
FROM python:3.12-slim AS base

# No generar .pyc y logueo sin buffer
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# Dependencias de sistema mínimas
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copiamos sólo requirements primero para aprovechar la cache de Docker
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copiamos el resto del código
COPY . .

# Creamos un usuario no-root para buenas prácticas
RUN useradd -m appuser
USER appuser

# Variables por defecto (en K8s las sobreescribimos con ConfigMap/Secret)
ENV DJANGO_SETTINGS_MODULE=demo.settings \
    PORT=8000

EXPOSE 8000

# Healthcheck a nivel de contenedor
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8000/health/ || exit 1

# Comando de arranque usando gunicorn (producción)
CMD ["gunicorn", "demo.wsgi:application", "--bind", "0.0.0.0:8000"]
