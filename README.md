install dependencies:
### npm install

install truffle
### npm i truffle

run local network:
### npm i ganache-cli

generate abi using:
### node .\script\generateABIs.js

generate java class file from abi:

[//]: # ()
      install web3j cli   --> https://github.com/web3j/web3j-cli

setx JAVA_HOME -m "C:\_jdk12.0"


[//]: # ()
      web3j generate solidity [-hV] [-jt] [-st] -a=<abiFile> [-b=<binFile>] -o=<destinationFileDir> -p=<packageName>


compile:
### truffle console


deploying contracts:
### truffle migrate --network=[networkName] 

using console:
### truffle console --network=[networkName]


polygon matic test network params:
rpc-url https://polygon-mumbai.infura.io/v3/c9ffc30a4490470bb7fee9e7a8b4665b

network_id: 80001

chainId: 80001

confirmations: 2

timeoutBlocks: 200

gasPrice: 50000000000

skipDryRun: true

