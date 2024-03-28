"use client";

import {
  useWriteContract,
  useWaitForTransactionReceipt,
  useAccount,
} from "wagmi";
import { contracts } from "@/utils/constants";
import { DemoERC721Abi } from "@/abis/DemoERC721";
import { Button } from "@/components/ui/button";

const Mint721 = () => {
  const { address } = useAccount();
  const { data: hash, writeContract } = useWriteContract();

  const handleClick = () => {
    if (!address) return;

    // get random int from 1 to 10000000
    // helps make sure we are minting different tokenIds
    // not something I would suggest doing IRL
    const tokenId = Math.floor(Math.random() * 10000000000);
    writeContract({
      address: contracts.FrogToken as `0x${string}`,
      abi: DemoERC721Abi,
      functionName: "mint",
      args: [address, BigInt(tokenId)],
    });
  };

  return (
    <Button onClick={handleClick} variant="outline">
      Mint 721
    </Button>
  );
};

export default Mint721;
