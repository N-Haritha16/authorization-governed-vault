FROM node:18-alpine

WORKDIR /app

# install deps
COPY package.json ./
RUN npm install

# copy rest of project
COPY . .

# compile contracts (optional but good)
RUN npx hardhat compile

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
