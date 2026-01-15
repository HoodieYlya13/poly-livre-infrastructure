#!/bin/bash

mkdir -p ..
cd ..

if [ ! -d "poly-livre-backend" ]; then
  git clone https://github.com/HoodieYlya13/poly-livre-backend.git
fi

if [ ! -d "poly-livre-frontend" ]; then
  git clone https://github.com/HoodieYlya13/poly-livre-frontend.git
fi

cd poly-livre-fullstack-infrastructure

echo "Installing frontend dependencies..."
(cd ../poly-livre-frontend && npm install)

docker compose up --build