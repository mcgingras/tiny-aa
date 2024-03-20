## You could have invented account abstraction

### Part 1:

Imagine we want a wallet that offers different protection mechanisms depending on the type of transaction. For example, transfering ERC20s should require a regular 1 signature (like an EOA) but transferring any NFT should require 2 signatures, for extra protection. How could we do this? We can't use a regular EOA, since there is no way to require 2 signatures from an EOA. An EOA can always execute any transaction with a single signauture. So, we need a smart contract that can act as our wallet. This will be called a smart wallet.

[insert rest of part one]

### Part 2:

Now, imagine that we do not want a separate EOA we control to have to execute transactions. The problem is that we need gas in this EOA, which may not be a problem for us, but it's a problem for onboarding new users who don't know what gas is.

"We said that the wallet contract’s executeOp method can be called by anyone, so we could just ask someone else with an EOA to call it for us. I will refer to this EOA and the person running it as the 'executor.'"

"Since the executor is the one paying for gas, not many people would be willing to do that for free. So the new plan is that the wallet contract will hold some ETH, and as part of the executor’s call, the wallet will transfer some ETH to the executor to compensate the executor for any gas used."

In part 2, we imagine that we are an executer who is given a userOp, and it is our job to execute the transaction by calling `handleOp` on the entryPoint on behalf of the account.
