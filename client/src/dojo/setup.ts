import { getSyncEntities } from "@dojoengine/state";
import { DojoProvider } from "@dojoengine/core";
import * as torii from "@dojoengine/torii-client";
import { createClientComponents } from "./createClientComponents";
import { defineContractComponents } from "./generated/contractComponents";
import { setupWorld } from "./generated/contractSystems.ts";
import { systems } from "./systems.ts";
import { world } from "./world";
import { Config } from "../../dojo.config.ts";
import { Account, RpcProvider } from "starknet";
import { BurnerManager } from "@dojoengine/create-burner";
import { createUpdates } from "./createUpdates";

export type SetupResult = Awaited<ReturnType<typeof setup>>;

export async function setup({ ...config }: Config) {
  // torii client
  const toriiClient = await torii.createClient([], {
    rpcUrl: config.rpcUrl,
    toriiUrl: config.toriiUrl,
    relayUrl: "",
    worldAddress: config.manifest.world.address || "",
  });

  // create contract components
  const contractComponents = defineContractComponents(world);

  // create client components
  const clientComponents = createClientComponents({ contractComponents });

  // create updates manager
  const updates = await createUpdates(clientComponents);

  // fetch all existing entities from torii
  const sync = await getSyncEntities(
    toriiClient,
    contractComponents as any,
    []
  );

  const client = await setupWorld(
    new DojoProvider(config.manifest, config.rpcUrl),
    config
  );

  const rpcProvider = new RpcProvider({
    nodeUrl: config.rpcUrl,
  });

  const burnerManager = new BurnerManager({
    masterAccount: new Account(
      rpcProvider,
      config.masterAddress,
      config.masterPrivateKey
    ),
    feeTokenAddress: config.feeTokenAddress,
    accountClassHash: config.accountClassHash,

    rpcProvider,
  });

  try {
    await burnerManager.init();
    if (burnerManager.list().length === 0) {
      await burnerManager.create();
    }
  } catch (e) {
    console.error(e);
  }

  return {
    client,
    clientComponents,
    contractComponents,
    systemCalls: systems({ client, clientComponents }),
    config,
    updates,
    world,
    burnerManager,
    rpcProvider,
    sync,
  };
}
