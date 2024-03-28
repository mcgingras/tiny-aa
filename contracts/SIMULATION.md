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
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
address to = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
address recipient = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
address wallet = 0x5FbDB2315678afecb367f032d93F642f64180aa3
uint256 nonce = 0
uint256 value = 0
uint256 gas = 0
bytes memory transferCalldata = abi.encodeWithSignature("transfer(address,uint256)", recipient, 1);
bytes32 digest = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(to,value,transferCalldata,gas,nonce)));
digest // view output (0x73bf7b9bf40a510f9d71a66cea901bfa417acd5dbf0132a93ef077adce8aed9f)
```

```
cast wallet sign -i [digest]
// copy signature
// check signature
cast wallet verify --address digest signature
cast wallet verify --address 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 0x73bf7b9bf40a510f9d71a66cea901bfa417acd5dbf0132a93ef077adce8aed9f 0xc948378940212089cf2dd0bfc7d360bb1e13f00f40cf57598c3857c9aba969677d0a8e39e4a738dda35b4eec93e5e8e39f51e75f77bcf105bd8538a089b1896b1b0
```

```
chisel
import {IWallet} from "../src/IWallet.sol";
bytes memory signature = hex'c948378940212089cf2dd0bfc7d360bb1e13f00f40cf57598c3857c9aba969677d0a8e39e4a738dda35b4eec93e5e8e39f51e75f77bcf105bd8538a089b1896b1b'
IWallet.UserOperation memory op = IWallet.UserOperation(address(wallet), to, value, transferCalldata, gas, signature, nonce);
bytes memory opCalldata = abi.encodeWithSignature("executeOp(UserOperation)", op);
```

```
cast rpc debug_traceCall '{"from":"0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266","to":"0x5FbDB2315678afecb367f032d93F642f64180aa3","data":"0x5ce2ab8d00000000000000000000000000000000000000000000000000000000000000200000000000000000000000005fbdb2315678afecb367f032d93f642f64180aa3000000000000000000000000e7f1725e7734ce288f8367e1bb143e90bb3f0512000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044a9059cbb00000000000000000000000070997970c51812dc3a010c7d01b50e0d17dc79c8000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004169892913b33cf36896828690d00e0e9ede3042ecc4d7b3c012b1fc81da1035db394b32c7a21a1974827be72fffb6e4f40f234aa8dbfe628ff214cd72e28133321b00000000000000000000000000000000000000000000000000000000000000"}'
```

This will deploy the Wallet contract on a local testnet, which we will be able to simulate transactions against. This is obviously not exactly what an executor would be doing, but it demonstrates closely enough for our purposes.

0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
