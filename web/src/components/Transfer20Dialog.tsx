"use client";

import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useWriteContract, useWaitForTransactionReceipt } from "wagmi";
import { contracts } from "@/utils/constants";
import { DemoERC20Abi } from "@/abis/DemoERC20";
import { useForm } from "react-hook-form";

export default function Transfer20Dialog() {
  const { data: hash, writeContract } = useWriteContract();

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm({
    defaultValues: {
      recipient: "",
      amount: "0",
    },
  });

  const onSubmit = async (data: { recipient: string; amount: string }) => {
    writeContract({
      address: contracts.FrogCoin as `0x${string}`,
      abi: DemoERC20Abi,
      functionName: "transfer",
      args: [data.recipient as `0x${string}`, BigInt(data.amount)],
    });
  };

  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button variant="outline">Transfer 20s</Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Transfer 20s</DialogTitle>
          <DialogDescription>
            Transfer frog ERC20 tokens to another address.
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit(onSubmit)}>
          <div className="grid gap-4 py-4">
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="amount" className="text-right">
                Amount
              </Label>
              <Input
                id="amount"
                defaultValue="1000000000000000000"
                className="col-span-3"
                {...register("amount")}
              />
            </div>
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="recipient" className="text-right">
                Recipient
              </Label>
              <Input
                id="recipient"
                defaultValue="0x"
                className="col-span-3"
                {...register("recipient")}
              />
            </div>
          </div>
          <DialogFooter>
            <Button type="submit">Send</Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
