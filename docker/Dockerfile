FROM node:18-alpine

WORKDIR /app

# install deps
COPY package.json package-lock.json ./
RUN npm install

# copy project
COPY . .

# make sure entrypoint is executable
RUN chmod +x docker/entrypoint.sh

# run your script on container start
CMD ["sh", "./docker/entrypoint.sh"]
