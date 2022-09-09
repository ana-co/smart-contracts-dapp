const { assert} = require('chai');
// const truffleAssert = require('truffle-assertions');
const Controller = artifacts.require("Controller.sol");
const utils = require("../script/utils");
const FreeUniToken = artifacts.require("FreeUniToken.sol");
const Collection = artifacts.require('Collection.sol');
const EternalStorage = artifacts.require("EternalStorage.sol");
const NFTLibrary = artifacts.require("NFTLibrary.sol");
// const {expectRevert}  = require("@openzeppelin/test-helpers");


contract("Controller", accounts => {

    let nft;
    let token;
    let controller;
    let storage;
    let token_id;

    before(async () => {
        token = await FreeUniToken.new("FreeUNI TOKEN", "FRU", utils.toWei(1_000_000_000));
        nft = await Collection.new("NFT Collection", "VIDEOCOLLECTION", "");
        storage = await EternalStorage.new(accounts[0], accounts[0]);
        let lib = await NFTLibrary.new();
        await Controller.link("NFTLibrary", lib.address);
        controller = await Controller.new();
        await controller.initialize(storage.address, nft.address);
        await storage.setAssociatedContract(controller.address);

        await nft.grantRole(await nft.MINTER_ROLE.call(), controller.address);
        await nft.grantRole(await nft.DEFAULT_ADMIN_ROLE.call(), controller.address);
    });


    it("should mint", async () => {
        let price = utils.toWei('0.000000001');
        await controller.mint("google.com", web3.utils.fromAscii("title"), web3.utils.fromAscii("desc"), price, price, 144);

        token_id = 1;
        let owner = await nft.ownerOf(token_id);
        let uri = await nft.tokenURI(token_id);

        assert.equal(owner.toString(), accounts[0]);
        assert.equal(uri.toString(), "google.com");

        let res = await controller.getMediaInfo(token_id);
        assert.equal(price, res[2].toNumber());

    })

    it("should mint (not admin) ", async () => {
        let minter_account = accounts[2];
        let price = utils.toWei('0.0000000014');
        await controller.mint("notanadmin.com", web3.utils.fromAscii("ar var adzmini"), web3.utils.fromAscii("desc"), price, price, 144, {from: minter_account});

        token_id = 2;
        let owner = await nft.ownerOf(token_id);
        let uri = await nft.tokenURI(token_id);

        assert.equal(owner.toString(), minter_account);
        assert.equal(uri.toString(), "notanadmin.com");

        let res = await controller.getMediaInfo(token_id);
        assert.equal(price, res[2].toNumber());

    })


    it("should buy (owner)", async () => {
        let price = utils.toWei('0.0000000012');
        await controller.mint("google2.com", utils.getByte32("title2"), utils.getByte32("desc2"), price, price, 144);
        token_id = 3;
        // let prev_owner = await nft.ownerOf(token_id);

        let buyer_account = accounts[2];
        await controller.buyNFT(token_id, {from: buyer_account, value: price});

        let owner = await nft.ownerOf(token_id);
        assert.equal(owner.toString(), buyer_account);

    });


    it("should buy (owner)", async () => {
        let price = utils.toWei('0.0000000012');
        await controller.mint("google2.com", utils.getByte32("title2"), utils.getByte32("desc2"), price, price, 144,
            {from: accounts[8]});
        token_id = 4;
        // let prev_owner = await nft.ownerOf(token_id);

        let buyer_account = accounts[9];
        await controller.buyNFT(token_id, {from: buyer_account, value: price});

        let owner = await nft.ownerOf(token_id);
        assert.equal(owner.toString(), buyer_account);

    });

    it("should buy (owner)", async () => {
        let price = utils.toWei('0.0000000012');
        token_id = 4;
        // let prev_owner = await nft.ownerOf(token_id);

        let buyer_account = accounts[8];
        // await nft.approve(controller.address, token_id, {from: prev_owner});
        await controller.buyNFT(token_id, {from: buyer_account, value: price});

        let owner = await nft.ownerOf(token_id);
        assert.equal(owner.toString(), buyer_account);

    });

    it("should not buy (low price) ", async () => {
        let price = utils.toWei('0.000000002');
        await controller.mint("lowprice.com", utils.getByte32("lowprice"), utils.getByte32("desc3"), price, price, 144);
        token_id = 4

        // let prev_owner = await nft.ownerOf(token_id);
        let buyer_account = accounts[3];

        let price_offer = utils.toWei('0.000000001');

        try {
            await controller.buyNFT(token_id, {from: buyer_account, value: price_offer});
            assert.fail("Not enough funds");
        } catch (err) {
            assert.include(err.message, "revert", "Not enough funds");
        }

        // await assert.throws(
        //     controller.buyNFT(token_id, {from: buyer_account, value: price_offer}),
        //     "Not enough funds"
        // );

    });

    // it("should buy (balance) ", async () => {
    //     let price = utils.toWei('0.000000001');
    //     await controller.mint("google4.com", utils.getByte32("title3"), utils.getByte32("desc3"), price);
    //     token_id = 5;
    //
    //     let prev_owner = await nft.ownerOf(token_id);
    //     // let owner_balance_before_purchase = await web3.eth.getBalance(prev_owner);
    //
    //     let buyer_account = accounts[5];
    //     // let buyer_balance_before_purchase = await web3.eth.getBalance(buyer_account);
    //
    //     await nft.approve(controller.address, token_id, {from: prev_owner});
    //     await controller.buyNFT(token_id, {from: buyer_account, value:price});
    //
    //     // let owner_balance = await web3.eth.getBalance(prev_owner);
    //     // let buyer_balance = await web3.eth.getBalance(buyer_account);
    //
    //     // assert.equal(Number(owner_balance), Number(owner_balance_before_purchase)+Number(price));
    //     // assert.isBelow(Number(buyer_balance), Number(buyer_balance_before_purchase)+Number(price));
    //
    // });


});