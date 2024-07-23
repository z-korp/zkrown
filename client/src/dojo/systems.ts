import type { IWorld } from "./generated/contractSystems";

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
  const extractedMessage = (message: string) => {
    return message.match(/\('([^']+)'\)/)?.[1];
  };

  const notify = (message: string, transaction: any) => {
    if (transaction.execution_status != "REVERTED") {
      console.log(transaction.transaction_hash, message);
    } else {
      console.error(extractedMessage(transaction.revert_reason));
    }
  };

  const create = async ({ account, ...props }: SystemTypes.Create) => {
    try {
      const { transaction_hash } = await client.play.create({
        account,
        ...props,
      });

      notify(
        `Game has been created.`,
        await account.waitForTransaction(transaction_hash, {
          retryInterval: 100,
        }),
      );
    } catch (error: any) {
      console.error(extractedMessage(error.message));
    }
  };

  const join = async ({ account, ...props }: SystemTypes.Join) => {
    try {
      const { transaction_hash } = await client.play.join({
        account,
        ...props,
      });

      notify(
        `Game has been joined.`,
        await account.waitForTransaction(transaction_hash, {
          retryInterval: 100,
        }),
      );
    } catch (error) {
      console.error("Error joining game:", error);
    }
  };

  const promote = async ({ account, ...props }: SystemTypes.Promote) => {
    try {
      const { transaction_hash } = await client.play.promote({
        account,
        ...props,
      });

      notify(
        `Host role has been promoted.`,
        await account.waitForTransaction(transaction_hash, {
          retryInterval: 100,
        }),
      );
    } catch (error) {
      console.error("Error transferring ownership:", error);
    }
  };

  const leave = async ({ account, ...props }: SystemTypes.Leave) => {
    try {
      const { transaction_hash } = await client.play.leave({
        account,
        ...props,
      });

      notify(
        `Game has been left.`,
        await account.waitForTransaction(transaction_hash, {
          retryInterval: 100,
        }),
      );
    } catch (error) {
      console.error("Error leaving game:", error);
    }
  };

  const kick = async ({ account, ...props }: SystemTypes.Kick) => {
    try {
      const { transaction_hash } = await client.play.kick({
        account,
        ...props,
      });

      notify(
        `Player has been kicked.`,
        await account.waitForTransaction(transaction_hash, {
          retryInterval: 100,
        }),
      );
    } catch (error) {
      console.error("Error kicking player:", error);
    }
  };

  const remove = async ({ account, ...props }: SystemTypes.Remove) => {
    try {
      const { transaction_hash } = await client.play.remove({
        account,
        ...props,
      });

      notify(
        `Game has been deleted.`,
        await account.waitForTransaction(transaction_hash, {
          retryInterval: 100,
        }),
      );
    } catch (error) {
      console.error("Error deleting game:", error);
    }
  };

  const start = async ({ account, ...props }: SystemTypes.Start) => {
    try {
      const { transaction_hash } = await client.play.start({
        account,
        ...props,
      });

      notify(
        `Game has started.`,
        await account.waitForTransaction(transaction_hash, {
          retryInterval: 100,
        }),
      );
    } catch (error) {
      console.error("Error starting game:", error);
    }
  };

  const claim = async ({ account, ...props }: SystemTypes.Claim) => {
    try {
      const { transaction_hash } = await client.play.claim({
        account,
        ...props,
      });

      notify(
        `Game has been claimed.`,
        await account.waitForTransaction(transaction_hash, {
          retryInterval: 100,
        }),
      );
    } catch (error) {
      console.error("Error claiming game:", error);
    }
  };

  const surrender = async ({ account, ...props }: SystemTypes.Surrender) => {
    try {
      const { transaction_hash } = await client.play.surrender({
        account,
        ...props,
      });

      notify(
        `Player has surrendered.`,
        await account.waitForTransaction(transaction_hash, {
          retryInterval: 100,
        }),
      );
    } catch (error: any) {
      console.error(extractedMessage(error.message));
    }
  };

  const banish = async ({ account, ...props }: SystemTypes.Banish) => {
    try {
      const { transaction_hash } = await client.play.banish({
        account,
        ...props,
      });

      notify(
        `Player has been banished.`,
        await account.waitForTransaction(transaction_hash, {
          retryInterval: 100,
        }),
      );
    } catch (error: any) {
      console.error(extractedMessage(error.message));
    }
  };

  const attack = async ({ account, ...props }: SystemTypes.Attack) => {
    try {
      const { transaction_hash } = await client.play.attack({
        account,
        ...props,
      });

      notify(
        `Player has attacked.`,
        await account.waitForTransaction(transaction_hash, {
          retryInterval: 100,
        }),
      );
    } catch (error: any) {
      console.error(extractedMessage(error.message));
    }
  };

  const defend = async ({ account, ...props }: SystemTypes.Defend) => {
    try {
      const { transaction_hash } = await client.play.defend({
        account,
        ...props,
      });

      notify(
        `Player has defended.`,
        await account.waitForTransaction(transaction_hash, {
          retryInterval: 100,
        }),
      );
    } catch (error: any) {
      console.error(extractedMessage(error.message));
    }
  };

  const discard = async ({ account, ...props }: SystemTypes.Discard) => {
    try {
      const { transaction_hash } = await client.play.discard({
        account,
        ...props,
      });

      notify(
        `Player has discarded.`,
        await account.waitForTransaction(transaction_hash, {
          retryInterval: 100,
        }),
      );
    } catch (error: any) {
      console.error(extractedMessage(error.message));
    }
  };

  const finish = async ({ account, ...props }: SystemTypes.Finish) => {
    try {
      const { transaction_hash } = await client.play.finish({
        account,
        ...props,
      });

      notify(
        `Game has finished.`,
        await account.waitForTransaction(transaction_hash, {
          retryInterval: 100,
        }),
      );
    } catch (error: any) {
      console.error(extractedMessage(error.message));
    }
  };

  const transfer = async ({ account, ...props }: SystemTypes.Transfer) => {
    try {
      const { transaction_hash } = await client.play.transfer({
        account,
        ...props,
      });

      notify(
        `Player has transferred.`,
        await account.waitForTransaction(transaction_hash, {
          retryInterval: 100,
        }),
      );
    } catch (error: any) {
      console.error(extractedMessage(error.message));
    }
  };

  const supply = async ({ account, ...props }: SystemTypes.Supply) => {
    try {
      const { transaction_hash } = await client.play.supply({
        account,
        ...props,
      });

      notify(
        `Player has supplied.`,
        await account.waitForTransaction(transaction_hash, {
          retryInterval: 100,
        }),
      );
    } catch (error: any) {
      console.error(extractedMessage(error.message));
    }
  };

  const emote = async ({ account, ...props }: SystemTypes.Emote) => {
    try {
      const { transaction_hash } = await client.play.emote({
        account,
        ...props,
      });

      notify(
        `Player has emoted.`,
        await account.waitForTransaction(transaction_hash, {
          retryInterval: 100,
        }),
      );
    } catch (error: any) {
      console.error(extractedMessage(error.message));
    }
  };

  return {
    create,
    join,
    leave,
    start,
    kick,
    promote,
    remove,
    claim,
    surrender,
    banish,
    attack,
    defend,
    discard,
    finish,
    transfer,
    supply,
    emote,
  };
}
