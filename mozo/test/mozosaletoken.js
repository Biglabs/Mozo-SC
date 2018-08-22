let MozoSaleToken = artifacts.require("./MozoSaleToken.sol");
const totalSupply = 70000000000;
contract('MozoSaleToken', function (accounts) {
    it(`should put ${totalSupply} - 12000000000 in the first account (because 12000000000 in crowd sale`, async () => {
        const smzo = await MozoSaleToken.deployed();
        const balance = await smzo.balanceOf.call(accounts[0]);
        assert.equal(balance.valueOf(), totalSupply - 12000000000, `${totalSupply} wasn't in the first account`);
    });
    it("should valid contract info", async () => {
        const smzo = await MozoSaleToken.deployed();
        const name = await smzo.name.call();
        const symbol = await smzo.symbol.call();
        const decimals = await smzo.decimals.call();
        const amlThreshold = await smzo.AML_THRESHOLD.call();
        assert.equal(name, "Mozo Sale Token", "Wrong Token name");
        assert.equal(symbol, "SMZO", "Wrong token symbol");
        assert.equal(decimals, 2, "Wrong decimals");
        assert.equal(amlThreshold, 16500000, "Wrong AML_THRESHOLD");
    });
    it("should valid owner", async () => {
        const smzo = await MozoSaleToken.deployed();
        const valid = await smzo.isValidOwner.call(accounts[0]);
        assert.equal(valid, true, `${accounts[0]} is invalid owner`);
    });
    it("should send coin correctly", async () => {
        let firstAccount = accounts[0];
        let secondAccount = accounts[1];
        const amount = 1000;

        const smzo = await MozoSaleToken.deployed();
        const firstStartingBalance = await smzo.balanceOf.call(firstAccount);
        const secondStartingBalance = await smzo.balanceOf.call(secondAccount);

        await smzo.transfer(secondAccount, amount);
        const firstEndingBalance = await smzo.balanceOf.call(firstAccount);
        const secondEndingBalance = await smzo.balanceOf.call(secondAccount);
        assert.equal(firstEndingBalance.valueOf(), firstStartingBalance.sub(amount).valueOf(), "Amount wasn't correctly taken from the sender");
        assert.equal(secondEndingBalance.valueOf(), secondStartingBalance.add(amount).valueOf(), "Amount wasn't correctly sent to the receiver");
    });
});
