# ==============================================================================
# Fase 1: Imagen Base
# ==============================================================================
FROM python:3.10-slim

# ==============================================================================
# Fase 2: Instalación de Dependencias del Sistema (Google Chrome)
# ==============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    && mkdir -p /etc/apt/keyrings/ \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable

# ==============================================================================
# Fase 2.5: Instalar LIBRERÍAS ADICIONALES para que Chrome funcione
# ESTA ES LA SOLUCIÓN AL ERROR 127
# ==============================================================================
RUN apt-get install -y --no-install-recommends \
    libglib2.0-0 \
    libnss3 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libgtk-3-0 \
    libx11-xcb1 \
    libdbus-glib-1-2 \
    libxtst6 \
    libxt6 \
    libxss1 \
    libxrandr2 \
    # Limpieza final para reducir el tamaño de la imagen
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# Fase 3: Configuración del Entorno de la Aplicación
# ==============================================================================
WORKDIR /app

# ==============================================================================
# Fase 4: Instalación de Dependencias de Python
# ==============================================================================
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ==============================================================================
# Fase 5: Copia del Código de la Aplicación
# ==============================================================================
COPY . .

# ==============================================================================
# Fase 6: Comando de Inicio
# ==============================================================================
CMD gunicorn --bind 0.0.0.0:$PORT app:app