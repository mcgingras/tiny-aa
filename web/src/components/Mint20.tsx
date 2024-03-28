"use client";

import {
  useWriteContract,
  useWaitForTransactionReceipt,
  useAccount,
} from "wagmi";
import { contracts } from "@/utils/constants";
import { DemoERC20Abi } from "@/abis/DemoERC20";

const Mint20 = () => {
  const { address } = useAccount();
  const { data: hash, writeContract } = useWriteContract();

  const handleClick = () => {
    if (!address) return;
    writeContract({
      address: contracts.FrogCoin as `0x${string}`,
      abi: DemoERC20Abi,
      functionName: "mint",
      args: [address, BigInt(100000000000000000)],
    });
  };

  return (
    <div>
      <p>Mint FrogCoin for free!</p>
      <button onClick={handleClick}>Mint</button>
    </div>
  );
};

export default Mint20;
