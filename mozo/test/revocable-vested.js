let RevocableVested = artifacts.require("./RevocableVested.sol");

contract('RevocableVested', function (accounts) {
    it(`should valid agency address`, async () => {
        const revocableVested = await RevocableVested.deployed();
        const agency = await revocableVested.agency.call();
        assert.equal(agency, accounts[2], `${accounts[2]} is not match to deployed RevocableVested agency address`);
    });
});
