web3 = require('web3')

function hash(string) {
    return web3.utils.keccak256(string);
}

function getByte32(string) {
    return web3.utils.fromAscii(string);
}

function toWei(amount) {
    return web3.utils.toWei("" + amount);
}

module.exports = {toWei, hash, getByte32};