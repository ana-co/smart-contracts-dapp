const {expect, should, assert} = require('chai');
const truffleAssert = require('truffle-assertions');
const Controller = artifacts.require("Controller.sol");
const utils = require("../script/utils");
const FreeUniToken = artifacts.require("FreeUniToken.sol");
const Collection = artifacts.require('Collection.sol');
const EternalStorage = artifacts.require("EternalStorage.sol");
const NFTLibrary = artifacts.require("NFTLibrary.sol");


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
        await controller.mint("google.com", utils.getByte32("title"), utils.getByte32("desc"), 12);

        let owner = await nft.ownerOf(1);
        let uri = await nft.tokenURI(1);

        assert.equal(owner.toString(), accounts[0]);
        assert.equal(uri.toString(), "google.com");

        let res = await controller.getMediaInfo(1);
        assert.equal(12, res[2].toNumber());

    })


    it("should assert true", async () => {
        await controller.mint("google2.com", utils.getByte32("title2"), utils.getByte32("desc2"), 12);
        let token_id = 2
        let prev_owner = await nft.ownerOf(token_id);

        let buyer_account = accounts[2]
        await nft.approve(controller.address, token_id, {from: prev_owner})
        await controller.buyNFT(2, {from: buyer_account, value:12});

        let owner = await nft.ownerOf(token_id);
        assert.equal(owner.toString(), buyer_account);

    });


});