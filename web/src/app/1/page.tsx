import Wallet from "@/components/Wallet";
import { contracts } from "@/utils/constants";

const PageOne = () => {
  return (
    <div className="flex flex-row space-x-4">
      <Wallet type="EOA" address="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" />
      <Wallet type="EOA" address="0x70997970C51812dc3A010C7d01b50e0d17dc79C8" />
      <Wallet type="SWA" address={contracts[1].Wallet as `0x${string}`} />
    </div>
  );
};

export default PageOne;
