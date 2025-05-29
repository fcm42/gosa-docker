#!/bin/bash
set -e

echo "Starting GOsa² Container..."

# Erstelle Verzeichnisse falls sie nicht existieren
mkdir -p /var/lib/gosa/sessions
mkdir -p /var/lib/gosa/tmp
mkdir -p /var/cache/gosa
mkdir -p /var/spool/gosa
mkdir -p /etc/gosa

echo "Starting PHP-FPM..."

# Führe den ursprünglichen Befehl aus
exec "$@"
