# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/go/dockerfile-reference/

# Want to help us make this template better? Share your feedback here: https://forms.gle/ybq9Krt8jtBL3iCk7

ARG NODE_VERSION=18

# Use an ARM-compatible base image
FROM node:${NODE_VERSION}

# # Install Python and other dependencies
# RUN apk add --no-cache python3 py3-pip build-base



WORKDIR /usr/src/app

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.npm to speed up subsequent builds.
# Leverage a bind mounts to package.json and package-lock.json to avoid having to copy them into
# into this layer.
COPY package.json ./
RUN npm install

# Run the application as root user.
USER root

# Copy the rest of the source files into the image.
COPY . .
# Install dependencies for all extensions.
# RUN for dir in extensions/*; do \
#     if [ -d "$dir" ]; then \
#         cd "$dir" && npm install && npm run build && cd ..; \
#     fi \
# done
# Expose the port that the application listens on.
EXPOSE 8055

RUN  bash ./deploy.sh
RUN npx directus start
# # Run the application.
# RUN nohup npx --yes directus start & npx directus-sync -u http://127.0.0.1:8055 -e $ADMIN_EMAIL  -p $ADMIN_PASSWORD  push --force
# CMD bash -c 'if lsof -i:8055 -t >/dev/null; then echo "Port 8055 is in use. Killing the process using it..."; kill -9 $(lsof -i:8055 -t); echo "Process killed."; fi && npx directus start'