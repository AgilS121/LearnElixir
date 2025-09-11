#!/bin/sh
set -e

# Jalankan migrasi Ecto sebelum start server
/app/bin/hello_phoenix eval "HelloPhoenix.Release.migrate"

# Start release Phoenix
PHX_SERVER=true /app/bin/hello_phoenix start
