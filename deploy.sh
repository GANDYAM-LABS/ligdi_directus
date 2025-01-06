
#!/bin/bash
# Install dependencies


echo "Installing dependencies..."
npm install -y
echo "Dependencies installed."
# Load environment variables from .env file
if [ -f .env ]; then
    while IFS='=' read -r key value; do
        if [[ ! $key =~ ^# && -n $key ]]; then
            export "$key=$value"
        fi
    done < .env
    echo ".env file loaded."
else
    echo ".env file not found."
fi
# Build Directus extensions
echo "Building Directus extensions..."
cd extensions/
echo "Current directory: $(pwd)"
for d in */ ; do
    cd "$d"
    echo "Current directory: $(pwd)"
    if [ -f package.json ]; then
        echo "Building $d..."
        npm install
        npm run build
        echo "$d built."
    else
        echo "Error: $d does not contain a package.json file."
    fi
    cd ../
    echo "Current directory: $(pwd)"
done
cd ../
echo "Current directory: $(pwd)"
echo "Directus extensions built."

# Install Directus database tables
echo "Installing Directus database tables..."
if npx --yes  directus bootstrap; then
    echo "Directus database tables installed."
else
    echo "Error: Directus database tables already installed."
fi
# Install Directus admin user
echo "Installing Directus admin user..."
echo "Admin email: $ADMIN_EMAIL"
echo "Admin password: $ADMIN_PASSWORD"
if npx --yes directus users passwd --email=$ADMIN_EMAIL --password=$ADMIN_PASSWORD; then
    echo "Directus admin user installed."
else
    echo "Error: Directus admin user already installed."
fi

# Start Directus
echo "Starting Directus..."
# Check if port 8055 is in use and kill the process using it
if lsof -i:8055 -t >/dev/null; then
    echo "Port 8055 is in use. Killing the process using it..."
    kill -9 $(lsof -i:8055 -t)
    echo "Process killed."
fi

nohup npx --yes directus start &
#npx directus-sync -u http://127.0.0.1:8055 -e $ADMIN_EMAIL  -p $ADMIN_PASSWORD  push --force


