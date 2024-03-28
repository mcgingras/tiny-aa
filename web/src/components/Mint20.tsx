"use client";

import {
  useReadContract,
  useWriteContract,
  useWaitForTransactionReceipt,
  useAccount,
} from "wagmi";
import { contracts } from "@/utils/constants";
import { DemoERC20Abi } from "@/abis/DemoERC20";
import { Button } from "@/components/ui/button";
import { Loader2 } from "lucide-react";

const Mint20 = () => {
  const { address } = useAccount();
  const { data: hash, writeContract } = useWriteContract();

  const { refetch } = useReadContract({
    abi: DemoERC20Abi,
    address: contracts.FrogCoin as `0x${string}`,
    functionName: "balanceOf",
    args: [address as `0x${string}`],
  });

  const handleClick = () => {
    if (!address) return;
    writeContract(
      {
        address: contracts.FrogCoin as `0x${string}`,
        abi: DemoERC20Abi,
        functionName: "mint",
        args: [address, BigInt(1000000000000000000)],
      },
      { onSuccess: () => refetch() }
    );
  };

  const { isLoading } = useWaitForTransactionReceipt({ hash });

  return (
    <>
      <Button onClick={handleClick} variant="outline" disabled={isLoading}>
        {isLoading ? (
          <>
            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
            <span>Minting</span>
          </>
        ) : (
          "Mint 20"
        )}
      </Button>
    </>
  );
};

export default Mint20;
