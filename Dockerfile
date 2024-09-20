# Utiliser l'image de base FastAPI
#FROM tiangolo/uvicorn-gunicorn-fastapi:python3.9

# Définir le répertoire de travail
#WORKDIR /app

# Copier tout le contenu du répertoire dans /app
#COPY . /app

# Installer les dépendances
#RUN pip install --no-cache-dir firebase-admin pydantic

# Exposer le port 8001
#EXPOSE 8001

# Copier le fichier .env si nécessaire
#COPY .env /app

# Définir les variables d'environnement à partir du fichier .env
#ENV ENV_FILE_LOCATION=/app/.env

FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Install FastAPI and Uvicorn
RUN pip install --no-cache-dir fastapi uvicorn

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME World

# Run app.py when the container launches
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
