#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rails/tmp/pids/server.pid

# Wait for database
until PGPASSWORD=${POSTGRES_PASSWORD:-password} psql -h "db" -U "${POSTGRES_USER:-hello}" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - executing command"

# Install development gems if needed
bundle install

# Prepare database and assets
bundle exec rails db:prepare

# Then exec the container's main process
exec bundle exec puma -C config/puma.rb
