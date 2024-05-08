-include .env

build:; forge build
deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA) --account fmkgen --sender 0x5159f365b81714Ca498477b9c6529A7681806d79 --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

#deploy-sepolia:
#	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA) --private-key $(PKBW) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv