#!/bin/bash
source .env && forge script script/NFTMarketDeploy.s.sol:NFTMarketV1Deploy --rpc-url ${ETH_RPC_URL} --broadcast -vvvv
source .env && forge script script/NFTMarketDeploy.s.sol:NFTMarketV2Deploy --rpc-url ${ETH_RPC_URL} --broadcast -vvvv

# mint a nft
cast send 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "mint(address,string)(uint256)" 0x251757EFDd8818283ec73A428e5486FB319bFc84 https://ipfs.io/ipfs/QmY5WwRyZm7P6cT9y4uNcHr5eVJvXsQkLX9VZgVn5h7uZ --private-key ${PRIVATE_KEY}
# list a nft
cast send 0xcf7ed3acca5a467e9e704c703e8d87f634fb0fc9 "list(uint256,uint256)" 2 10000 -f 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
