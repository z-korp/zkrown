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
      "Game has been created.",
    );
  };

  const join = async ({ account, ...props }: SystemTypes.Join) => {
    await handleTransaction(
      account,
      () => client.play.join({ account, ...props }),
      "Game has been joined.",
    );
  };

  const promote = async ({ account, ...props }: SystemTypes.Promote) => {
    await handleTransaction(
      account,
      () => client.play.promote({ account, ...props }),
      "Host role has been promoted.",
    );
  };

  const leave = async ({ account, ...props }: SystemTypes.Leave) => {
    await handleTransaction(
      account,
      () => client.play.leave({ account, ...props }),
      "Game has been left.",
    );
  };

  const kick = async ({ account, ...props }: SystemTypes.Kick) => {
    await handleTransaction(
      account,
      () => client.play.kick({ account, ...props }),
      "Game has been left.",
    );
  };

  const remove = async ({ account, ...props }: SystemTypes.Remove) => {
    await handleTransaction(
      account,
      () => client.play.remove({ account, ...props }),
      "Game has been deleted.",
    );
  };

  const start = async ({ account, ...props }: SystemTypes.Start) => {
    await handleTransaction(
      account,
      () => client.play.start({ account, ...props }),
      "Game has started.",
    );
  };

  const claim = async ({ account, ...props }: SystemTypes.Claim) => {
    await handleTransaction(
      account,
      () => client.play.claim({ account, ...props }),
      "Game has been claimed.",
    );
  };

  const surrender = async ({ account, ...props }: SystemTypes.Surrender) => {
    await handleTransaction(
      account,
      () => client.play.surrender({ account, ...props }),
      "Player has surrendered.",
    );
  };

  const banish = async ({ account, ...props }: SystemTypes.Banish) => {
    await handleTransaction(
      account,
      () => client.play.banish({ account, ...props }),
      "Player has been banished.",
    );
  };

  const attack = async ({ account, ...props }: SystemTypes.Attack) => {
    return await handleTransaction(
      account,
      () => client.play.attack({ account, ...props }),
      "Player has attacked.",
    );
  };

  const discard = async ({ account, ...props }: SystemTypes.Discard) => {
    await handleTransaction(
      account,
      () => client.play.discard({ account, ...props }),
      "Player has discarded.",
    );
  };

  const finish = async ({ account, ...props }: SystemTypes.Finish) => {
    await handleTransaction(
      account,
      () => client.play.finish({ account, ...props }),
      "Game has finished.",
    );
  };

  const transfer = async ({ account, ...props }: SystemTypes.Transfer) => {
    await handleTransaction(
      account,
      () => client.play.transfer({ account, ...props }),
      "Player has transferred.",
    );
  };

  const supply = async ({ account, ...props }: SystemTypes.Supply) => {
    await handleTransaction(
      account,
      () => client.play.supply({ account, ...props }),
      "Player has supplied.",
    );
  };

  const emote = async ({ account, ...props }: SystemTypes.Emote) => {
    await handleTransaction(
      account,
      () => client.play.emote({ account, ...props }),
      "Player has emoted.",
    );
  };

  return {
    create,
    join,
    leave,
    start,
    kick,
    promote, // grant in contract
    remove, // delect in contract
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
