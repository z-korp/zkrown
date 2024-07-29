import { Account, GetTransactionReceiptResponse } from "starknet";
import { toast } from "sonner";
import type { IWorld } from "./generated/contractSystems";
import { shortenHex } from "@dojoengine/utils";
import * as SystemTypes from "./generated/contractSystems";
import { ClientModels } from "./models";

export type SystemCalls = ReturnType<typeof systems>;

export function systems({
  client,
  clientModels,
}: {
  client: IWorld;
  clientModels: ClientModels;
}) {
  const TOAST_ID = "unique-id";

  const extractedMessage = (message: string) => {
    return message.match(/\('([^']+)'\)/)?.[1];
  };

  const isMdOrLarger = (): boolean => {
    return window.matchMedia("(min-width: 768px)").matches;
  };

  const isSmallHeight = (): boolean => {
    return window.matchMedia("(max-height: 768px)").matches;
  };

  const getToastAction = (transaction_hash: string) => {
    return {
      label: "View",
      onClick: () =>
        window.open(
          `https://worlds.dev/networks/slot/worlds/zkrown/txs/${transaction_hash}`,
        ),
    };
  };

  const getToastPlacement = ():
    | "top-center"
    | "bottom-center"
    | "bottom-right" => {
    if (!isMdOrLarger()) {
      // if mobile
      return isSmallHeight() ? "top-center" : "bottom-center";
    }
    return "bottom-right";
  };

  const toastPlacement = getToastPlacement();

  const notify = (message: string, transaction: any) => {
    if (transaction.execution_status !== "REVERTED") {
      toast.success(message, {
        id: TOAST_ID,
        description: shortenHex(transaction.transaction_hash),
        action: getToastAction(transaction.transaction_hash),
        position: toastPlacement,
      });
    } else {
      toast.error(extractedMessage(transaction.revert_reason), {
        id: TOAST_ID,
        position: toastPlacement,
      });
    }
  };

  const handleTransaction = async (
    account: Account,
    action: () => Promise<{ transaction_hash: string }>,
    successMessage: string,
  ): Promise<GetTransactionReceiptResponse | null> => {
    toast.loading("Transaction in progress...", {
      id: TOAST_ID,
      position: toastPlacement,
    });
    try {
      const { transaction_hash } = await action();
      toast.loading("Transaction in progress...", {
        description: shortenHex(transaction_hash),
        action: getToastAction(transaction_hash),
        id: TOAST_ID,
        position: toastPlacement,
      });

      const transaction = await account.waitForTransaction(transaction_hash, {
        retryInterval: 100,
      });

      notify(successMessage, transaction);

      return transaction;
    } catch (error: any) {
      toast.error(extractedMessage(error.message), { id: TOAST_ID });
      return null;
    }
  };

  const create = async ({ account, ...props }: SystemTypes.Create) => {
    await handleTransaction(
      account,
      () => client.play.create({ account, ...props }),
      "New game successfully created.",
    );
  };

  const join = async ({ account, ...props }: SystemTypes.Join) => {
    await handleTransaction(
      account,
      () => client.play.join({ account, ...props }),
      "You've successfully joined the game.",
    );
  };

  const promote = async ({ account, ...props }: SystemTypes.Promote) => {
    await handleTransaction(
      account,
      () => client.play.promote({ account, ...props }),
      "Player successfully promoted to host.",
    );
  };

  const leave = async ({ account, ...props }: SystemTypes.Leave) => {
    await handleTransaction(
      account,
      () => client.play.leave({ account, ...props }),
      "You've left the game successfully.",
    );
  };

  const kick = async ({ account, ...props }: SystemTypes.Kick) => {
    await handleTransaction(
      account,
      () => client.play.kick({ account, ...props }),
      "Player has been kicked from the game.",
    );
  };

  const remove = async ({ account, ...props }: SystemTypes.Remove) => {
    await handleTransaction(
      account,
      () => client.play.remove({ account, ...props }),
      "Game has been successfully deleted.",
    );
  };

  const start = async ({ account, ...props }: SystemTypes.Start) => {
    await handleTransaction(
      account,
      () => client.play.start({ account, ...props }),
      "The game has officially begun!",
    );
  };

  const claim = async ({ account, ...props }: SystemTypes.Claim) => {
    await handleTransaction(
      account,
      () => client.play.claim({ account, ...props }),
      "Token successfully claimed.",
    );
  };

  const surrender = async ({ account, ...props }: SystemTypes.Surrender) => {
    await handleTransaction(
      account,
      () => client.play.surrender({ account, ...props }),
      "You've surrendered the game.",
    );
  };

  const banish = async ({ account, ...props }: SystemTypes.Banish) => {
    await handleTransaction(
      account,
      () => client.play.banish({ account, ...props }),
      "Player has been banished from the game.",
    );
  };

  const attack = async ({ account, ...props }: SystemTypes.Attack) => {
    return await handleTransaction(
      account,
      () => client.play.attack({ account, ...props }),
      "Attack successfully executed.",
    );
  };

  const discard = async ({ account, ...props }: SystemTypes.Discard) => {
    await handleTransaction(
      account,
      () => client.play.discard({ account, ...props }),
      "Cards successfully discarded.",
    );
  };

  const finish = async ({ account, ...props }: SystemTypes.Finish) => {
    await handleTransaction(
      account,
      () => client.play.finish({ account, ...props }),
      "Current phase completed.",
    );
  };

  const transfer = async ({ account, ...props }: SystemTypes.Transfer) => {
    await handleTransaction(
      account,
      () => client.play.transfer({ account, ...props }),
      "Resources transferred successfully.",
    );
  };

  const supply = async ({ account, ...props }: SystemTypes.Supply) => {
    await handleTransaction(
      account,
      () => client.play.supply({ account, ...props }),
      "Supply action completed successfully.",
    );
  };

  const emote = async ({ account, ...props }: SystemTypes.Emote) => {
    await handleTransaction(
      account,
      () => client.play.emote({ account, ...props }),
      "Emote sent successfully.",
    );
  };

  return {
    create,
    join,
    leave,
    start,
    kick,
    promote, // "grant" in contract
    remove, // "delete" in contract
    claim,
    surrender,
    banish,
    attack,
    discard,
    finish,
    transfer,
    supply,
    emote,
  };
}
