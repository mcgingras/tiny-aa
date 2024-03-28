"use client";

import { useWriteContract, useWaitForTransactionReceipt } from "wagmi";
import { contracts } from "@/utils/constants";
import { DemoERC20Abi } from "@/abis/DemoERC20";

const Transfer20 = () => {
  const { data: hash, writeContract } = useWriteContract();

  const handleClick = () => {
    writeContract({
      address: contracts.FrogCoin as `0x${string}`,
      abi: DemoERC20Abi,
      functionName: "transfer",
      args: [
        "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
        BigInt(1000000000000000000),
      ],
    });
  };

  return (
    <button
      onClick={handleClick}
      className="border px-2 py-1 rounded-lg text-neutral-600 hover:bg-neutral-100 transition-colors cursor-pointer"
    >
      Transfer 20
    </button>
  );
};

export default Transfer20;
