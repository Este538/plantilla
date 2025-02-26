#!/bin/bash

# Detener NGINX y NGROK
echo "Deteniendo NGINX y NGROK..."
sudo systemctl stop nginx.service
pkill ngrok

# Directorio del repositorio
repo_direction="/var/www/plantilla"

# Verificar si el directorio ya existe
if [ -d "$repo_direction" ]; then
    echo "El repositorio ya existe. Actualizando..."
    cd "$repo_direction"
    git pull
else
    echo "Clonando el repositorio..."
    git clone https://github.com/Este538/plantilla.git "$repo_direction"
    cd "$repo_direction"
fi

# Configurar NGINX para servir el repositorio
#hubo un detalle con la instalación, el sistema lo catalogo como root al usuario en vez de ELFO
nginx_config="/etc/nginx/sites-available/default"
if grep -q "root /var/www/plantilla;" "$nginx_config"; then
    echo "La configuración de NGINX ya está actualizada."
else
    echo "Actualizando la configuración de NGINX..."
    sudo sed -i 's|root /var/www/html;|root /var/www/plantilla;|' "$nginx_config"
    sudo nginx -t && sudo systemctl restart nginx
fi

# Iniciar NGINX
echo "Iniciando NGINX..."
sudo systemctl start nginx

# Generar URL de NGROK
echo "Iniciando NGROK..."
ngrok http 80 > /dev/null &

# Esperar unos segundos para que NGROK inicie
sleep 5

# Obtener la URL de NGROK
ngrok_url=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')

# Desplegar la URL de NGROK
echo "La URL de NGROK es: $ngrok_url"