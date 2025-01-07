ARG NODE_VERSION=18.19.1

FROM node:${NODE_VERSION}

# Use production node environment by default.
ENV NODE_ENV=production

WORKDIR /usr/src/app

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.npm to speed up subsequent builds.
# Leverage a bind mounts to package.json and package-lock.json to avoid having to copy them into
# into this layer.
COPY package.json .
RUN npm install

# Run the application as root user.
USER root

# Copy the rest of the source files into the image.
COPY . .
# Install dependencies for all extensions.
RUN for dir in extensions/*; do \
    if [ -d "$dir" ]; then \
        (cd "$dir" && echo  "$dir" &&  npm install && npm run build); \
    fi; \
done
# Expose the port that the application listens on.
EXPOSE 8056
RUN bash ./deploy.sh
# Run the application.
# Run the application with increased memory limit.
# ENV NODE_OPTIONS="--max-old-space-size=4096"
CMD npx directus start