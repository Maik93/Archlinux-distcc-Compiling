#!/usr/bin/bash
set -e

image_name='maik-distcc'

# Mandatory argument: remote IP and username as user@ip
if [ -z "$1" ]; then
    echo "Usage: $0 user@ip"
    exit 1
fi

script_path="$( cd "$(dirname "$0")" ; pwd -P )"

echo "Building Docker image ${image_name}..."
sudo docker build -t ${image_name} .

echo "Transferring Docker image to $1..."
docker save ${image_name} | ssh -C $1 docker load

echo "Running Docker image ${image_name} on $1..."
ssh $1 << EOF
docker run -d \
    -p 3632:3632 \
    -p 3633:3633 \
    --name ${image_name} \
    ${image_name}
EOF
