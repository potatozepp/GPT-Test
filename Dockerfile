FROM node:18-slim

# Install ffmpeg for audio conversion
RUN apt-get update && apt-get install -y ffmpeg && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy source code
COPY . .

# Expose default ports for server and Vite dev server
EXPOSE 3001 5173

# Start the Express backend and Vite dev server
CMD ["sh", "-c", "npm run server & npm run dev"]
