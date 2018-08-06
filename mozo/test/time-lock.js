let TimeLock = artifacts.require("./TimeLock.sol");

contract('TimeLock', function (accounts) {
    it(`should valid agency address`, async () => {
        const timeLock = await TimeLock.deployed();
        const agency = await timeLock.agency.call();
        assert.equal(agency, accounts[1], `${accounts[1]} is not match to deployed TimeLock agency address`);
    });
});
