#!/usr/bin/env bash
set -euo pipefail

# Jalankan migrasi jika modul Release ada
/app/bin/hello_phoenix eval '
if Code.ensure_loaded?(HelloPhoenix.Release) and function_exported?(HelloPhoenix.Release, :migrate, 0) do
  IO.puts("Running DB migrations...")
  HelloPhoenix.Release.migrate()
else
  IO.puts("Skip migrate: HelloPhoenix.Release.migrate/0 not found")
end
'

# Start aplikasi
exec /app/bin/hello_phoenix start
