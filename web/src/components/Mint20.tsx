"use client";

import { useWriteContract, useWaitForTransactionReceipt } from "wagmi";

const Mint20 = () => {
  const { data: hash, writeContract } = useWriteContract();
  const handleClick = () => {
    // writeContract
  };
  return (
    <div>
      <p>Mint FrogCoin for free!</p>
      <button onClick={handleClick}>Mint</button>
    </div>
  );
};

export default Mint20;
