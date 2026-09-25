#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx

# Start Nginx service
sudo systemctl start nginx

# Enable Nginx to start on boot
sudo systemctl enable nginx

# Add a simple HTML page
echo "<h1>Hello, Nginx is running on Ubuntu!</h1>" | sudo tee /var/www/html/index.html