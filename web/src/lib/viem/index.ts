import { createWalletClient, http } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { anvil } from "viem/chains";

const executor = privateKeyToAccount(
  process.env.PRIVATE_KEY_3 as `0x${string}`
);

/**
 * Wallet client
 * This is to be used as the "executor" that submits userOps for the wallet
 * Could also be considered the EOA for the "bundler"
 */
export const client = createWalletClient({
  account: executor,
  chain: anvil,
  transport: http(),
});
