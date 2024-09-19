# Utiliser l'image de base FastAPI
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.9

# Définir le répertoire de travail
WORKDIR /app

# Copier tout le contenu du répertoire dans /app
COPY . /app

# Installer les dépendances
RUN pip install --no-cache-dir firebase-admin pydantic

# Exposer le port 8001
EXPOSE 8001

# Copier le fichier .env si nécessaire
#COPY .env /app

# Définir les variables d'environnement à partir du fichier .env
ENV ENV_FILE_LOCATION=/app/.env

