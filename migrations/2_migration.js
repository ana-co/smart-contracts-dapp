const Collection = artifacts.require("Collection.sol");
const EternalStorage = artifacts.require("EternalStorage.sol");
const NFTLibrary = artifacts.require("NFTLibrary.sol");
const Controller = artifacts.require("Controller.sol");

module.exports = async function (deployer, network, accounts) {

    if (network === "test") {
        return;
    }


    // deploy NFT
    await deployer.deploy(Collection, "NFT Collection", "MEDIA", "", {gas : 3000000});
    let nft = await Collection.deployed();


    // deploy Controller
    await deployer.deploy(EternalStorage, accounts[0], accounts[0]);
    let storage = await EternalStorage.deployed();
    await deployer.deploy(NFTLibrary, {gas : 4000000});
    await deployer.link(NFTLibrary, Controller);
    await deployer.deploy(Controller, {gas : 3000000});
    let controller = await Controller.deployed();
    await controller.initialize(storage.address, nft.address);

    await storage.setAssociatedContract(controller.address);

    await nft.grantRole(await nft.MINTER_ROLE.call(), controller.address);
    await nft.grantRole(await nft.DEFAULT_ADMIN_ROLE.call(), controller.address);

};