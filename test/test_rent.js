const {expect, should, assert} = require('chai');
const truffleAssert = require('truffle-assertions');
const Controller = artifacts.require("Controller.sol");
const utils = require("../script/utils");
const FreeUniToken = artifacts.require("FreeUniToken.sol");
const Collection = artifacts.require('Collection.sol');
const EternalStorage = artifacts.require("EternalStorage.sol");
const NFTLibrary = artifacts.require("NFTLibrary.sol");
const {MerkleTree} = require('merkletreejs');
const keccak256 = require('keccak256');

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
    await controller.mint("google.com", web3.utils.fromAscii("title"), web3.utils.fromAscii("desc"), price, 12, 144);

    token_id = 1;
    let owner = await nft.ownerOf(token_id);
    let uri = await nft.tokenURI(token_id);

    assert.equal(owner.toString(), accounts[0]);
    assert.equal(uri.toString(), "google.com");

    let res = await controller.getMediaInfo(token_id);
    assert.equal(price, res[2].toNumber());

  });

  it("should request renting nft", async () => {
    const peers = [accounts[1], accounts[2], accounts[3],accounts[4]];
    const merkleTree = new MerkleTree(peers, keccak256, {hashLeaves: true, sortPairs: true});
    const root = merkleTree.getHexRoot();
    let rentPrice = await controller.getMediaRentPrice(token_id);
    rentPrice = rentPrice.toNumber();
    const priceForPeer = rentPrice/peers.length;
    await controller.rentRequest(token_id, root, peers, {from: accounts[1], value:priceForPeer});
    const canRemove = await controller.canRemovePeer(token_id, accounts[1], accounts[1]);
    assert.equal(false, canRemove);

    const canRemove2 = await controller.canRemovePeer(token_id, accounts[1], accounts[2]);
    assert.equal(true, canRemove2);

    const canRemove3 = await controller.canRemovePeer(token_id, accounts[1], accounts[3]);
    assert.equal(true, canRemove3);
    let a = await controller.getPaidRentCumulativeValue(token_id, accounts[1]);
    console.log(a.toNumber());
  });

  it("should pay for renting nft from peer", async () => {
    const peers = [accounts[1], accounts[2], accounts[3],accounts[4]];
    const merkleTree = new MerkleTree(peers, keccak256, {hashLeaves: true, sortPairs: true});
    const proof = merkleTree.getHexProof(keccak256(accounts[2]));
    let rentPrice = await controller.getMediaRentPrice(token_id);
    rentPrice = rentPrice.toNumber();
    const priceForPeer = rentPrice/peers.length;
    await controller.rentByPeer(token_id, accounts[1], proof, {from:accounts[2], value:priceForPeer});
    const canRemove2 = await controller.canRemovePeer(token_id, accounts[1], accounts[2]);
    assert.equal(false, canRemove2);
    let a = await controller.getPaidRentCumulativeValue(token_id, accounts[1]);
    console.log(a.toNumber());
  });

  it("should request renting nft", async () => {
    let canRemove3 = await controller.canRemovePeer(token_id, accounts[1], accounts[3]);
    assert.equal(true, canRemove3);
    const peers = [accounts[1], accounts[2], accounts[4], accounts[5]];
    const merkleTree = new MerkleTree(peers, keccak256, {hashLeaves: true, sortPairs: true});
    const root = merkleTree.getHexRoot();
    await controller.rentRequest(token_id, root, peers, {from: accounts[1], value:0});
    const canRemove = await controller.canRemovePeer(token_id, accounts[1], accounts[1]);
    assert.equal(false, canRemove);
    const canRemove2 = await controller.canRemovePeer(token_id, accounts[1], accounts[2]);
    assert.equal(false, canRemove2);

    let rentPrice = await controller.getMediaRentPrice(token_id);
    rentPrice = rentPrice.toNumber();
    const priceForPeer = rentPrice/peers.length;
    const proof = merkleTree.getHexProof(keccak256(accounts[5]));
    await controller.rentByPeer(token_id, accounts[1], proof, {from:accounts[5], value:priceForPeer});

    const proof2 = merkleTree.getHexProof(keccak256(accounts[4]));
    await controller.rentByPeer(token_id, accounts[1], proof2, {from:accounts[4], value:priceForPeer});
    let a = await controller.getPaidRentCumulativeValue(token_id, accounts[1]);
    console.log(a.toNumber(), priceForPeer);

    const canRemove5 = await controller.canRemovePeer(token_id, accounts[1], accounts[5]);
    assert.equal(false, canRemove5);

    const canRemove4 = await controller.canRemovePeer(token_id, accounts[1], accounts[4]);
    assert.equal(false, canRemove4);

  });

  it("should returns nft status rented", async () => {
    let status = await controller.isRented(token_id);
    assert.equal(true, status);
    await controller.resetRentStatus(token_id, accounts[1]);
    let a = await controller.getPaidRentCumulativeValue(token_id, accounts[1]);
    assert.equal(a.toNumber(), 0);
    status = await controller.isRented(token_id);
    assert.equal(false, status);
  });

  it("should request renting nft", async () => {
    const peers = [accounts[1], accounts[2], accounts[3],accounts[4]];
    const merkleTree = new MerkleTree(peers, keccak256, {hashLeaves: true, sortPairs: true});
    const root = merkleTree.getHexRoot();
    let rentPrice = await controller.getMediaRentPrice(token_id);
    rentPrice = rentPrice.toNumber();
    const priceForPeer = rentPrice/peers.length;
    await controller.rentRequest(token_id, root, peers, {from: accounts[1], value:priceForPeer});
    const canRemove = await controller.canRemovePeer(token_id, accounts[1], accounts[1]);
    assert.equal(false, canRemove);

    const canRemove2 = await controller.canRemovePeer(token_id, accounts[1], accounts[2]);
    assert.equal(true, canRemove2);

    const canRemove3 = await controller.canRemovePeer(token_id, accounts[1], accounts[3]);
    assert.equal(true, canRemove3);
    let a = await controller.getPaidRentCumulativeValue(token_id, accounts[1]);
    console.log(a.toNumber());
  });

  it("should pay for renting nft from peer", async () => {
    const peers = [accounts[1], accounts[2], accounts[3],accounts[4]];
    const merkleTree = new MerkleTree(peers, keccak256, {hashLeaves: true, sortPairs: true});
    const proof = merkleTree.getHexProof(keccak256(accounts[2]));
    let rentPrice = await controller.getMediaRentPrice(token_id);
    rentPrice = rentPrice.toNumber();
    const priceForPeer = rentPrice/peers.length;
    await controller.rentByPeer(token_id, accounts[1], proof, {from:accounts[2], value:priceForPeer});
    const canRemove2 = await controller.canRemovePeer(token_id, accounts[1], accounts[2]);
    assert.equal(false, canRemove2);
    let a = await controller.getPaidRentCumulativeValue(token_id, accounts[1]);
    console.log(a.toNumber());
  });

  it("should request renting nft", async () => {
    let canRemove3 = await controller.canRemovePeer(token_id, accounts[1], accounts[3]);
    assert.equal(true, canRemove3);
    const peers = [accounts[1], accounts[2], accounts[4], accounts[5]];
    const merkleTree = new MerkleTree(peers, keccak256, {hashLeaves: true, sortPairs: true});
    const root = merkleTree.getHexRoot();
    await controller.rentRequest(token_id, root, peers, {from: accounts[1], value:0});
    const canRemove = await controller.canRemovePeer(token_id, accounts[1], accounts[1]);
    assert.equal(false, canRemove);
    const canRemove2 = await controller.canRemovePeer(token_id, accounts[1], accounts[2]);
    assert.equal(false, canRemove2);

    let rentPrice = await controller.getMediaRentPrice(token_id);
    rentPrice = rentPrice.toNumber();
    const priceForPeer = rentPrice/peers.length;
    const proof = merkleTree.getHexProof(keccak256(accounts[5]));
    await controller.rentByPeer(token_id, accounts[1], proof, {from:accounts[5], value:priceForPeer});

    const proof2 = merkleTree.getHexProof(keccak256(accounts[4]));
    await controller.rentByPeer(token_id, accounts[1], proof2, {from:accounts[4], value:priceForPeer});
    let a = await controller.getPaidRentCumulativeValue(token_id, accounts[1]);
    console.log(a.toNumber(), priceForPeer);

    const canRemove5 = await controller.canRemovePeer(token_id, accounts[1], accounts[5]);
    assert.equal(false, canRemove5);

    const canRemove4 = await controller.canRemovePeer(token_id, accounts[1], accounts[4]);
    assert.equal(false, canRemove4);

  });

  it("should returns nft status rented", async () => {
    let status = await controller.isRented(token_id);
    assert.equal(true, status);
    await controller.resetRentStatus(token_id, accounts[1]);
    let a = await controller.getPaidRentCumulativeValue(token_id, accounts[1]);
    assert.equal(a.toNumber(), 0);
    status = await controller.isRented(token_id);
    assert.equal(false, status);
  });

  it("should request renting nft by vinme person", async () => {
    const peers = [accounts[9], accounts[4], accounts[6]];
    const merkleTree = new MerkleTree(peers, keccak256, {hashLeaves: true, sortPairs: true});
    const root = merkleTree.getHexRoot();
    let rentPrice = await controller.getMediaRentPrice(token_id);
    rentPrice = rentPrice.toNumber();
    let a = await controller.getPaidRentCumulativeValue(token_id, accounts[9]);
    console.log("        asd ", a.toNumber());
    let priceForPeer = rentPrice/peers.length;
    await controller.rentRequest(token_id, root, peers, {from: accounts[9], value:priceForPeer});
    const canRemove = await controller.canRemovePeer(token_id, accounts[9], accounts[4]);
    assert.equal(true, canRemove);
    const canRemove2 = await controller.canRemovePeer(token_id, accounts[9], accounts[6]);
    assert.equal(true, canRemove2);
    a = await controller.getPaidRentCumulativeValue(token_id, accounts[9]);
    console.log("        asd ", a.toNumber());

    const proof = merkleTree.getHexProof(keccak256(accounts[4]));
    await controller.rentByPeer(token_id, accounts[9], proof, {from:accounts[4], value:priceForPeer});
    a = await controller.getPaidRentCumulativeValue(token_id, accounts[9]);
    console.log("        asd ", a.toNumber());

    const proof2 = merkleTree.getHexProof(keccak256(accounts[6]));
    await controller.rentByPeer(token_id, accounts[9], proof2, {from:accounts[6], value:priceForPeer});
    a = await controller.getPaidRentCumulativeValue(token_id, accounts[9]);
    console.log("        asd ", a.toNumber());

    const canRemove4 = await controller.canRemovePeer(token_id, accounts[9], accounts[4]);
    assert.equal(false, canRemove4);

    const canRemove6 = await controller.canRemovePeer(token_id, accounts[9], accounts[6]);
    assert.equal(false, canRemove6);

  });

  it("should returns nft status rented", async () => {
    let status = await controller.isRented(token_id);
    assert.equal(true, status);
    await controller.resetRentStatus(token_id, accounts[9]);
    let a = await controller.getPaidRentCumulativeValue(token_id, accounts[9]);
    assert.equal(a.toNumber(), 0);
    status = await controller.isRented(token_id);
    assert.equal(false, status);
  });




});