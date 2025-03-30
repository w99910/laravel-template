#!/bin/bash
set -e

# Use sed to replace placeholders with actual environment variables
sed -e "s/\${DB_USERNAME}/$DB_USERNAME/g" \
    -e "s/\${DB_PASSWORD}/$DB_PASSWORD/g" \
    -e "s/\${DB_DATABASE}/$DB_DATABASE/g" \
    /docker-entrypoint-initdb.d/create-indexes.js.template > /tmp/create-indexes.js

# Execute the generated script using mongosh
mongosh --host localhost --port 27017 /tmp/create-indexes.js
