"use client";

import { useState, useEffect } from "react";
import { useReadContract, useAccount } from "wagmi";
import { contracts } from "@/utils/constants";
import { DemoERC20Abi } from "@/abis/DemoERC20";
import { DemoERC721Abi } from "@/abis/DemoERC721";
import { formatUnits } from "viem";

import Mint20 from "@/components/Mint20";
import Mint721 from "@/components/Mint721";
import Transfer20Dialog from "@/components/Transfer20Dialog";

const Wallet = ({
  type,
  address,
}: {
  type: "SWA" | "EOA";
  address: `0x${string}`;
}) => {
  const [isClient, setIsClient] = useState(false);

  useEffect(() => {
    setIsClient(true);
  }, []);

  const { address: loggedInAddress } = useAccount();
  const { data: erc20Balance } = useReadContract({
    abi: DemoERC20Abi,
    address: contracts.FrogCoin as `0x${string}`,
    functionName: "balanceOf",
    args: [address as `0x${string}`],
  });

  const { data: erc721Balance } = useReadContract({
    abi: DemoERC721Abi,
    address: contracts.FrogToken as `0x${string}`,
    functionName: "balanceOf",
    args: [address as `0x${string}`],
  });

  return (
    <div className="border rounded-lg p-4 flex flex-col bg-white">
      <h1 className="font-semibold text-2xl text-neutral-700">{type}</h1>
      <p className="mb-2 text-gray-400 text-xs">{address}</p>
      <span className="text-neutral-500 mt-2 mb-1">
        ERC20 balance: {!!erc20Balance ? formatUnits(erc20Balance, 18) : 0}
      </span>
      <span className="text-neutral-500">
        ERC721 balance: {!!erc721Balance ? erc721Balance.toString() : 0}
      </span>
      {isClient && loggedInAddress?.toLowerCase() === address.toLowerCase() && (
        <div className="mt-4 space-y-1 flex flex-col">
          <Mint20 />
          <Mint721 />
          <Transfer20Dialog />
          {/* <Transfer721 /> */}
        </div>
      )}
    </div>
  );
};

export default Wallet;
