#!/usr/bin/env bash

echo "Resetting database..."
cd /Users/micheleglorioso/Desktop/Animals-adopt
bin/rails db:drop
bin/rails db:create
bin/rails db:migrate

echo "Adding sample data..."
bin/rails db:seed

echo "Done! Run ./start-server.sh to start the application."
