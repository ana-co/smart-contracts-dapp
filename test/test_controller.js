const {expect, should, assert} = require('chai');
const truffleAssert = require('truffle-assertions');
const Controller = artifacts.require("Controller.sol");
const utils = require("../script/utils");
const FreeUniToken = artifacts.require("FreeUniToken.sol");
const Collection = artifacts.require('Collection.sol');
const EternalStorage = artifacts.require("EternalStorage.sol");
const NFTLibrary = artifacts.require("NFTLibrary.sol");


function getByte32(string) {
    return web3.utils.fromAscii(string);
}

contract("Controller", accounts => {

    let nft;
    let token;
    let controller;
    let storage;

    before(async () => {
        token = await FreeUniToken.new("FreeUNI TOKEN", "FRU", utils.toWei(1_000_000_000));
        nft = await Collection.new("NFT Collection", "VIDEOCOLLECTION", "");
        storage = await EternalStorage.new(accounts[0], accounts[0]);
        let lib = await NFTLibrary.new();
        await Controller.link("NFTLibrary", lib.address);
        controller = await Controller.new();
        await controller.initialize(storage.address, nft.address)
        await storage.setAssociatedContract(controller.address);

        await nft.grantRole(await nft.MINTER_ROLE.call(), controller.address);
        await nft.grantRole(await nft.DEFAULT_ADMIN_ROLE.call(), controller.address);
    });


    it("should assert true", async () => {
        await controller.handleMint("google.com");

        let owner = await nft.ownerOf(1);
        let uri = await nft.tokenURI(1);

        assert.equal(owner.toString(), accounts[0]);
        assert.equal(uri.toString(), "google.com");

    });


});