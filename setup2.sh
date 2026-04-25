#!/bin/bash

set -e

MYSQL_PASSWORD="student"

echo "🧹 Stopping MySQL (if running)..."
sudo systemctl stop mysql || true

echo "🗑️ Removing MySQL packages..."
sudo apt-get purge -y mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-* || true

echo "🧼 Removing dependencies..."
sudo apt-get autoremove -y
sudo apt-get autoclean

echo "📂 Deleting MySQL files..."
sudo rm -rf /etc/mysql /var/lib/mysql /var/log/mysql

echo "📦 Updating package list..."
sudo apt-get update

echo "📥 Installing MySQL..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

echo "⚙️ Configuring MySQL..."

sudo mysql <<EOF
-- Remove password validation (avoid weak password errors)
UNINSTALL COMPONENT 'file://component_validate_password';

-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_PASSWORD}';

FLUSH PRIVILEGES;
EOF

echo "🔄 Restarting MySQL..."
sudo systemctl restart mysql

echo "🧪 Testing login..."
if mysql -u root -p${MYSQL_PASSWORD} -e "SELECT VERSION();" >/dev/null 2>&1; then
    echo "✅ SUCCESS: MySQL installed and root password is 'student'"
else
    echo "❌ Login failed. Try: sudo mysql"
fi
