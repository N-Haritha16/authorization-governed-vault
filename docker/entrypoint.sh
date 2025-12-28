#!/bin/sh
set -e

# 1) start hardhat node
npx hardhat node --hostname 0.0.0.0 &
HARDHAT_PID=$!

sleep 10

# 2) deploy using package.json script
npm run deploy

# 3) keep node alive
wait $HARDHAT_PID
