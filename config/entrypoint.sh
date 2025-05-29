#!/bin/bash
set -e

# Umgebungsvariablen mit Standardwerten
LDAP_SERVER=${LDAP_SERVER:-"ldap://ldap:389"}
LDAP_BASE_DN=${LDAP_BASE_DN:-"dc=example,dc=com"}
LDAP_ADMIN_DN=${LDAP_ADMIN_DN:-"cn=admin,dc=example,dc=com"}
LDAP_ADMIN_PASSWORD=${LDAP_ADMIN_PASSWORD:-"admin"}
GOSA_ADMIN_PASSWORD=${GOSA_ADMIN_PASSWORD:-"gosa"}

echo "Starting GOsa² Container..."
echo "LDAP Server: $LDAP_SERVER"
echo "Base DN: $LDAP_BASE_DN"

# Erstelle Verzeichnisse falls sie nicht existieren
mkdir -p /var/lib/gosa/sessions
mkdir -p /var/lib/gosa/tmp
mkdir -p /var/cache/gosa
mkdir -p /var/spool/gosa
mkdir -p /etc/gosa

# Erstelle GOsa Konfiguration basierend auf Umgebungsvariablen
cat > /etc/gosa/gosa.conf << EOF
<?xml version="1.0"?>
<conf>
  <main>
    <location name="default">
      <referral uri="${LDAP_SERVER}/${LDAP_BASE_DN}"
                admin="${LDAP_ADMIN_DN}"
                password="${LDAP_ADMIN_PASSWORD}" />
    </location>

    <globals>
      <sessionLifetime>7200</sessionLifetime>
      <passwordDefaultHash>ssha</passwordDefaultHash>
      <passwordMinLength>8</passwordMinLength>
      <logging>true</logging>
      <logFile>/dev/stdout</logFile>
      <cacheDirectory>/var/cache/gosa</cacheDirectory>
      <spoolDirectory>/var/spool/gosa</spoolDirectory>
      <language>de</language>
      <theme>default</theme>
      <debugLevel>0</debugLevel>
    </globals>
  </main>
</conf>
EOF

# Kopiere Konfiguration nach GOsa-Verzeichnis
cp /etc/gosa/gosa.conf /var/www/gosa/gosa.conf

# Setze Berechtigungen
chmod 640 /var/www/gosa/gosa.conf

echo "GOsa² configuration created successfully"
echo "Starting PHP-FPM..."

# Führe den ursprünglichen Befehl aus
exec "$@"
