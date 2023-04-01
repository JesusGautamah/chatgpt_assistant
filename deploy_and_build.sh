#!/usr/bin bash

# This script is used to deploy the application to the server

echo "Deploying the application to the server..."
cd chatgpt_assistant
git pull
sudo docker compose build
sudo docker compose up -d
sudo docker compose restart
echo "Deployed the application to the server"
