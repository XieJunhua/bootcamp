# bootcamp

to record web3 code

upgrade NFTMarket:
1. deploy v1 in dev, set .env `export DEPLOYER=${ETH_FROM}` and the `PRIVATE_KEY` you need to config in your env, try to execute `echo ${PRIVATE_KEY}` to test if you have set this.
```sh
source .env && forge script script/NFTMarketDeploy.s.sol:NFTMarketV1Deploy --rpc-url ${ETH_RPC_URL} --broadcast -vvvv
```
you will get:
```sh
[⠒] Compiling...
[⠘] Compiling 1 files with 0.8.25
[⠊] Solc 0.8.25 finished in 4.70s
Compiler run successful!
EIP-3855 is not supported in one or more of the RPCs used.
Unsupported Chain IDs: 31337.
Contracts deployed with a Solidity version equal or higher than 0.8.20 might not work properly.
For more information, please see https://eips.ethereum.org/EIPS/eip-3855
Traces:
  [3976404] NFTMarketV1Deploy::run()
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return] 
    ├─ [1553188] → new NFTMarketV1@0x5FbDB2315678afecb367f032d93F642f64180aa3
    │   └─ ← [Return] 7647 bytes of code
    ├─ [0] VM::envAddress("ETH_FROM") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [649703] → new BaseERC20@0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
    │   └─ ← [Return] 2687 bytes of code
    ├─ [1334885] → new MyERC721@0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
    │   └─ ← [Return] 6442 bytes of code
    ├─ [169036] → new ERC1967Proxy@0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
    │   ├─ emit Upgraded(implementation: NFTMarketV1: [0x5FbDB2315678afecb367f032d93F642f64180aa3])
    │   ├─ [115327] NFTMarketV1::initialize(MyERC721: [0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0], BaseERC20: [0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512]) [delegatecall]
    │   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266)
    │   │   ├─ emit Initialized(version: 1)
    │   │   └─ ← [Stop] 
    │   └─ ← [Return] 142 bytes of code
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return] 
    └─ ← [Stop] 


Script ran successfully.

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [1553188] → new NFTMarketV1@0x5FbDB2315678afecb367f032d93F642f64180aa3
    └─ ← [Return] 7647 bytes of code

  [649703] → new BaseERC20@0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
    └─ ← [Return] 2687 bytes of code

  [1334885] → new MyERC721@0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
    └─ ← [Return] 6442 bytes of code

  [171536] → new ERC1967Proxy@0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
    ├─ emit Upgraded(implementation: NFTMarketV1: [0x5FbDB2315678afecb367f032d93F642f64180aa3])
    ├─ [115327] NFTMarketV1::initialize(MyERC721: [0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0], BaseERC20: [0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512]) [delegatecall]
    │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266)
    │   ├─ emit Initialized(version: 1)
    │   └─ ← [Stop] 
    └─ ← [Return] 142 bytes of code


==========================

Chain 31337

Estimated gas price: 2 gwei

Estimated total gas used for script: 5452844

Estimated amount required: 0.010905688 ETH

==========================
##
Sending transactions [0 - 3].
⠚ [00:00:00] [#######################################################################################] 4/4 txes (0.0s)##
Waiting for receipts.
⠒ [00:00:00] [###################################################################################] 4/4 receipts (0.0s)
##### anvil-hardhat
✅  [Success]Hash: 0xb19721abfc5905b085258f0eb7505a6a08d959a67f8f26200e43c149a88a6c3e
Contract Address: 0x5FbDB2315678afecb367f032d93F642f64180aa3
Block: 1
Paid: 0.001714206 ETH (1714206 gas * 1 gwei)


##### anvil-hardhat
✅  [Success]Hash: 0x33bf4e87b875dee650000cf5827db94cfc21965db7160e8588d60bb9b25739fa
Contract Address: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
Block: 1
Paid: 0.000752417 ETH (752417 gas * 1 gwei)


##### anvil-hardhat
✅  [Success]Hash: 0xfd8547d7e97b4cada35c02e35344d7d8c9945c8950bd0a72977a82b8cf358ad6
Contract Address: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
Block: 1
Paid: 0.001487279 ETH (1487279 gas * 1 gwei)


##### anvil-hardhat
✅  [Success]Hash: 0x8d34bc17d82c5bacd09c3bcf4009920fef9bb80dd4cd37a5024926744ab24cc4
Contract Address: 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
Block: 1
Paid: 0.0002418 ETH (241800 gas * 1 gwei)



==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
Total Paid: 0.004195702 ETH (4195702 gas * avg 1 gwei)

Transactions saved to: /Users/xiejunhua/web3/bootcamp/broadcast/NFTMarketDeploy.s.sol/31337/run-latest.json

Sensitive values saved to: /Users/xiejunhua/web3/bootcamp/cache/NFTMarketDeploy.s.sol/31337/run-latest.json
```

2. you can get the proxy address from the log and set it to the .env file
   
