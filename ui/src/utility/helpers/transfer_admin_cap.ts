import { Transaction } from "@mysten/sui/transactions";

export const transferAdminCap = (adminCapId: string, to: string) => {
  const tx = new Transaction();

  tx.transferObjects([tx.object(adminCapId)], tx.pure.address(to));

  return tx;
};