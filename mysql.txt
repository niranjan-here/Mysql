#!/bin/bash

MYSQL_PASSWORD="student"

echo "🔍 Checking for existing MySQL installation..."

if dpkg -l | grep -q mysql-server; then
    echo "⚠️ Removing existing MySQL..."

    sudo systemctl stop mysql

    sudo apt-get purge -y mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-*
    sudo apt-get autoremove -y
    sudo apt-get autoclean

    sudo rm -rf /etc/mysql /var/lib/mysql /var/log/mysql

    echo "✅ Old MySQL removed."
else
    echo "✅ No existing MySQL found."
fi

echo "📦 Updating packages..."
sudo apt-get update

echo "📥 Installing MySQL..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

echo "⚙️ Configuring MySQL..."

sudo mysql <<EOF
-- Remove password validation completely (easiest policy)
UNINSTALL COMPONENT 'file://component_validate_password';

-- Ensure password-based login works
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_PASSWORD}';

FLUSH PRIVILEGES;
EOF

echo "🚀 MySQL setup complete."

echo "🧪 Testing login..."
mysql -u root -p${MYSQL_PASSWORD} -e "SELECT VERSION();"

if [ $? -eq 0 ]; then
    echo "✅ Success! MySQL root password is 'student'"
else
    echo "❌ Login failed. Try: sudo mysql"
fi
