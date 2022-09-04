#!/usr/bin/bash
sudo apt-get update
sudo apt-get install -y nginx
echo "<h1>Great job Bryon!</h1>" | sudo tee /var/www/html/index.html
sudo systemctl start nginx
sudo systemctl enable nginx
