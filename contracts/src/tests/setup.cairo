mod setup {
    // Core imports

    use core::debug::PrintTrait;

    // Starknet imports

    use starknet::ContractAddress;
    use starknet::testing::set_contract_address;

    // Dojo imports

    use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    // Internal imports

    use zkrown::tests::mocks::erc20::{
        IERC20Dispatcher, IERC20DispatcherTrait, IERC20FaucetDispatcher,
        IERC20FaucetDispatcherTrait, ERC20
    };
    use zkrown::types::config::{Config, ConfigTrait};
    use zkrown::models::game::Game;
    use zkrown::models::player::Player;
    use zkrown::models::tile::Tile;
    use zkrown::systems::play::{play, IHostDispatcher, IPlayDispatcher};

    // Constants

    fn HOST() -> ContractAddress {
        starknet::contract_address_const::<'HOST'>()
    }

    fn PLAYER() -> ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    fn ANYONE() -> ContractAddress {
        starknet::contract_address_const::<'ANYONE'>()
    }

    #[derive(Drop)]
    struct Systems {
        host: IHostDispatcher,
        play: IPlayDispatcher,
    }

    #[derive(Drop)]
    struct Context {
        erc20: IERC20Dispatcher,
        config: Config,
    }

    fn deploy_erc20() -> IERC20Dispatcher {
        let (address, _) = starknet::deploy_syscall(
            ERC20::TEST_CLASS_HASH.try_into().expect('Class hash conversion failed'),
            0,
            array![].span(),
            false
        )
            .expect('ERC20 deploy failed');
        IERC20Dispatcher { contract_address: address }
    }

    fn spawn_game() -> (IWorldDispatcher, Systems, Context) {
        // [Setup] World
        let mut models = core::array::ArrayTrait::new();
        models.append(zkrown::models::index::game::TEST_CLASS_HASH);
        models.append(zkrown::models::index::player::TEST_CLASS_HASH);
        models.append(zkrown::models::index::tile::TEST_CLASS_HASH);
        let world = spawn_test_world(models);
        let erc20 = deploy_erc20();

        // [Setup] Systems
        let calldata: Array<felt252> = array![erc20.contract_address.into(),];
        let contract_address = world
            .deploy_contract('play', play::TEST_CLASS_HASH.try_into().unwrap(), calldata.span());
        let systems = Systems {
            host: IHostDispatcher { contract_address: contract_address },
            play: IPlayDispatcher { contract_address: contract_address },
        };

        // [Setup] Context
        let context = Context { erc20, config: Config::Test };
        let faucet = IERC20FaucetDispatcher { contract_address: erc20.contract_address };
        set_contract_address(ANYONE());
        faucet.mint();
        erc20.approve(contract_address, ERC20::FAUCET_AMOUNT);
        set_contract_address(PLAYER());
        faucet.mint();
        erc20.approve(contract_address, ERC20::FAUCET_AMOUNT);
        set_contract_address(HOST());
        faucet.mint();
        erc20.approve(contract_address, ERC20::FAUCET_AMOUNT);

        // [Return]
        (world, systems, context)
    }
}
