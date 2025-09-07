#!/bin/bash

# Build the Docker image
docker build -t health_exam_db_image .

# Remove the existing container if it exists
docker rm -f health_exam_db 2>/dev/null

# Run the Docker container
docker run -d \
    --name health_exam_db \
    -p 3306:3306 \
    health_exam_db_image

# Check if the container is running
docker ps -f "name=health_exam_db"