let MozoToken = artifacts.require("./MozoToken.sol");
const totalSupply = 500000000000;
contract('MozoToken', function (accounts) {
    it("should put 500000000000 in the first account", async () => {
        const mozoToken = await MozoToken.deployed();
        const balance = await mozoToken.balanceOf.call(accounts[0]);
        assert.equal(balance.valueOf(), totalSupply, `${totalSupply} wasn't in the first account`);
    });
    it("should valid owner", async () => {
        const instance = await MozoToken.deployed();
        const valid = await instance.isValidOwner.call(accounts[0]);
        assert.equal(valid, true, `${accounts[0]} is invalid owner`);
    });
    it("should send coin correctly", async () => {
        let firstAccount = accounts[0];
        let secondAccount = accounts[1];
        const amount = 1000;

        const mozoToken = await MozoToken.deployed();
        const firstStartingBalance = await mozoToken.balanceOf.call(firstAccount);
        const secondStartingBalance = await mozoToken.balanceOf.call(secondAccount);

        await mozoToken.transfer(secondAccount, amount);
        const firstEndingBalance = await mozoToken.balanceOf.call(firstAccount);
        const secondEndingBalance = await mozoToken.balanceOf.call(secondAccount);
        assert.equal(firstEndingBalance.valueOf(), firstStartingBalance.sub(amount).valueOf(), "Amount wasn't correctly taken from the sender");
        assert.equal(secondEndingBalance.valueOf(), secondStartingBalance.add(amount).valueOf(), "Amount wasn't correctly sent to the receiver");
    });
});
