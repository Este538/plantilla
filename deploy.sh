#!/bin/bash

#Detener NGINX y NGROK

sudo systemctl restart nginx.service
pkill ngrok

#Directorio del repositorio.
repo_direction="/var/www/plantilla"

#Verificar si el directorio ya existe.
if[ -d "$repo_direction" ]; then
    cd "$repo_direction"
    git pull
else
   git clone https://github.com/Este538/plantilla.git
fi

#Iniciar NGINX
sudo systemctl start nginx

#Generar URL de NGROK
ngrok http 80 > /dev/null &
#Esperar unos segundos para que NGROK inicie
sleep 5

#Obtener la URL de NGROK
ngrook_url=$(curl -s http://localhost:4040/api/tunnels | jq -r .tunnels[0].public_url)

#Desplegar la URL de NGROK
echo "La URL de NGROK es: $ngrook_url"