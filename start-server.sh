#!/usr/bin/env bash

echo "Running migrations..."
cd /Users/micheleglorioso/Desktop/Animals-adopt
bin/rails db:migrate

echo "Starting Rails server..."
bin/rails server
