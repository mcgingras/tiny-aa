## You could have invented account abstraction

### Part 1:

Imagine we want a wallet that offers different protection mechanisms depending on the type of transaction. For example, transfering ERC20s should require a regular 1 signature (like an EOA) but transferring any NFT should require 2 signatures, for extra protection. How could we do this? We can't use a regular EOA, since there is no way to require 2 signatures from an EOA. An EOA can always execute any transaction with a single signauture. So, we need a smart contract that can act as our wallet. This will be called a smart wallet.

[insert rest of part one]

### Part 2:

*Introducing a mechanism for removing the need for an EOA. We introduce the “executor” who executes transactions on our behalf, and we refund this actor ETH.*

How might we improve this situation? What if we don’t want to require that the owner of the smart contract wallet (SCW) needs to have a separate EOA just to execute from. Right now we get the security guarantees, but we are lacking on UX. This is actually worse UX than simply using an EOA.

In part 1, an EOA that we controlled was calling the `executeOp` function and paying the gas. Since all of the security comes from the signers, it’s okay for anyone to make this call. We can imagine a service called an executor that will offer to make these calls on behalf of people who own SCWs, so the owners do not to manage a separate EOA.

The role of the executor is to call the `executeOp` function for given userOps. However, doing so costs gas. In part 1, it was okay that the external EOA was paying for gas, since it was an account we owned and we were paying gas for our own transactions. But when we introduce a 3rd party, they likely will not want to execute these ops for free.

The new plan is that the wallet contract will hold some ETH, and as part of the `executeOp` call we will calculate how much gas we spent, and send it back to the caller to compensate them for any gas they used. (how does the wallet get ETH?)

### Part 2a:

We are prone to an attack by a griefer. Since the executeOp function both handles validate + execution, and we are refunding gas no matter what, we are prone to an attack by a griefer that could submit ops that are invalid, but are still "executed" in the sense that we are able to call executeOp and run them (but have them fail). Yet, theses ops are still draining our balance, so it's faulty. Maybe a bundler could expose an attack vector here where they are able to suck up all the gas from a bunch of wallets by calling dummy userOps with insanely high gas fees. We need to protect against this.
