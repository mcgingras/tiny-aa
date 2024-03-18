## You could have invented account abstraction

Part 1:

Imagine we want a wallet that offers different protection mechanisms depending on the type of transaction. For example, transfering ERC20s should require a regular 1 signature (like an EOA) but transferring any NFT should require 2 signatures, for extra protection. How could we do this? We can't use a regular EOA, since there is no way to require 2 signatures from an EOA. An EOA can always execute any transaction with a single signauture. So, we need a smart contract that can act as our wallet. This will be called a smart wallet.
