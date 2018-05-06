------------------------------------------------------------------ FOR AUDITORS -------------------------------------------------------------

1. List of contracts to be audited

1.1. Mozo tokens (ERC20)

a. Location: mozo\contracts\MozoToken.sol

b. Specification
- Decimals: 2

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

1.4. Timeline Bonus

a. Location: mozo\contracts\TimelineBonus.sol

b. Usage: Presale and crowd sale

c. Specification:
- Created once in presale and crowd sale
- Only owner of parent smart contract (ICO tokens) can create this contract
- Owner can refill (add more tokens)
- Bonus period:
	+ Minimum contribution
	+ Percentage 
	=> No. tokens received = No. bought tokens * (1 + Percentage/100)
- After bonus period:
	+ Minimum contribution

1.5. Investment Bonus

a. Location: mozo\contracts\InvestmentDiscount.sol

b. Usage: Presale and crowd sale

c. Specification:
- Created once in presale and crowd sale
- Only owner of parent smart contract (ICO tokens) can create this contract
- Owner can refill (add more tokens)
- Bonus based on number of Eth contribution

1.6. Presale Agency
a. Location: mozo\contracts\Agency.sol

b. Usage: Presale

c. Specification:
- Created in presale (Optional: Multiple depends on number of agencies)
- Only owner of parent smart contract (ICO tokens) can create this contract
- Owner can refill (add more tokens)
- When releasing, bonus tokens will be transferred to agency
	=> No. bonus tokens = No. sold tokens * BonusPercentage/100
- Agency can claim bonus token after ICO ending (if owner did not release)

1.7. Referral
a. Location: mozo\contracts\Referral.sol

b. Usage: Crowd sale

c. Specification:
- Created in crowd sale for each registered agency investors
- Only owner of parent smart contract (ICO tokens) can create this contract
- There are 5 package levels:
	+ 50k tokens
		* Minimum contribution: 0.1ETH
		* Bonus: 10%
	+ 100k tokens
		* Minimum contribution: 0.1ETH
		* Bonus: 12%
		* required 50k tokens level
	+ 1m tokens
		* Minimum contribution: 0.1ETH
		* Bonus: 14%
		* required 100k tokens level
	+ 10m tokens
		* Minimum contribution: 0.1ETH
		* Bonus: 16%
		* required 1m tokens level
	+ 100m tokens
		* Minimum contribution: 0.1ETH
		* Bonus: 18%
		* required 10m tokens level
- Owner can upgrade level
	+ Good progress
	+ Requested by investors who buy tokens
- When releasing,bonus tokens will be transferred to agency
	=> No. bonus tokens = No. sold tokens * {Bonus percentage level of sold tokens} /100

1.8. Time Lock tokens
a. Location: mozo\contracts\TimeLock.sol

b. Usage: After presale

c. Specification:
- Created after presale for consultant/advisor/team
- Only owner of parent smart contract (Mozo tokens) can create this contract
- When releasing by owner, all tokens will be transferred to beneficiary
- Agency can claim bonus token after contract ending (if owner did not release)

1.9. Revocable Vested tokens
a. Location: mozo\contracts\RevocableVested.sol

b. Usage: After ICO

c. Specification:
- Created after ICO for consultant/advisor/team
- Only owner of parent smart contract (Mozo tokens) can create this contract
- When revoking:
	+ Before cliff period: no tokens
	+ After cliff period: linear based on time passed
- Agency can claim bonus token after contract ending (if owner did not release)

Refer to Mozo-Smart contracts.docx for more information.

2. Note:
- We try to reduce gas consumption
