# ==============================================================================
# Fase 1: Imagen Base
# Se utiliza una imagen oficial de Python 3.10 en su versión 'slim',
# que es ligera e ideal para producción.
# ==============================================================================
FROM python:3.10-slim

# ==============================================================================
# Fase 2: Instalación de Dependencias del Sistema (Google Chrome)
# Este bloque instala Google Chrome, que es necesario para que Selenium funcione.
# Se usa el método moderno y seguro para agregar la clave del repositorio.
# ==============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    && mkdir -p /etc/apt/keyrings/ \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    # Limpieza final para reducir el tamaño de la imagen
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# Fase 3: Configuración del Entorno de la Aplicación
# Se establece el directorio de trabajo dentro del contenedor.
# Todos los comandos siguientes se ejecutarán desde /app.
# ==============================================================================
WORKDIR /app

# ==============================================================================
# Fase 4: Instalación de Dependencias de Python
# Se copia únicamente el archivo requirements.txt primero. Esto aprovecha el
# caché de Docker: si no cambias tus dependencias, no se reinstalarán cada vez.
# ==============================================================================
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ==============================================================================
# Fase 5: Copia del Código de la Aplicación
# Se copia el resto de tu código (app.py, scraper.py) al contenedor.
# ==============================================================================
COPY . .

# ==============================================================================
# Fase 6: Comando de Inicio (EL MÁS IMPORTANTE)
# Esta es la instrucción final que ejecuta tu aplicación usando Gunicorn.
#
# - gunicorn: Es el servidor WSGI, mucho más robusto que el servidor de desarrollo de Flask.
# - --bind 0.0.0.0:$PORT: Le dice a Gunicorn que escuche en todas las interfaces de red
#   disponibles y que use el puerto que Railway (o Render) le asigne a través de
#   la variable de entorno $PORT.
# - app:app: Le dice a Gunicorn: "Dentro del archivo 'app.py', busca la variable
#   llamada 'app' (que es tu instancia de Flask)".
#
# Este comando resuelve directamente el error "No module named 'main'".
# ==============================================================================
CMD gunicorn --bind 0.0.0.0:$PORT app:app