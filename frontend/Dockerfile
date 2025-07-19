# Dockerfile для frontend
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Build argument for the API URL
ARG REACT_APP_BASE_URL=http://localhost:5000/api
ENV REACT_APP_BASE_URL=$REACT_APP_BASE_URL

RUN npm run build

RUN npm install -g serve

EXPOSE 3000

CMD ["serve", "-s", "build", "-l", "3000"]
