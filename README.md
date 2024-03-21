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

We notice that Evil wallet is able to trick our executor by simply not refuding any gas in the executeOp method. In order to get around this, we can have our executor start simulating transactions off-chain befere calling them. If it receives an op that fails simulation (meaning it does not return any gas) then it will refuse to call any transactions that we know will not return us gas.

Let's do a demo here. We can't actually write any test cases because theres no such thing as "simulating a transaction" in solidity. (_is this correct?_) Instead, we can do what an executor would do, and run a local node off-chain to test against. Here are the steps

1. Spin up a local node
```
anvil
forge create Wallet --constructor-args "[0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266]" --interactive
$ enter private key from anvil (0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
```

2. Deploy ERC20 + other contracts to local node
```
// forge script script/1.2a/Deploy.s.sol:DeployScript --fork-url http://localhost:8545 --broadcast -i 1
```

3. Prepare calldata (testing our setup)
```
chisel
address to = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
bytes memory data = abi.encodeWithSignature("balanceOf(address)", to)
data
```

4. Make call against local node (testing our setup)
```
cast rpc eth_call '{"from":"0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266","to":"0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512","data":"0x70a08231000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb9226600000000000000000000000000000000000000000000000000000000"}'
```

5. Get nonce
To get the nonce we can use Rivet, or we can also just assume we are at 0.

6. Prepare calldata for `executeOp` call
```
chisel
address to = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
address recipient = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
uint256 nonce = 0
uint256 value = 0
uint256 gas = 0
bytes memory transferCalldata = abi.encodeWithSignature("transfer(address,uint256)", recipient, 1);
bytes32 digest = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(to,value,transferCalldata,gas,nonce)));
digest // view output
```

```
cast wallet sign -i [digest]
// copy signature
```


This will deploy the Wallet contract on a local testnet, which we will be able to simulate transactions against. This is obviously not exactly what an executor would be doing, but it demonstrates closely enough for our purposes.

### Part 2b:

We are prone to an attack by a griefer. Since the executeOp function both handles validate + execution, and we are refunding gas no matter what, we are prone to an attack by a griefer that could submit ops that are invalid, but are still "executed" in the sense that we are able to call executeOp and run them (but have them fail). Yet, theses ops are still draining our balance, so it's faulty. Maybe a bundler could expose an attack vector here where they are able to suck up all the gas from a bunch of wallets by calling dummy userOps with insanely high gas fees. We need to protect against this.
