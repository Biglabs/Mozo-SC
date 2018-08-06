------------------------------------------------------------------ FOR AUDITORS -------------------------------------------------------------

1. List of contracts to be audited

1.1. Mozo tokens (ERC20)

a. Location: mozo\contracts\MozoToken.sol

b. Specification
- Decimals: 2
- Symbol: MOZO

1.2. ICO tokens (ERC20)

a. Location: mozo\contracts\MozoSaleToken.sol

b. Specification
- Created once before ICO
- Hardcap is set by owner (not softcap)
	+ We uase DApp to calculate total of collected Eth and BTC. Founder will use this tool to decide whether hardcap is reached or not
- Unsold tokens: When ICO ending
	+ hardcap is reached: burn all unsold tokens
	+ hard cap is not reached: distribute all unsold tokens to investors
- Rate: number of wei to buy 0.01 (smallest unit) Mozo tokens
- All sale smart contracts must use this rate
- Only owner of parent smart contract (Mozo tokens) can create this contract
- After releasing, sale tokens will be exchanged to Mozo tokens

1.3. Investment Bonus

a. Location: mozo\contracts\InvestmentDiscount.sol

b. Usage: Crowd sale

c. Specification:
- Created once in presale and crowd sale
- Only owner of parent smart contract (ICO tokens) can create this contract
- Owner can refill (add more tokens)
- Bonus based on number of Eth contribution

1.4. Time Lock tokens
a. Location: mozo\contracts\TimeLock.sol

b. Usage: After presale

c. Specification:
- Created after presale for consultant/advisor/team
- Only owner of parent smart contract (Mozo tokens) can create this contract
- When releasing by owner, all tokens will be transferred to beneficiary
- Agency can claim bonus token after contract ending (if owner did not release)

1.5. Revocable Vested tokens
a. Location: mozo\contracts\RevocableVested.sol

b. Usage: After ICO

c. Specification:
- Created after ICO for consultant/advisor/team
- Only owner of parent smart contract (Mozo tokens) can create this contract
- When revoking:
	+ Before cliff period: no tokens
	+ After cliff period: linear based on time passed
- Agency can claim bonus token after contract ending (if owner did not release)

2. Note:
- We try to reduce gas consumption
