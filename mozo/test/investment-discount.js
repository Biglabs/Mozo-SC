let InvestmentDiscount = artifacts.require("./InvestmentDiscount.sol");
let MozoSaleToken = artifacts.require("./MozoSaleToken.sol");

contract('InvestmentDiscount', function (accounts) {
    it(`should valid MozoSaleToken address`, async () => {
        const investmentDiscount = await InvestmentDiscount.deployed();
        const ico = await investmentDiscount.ico.call();
        const mozoSaleToken = await MozoSaleToken.deployed();
        const address = mozoSaleToken.address;
        assert.equal(ico, address, `${ico} is not match to deployed MozoSaleToken address`);
    });
    it(`should getSoldToken`, async () => {
        const investmentDiscount = await InvestmentDiscount.deployed();
        const soldToken = await investmentDiscount.getSoldToken.call();
        assert.isAtLeast(soldToken.toNumber(), 0, `failed`);
        const addingSeconds = 100;
        await web3.currentProvider.send({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [100],
            id: 0
        });
        console.log(`increaseTime ${addingSeconds} seconds`);
    });
    it(`should buyToken successfully`, async () => {
        const investmentDiscount = await InvestmentDiscount.deployed();
        const value = web3.toWei(10, "ether");
        await investmentDiscount.buyToken({from: accounts[3], value: value});
        const soldToken = await investmentDiscount.getSoldToken.call();
        assert.isAtLeast(soldToken, 0, `failed`);
    });
    it(`should getSoldToken`, async () => {
        const investmentDiscount = await InvestmentDiscount.deployed();
        const soldToken = await investmentDiscount.getSoldToken.call();
        assert.isAtLeast(soldToken.toNumber(), 1, `failed`);
    });
});
