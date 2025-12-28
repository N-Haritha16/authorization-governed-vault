#!/bin/sh
set -e

echo "Compiling contracts..."
npx hardhat compile

echo "Waiting for blockchain to be ready..."
sleep 10

echo "Deploying contracts..."
npx hardhat run scripts/deploy.js --network localhost

echo "Deployment completed"
tail -f /dev/null
