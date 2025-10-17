# 1. Usar una imagen base oficial de Python
FROM python:3.10-slim

# 2. Instalar las dependencias del sistema, incluyendo Google Chrome (MÉTODO CORREGIDO)
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    && mkdir -p /etc/apt/keyrings/ \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# 3. Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

# 4. Copiar el archivo de requerimientos e instalar las librerías de Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copiar todo el código de nuestra aplicación al contenedor
COPY . .

# 6. Exponer el puerto que nuestra aplicación usará
EXPOSE 8080

# 7. El comando para iniciar nuestra aplicación (FORMA CORREGIDA)
# Usamos la "forma de shell" (sin corchetes) para que la variable $PORT sea interpretada.
CMD gunicorn --bind 0.0.0.0:$PORT app:app