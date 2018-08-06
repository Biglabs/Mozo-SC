const MozoToken = artifacts.require("./MozoToken.sol");
const MozoSaleToken = artifacts.require("./MozoSaleToken.sol");
const InvestmentDiscount = artifacts.require("./InvestmentDiscount.sol");
const TimeLock = artifacts.require("./TimeLock.sol");
const RevocableVested = artifacts.require("./RevocableVested.sol");

const oneMin = 60;
const oneHour = oneMin * oneMin;
const start = Math.round(Date.now() / 1000) + oneMin;

async function deployMozoToken(deployer) {
    const mozoTokenSupply = 500000000000;
    await deployer.deploy(MozoToken, mozoTokenSupply);
}

async function deployMozoSaleToken(deployer) {
    const params = {
        mozoToken: MozoToken.address,
        coOwners: [],
        supply: 70000000000,
        rate: 1923076900000,
        openingTime: start,
        closingTime: start + oneHour
    };
    await deployer.deploy(MozoSaleToken, params.mozoToken, params.coOwners,
        params.supply, params.rate, params.openingTime, params.closingTime);
}

async function deployInvestmentDiscount(deployer) {
    const eth = 1000000000000000000;
    const params1 = {
        smzoToken: MozoSaleToken.address,
        weiContributionTranches: [eth / 10, eth, 50 * eth],
        bonusPercentageTranches: [0, 10, 20],
        startTime: start,
        endTime: start + oneHour
    };

    await deployer.deploy(InvestmentDiscount, params1.smzoToken, params1.weiContributionTranches,
        params1.bonusPercentageTranches, params1.startTime, params1.endTime);
    const mozoSaleToken = await MozoSaleToken.deployed();
    await mozoSaleToken.addSaleAddress(InvestmentDiscount.address);
    await mozoSaleToken.transfer(InvestmentDiscount.address, 12000000000);
}

async function deployTimeLock(deployer, params) {
    await deployer.deploy(TimeLock, MozoToken.address, params.beneficiary,
        params.start, params.lockPeriod);
}

async function deployRevocableVested(deployer, params) {
    await deployer.deploy(RevocableVested, MozoToken.address, params.beneficiary,
        params.start, params.cliff, params.vestedDuration);
}

module.exports = function (deployer, network, accounts) {
    deployer.then(async () => {

        await deployMozoToken(deployer);
        await deployMozoSaleToken(deployer);
        await deployInvestmentDiscount(deployer);
        await deployTimeLock(deployer, {
            beneficiary: accounts[1],
            start: start,
            lockPeriod: oneMin
        });
        await deployRevocableVested(deployer, {
            beneficiary: accounts[2],
            start: start,
            cliff: oneMin,
            vestedDuration: oneMin
        });
    })
};