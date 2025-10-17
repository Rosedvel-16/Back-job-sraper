# ==============================================================================
# Fase 1: Imagen Base
# ==============================================================================
FROM python:3.10-slim

# ==============================================================================
# Fase 2: Instalación de TODO en un solo paso (Más eficiente)
# ==============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Herramientas necesarias para añadir el repositorio de Chrome
    wget \
    gnupg \
    # --- LISTA DE LIBRERÍAS ACTUALIZADA Y CORRECTA ---
    libnss3 \
    libdbus-glib-1-2 \
    libgtk-3-0 \
    libx11-xcb1 \
    libasound2 \
    libxtst6 \
    libxss1 \
    libfontconfig1 \
    libdbus-1-3 \
    # Proceso para instalar Google Chrome
    && mkdir -p /etc/apt/keyrings/ \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
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
# Fase 6: Comando de Inicio (CON TIMEOUT AUMENTADO)
# ==============================================================================
# Le damos 120 segundos (2 minutos) de paciencia al trabajador antes de cancelarlo.
CMD gunicorn --bind 0.0.0.0:$PORT --timeout 120 app:app