#[test_only]
module hello_world::conditioning_tests {
    use sui::test_scenario as ts;
    use hello_world::collectioning::test_init;
    use hello_world::collectioning::CollectionOfUsers;
    use hello_world::collectioning::collection_size;
    use hello_world::collectioning;
    use hello_world::collectioning::add_user_to_collection_entry;
    use hello_world::collectioning::read_user;

    // test addr - basically for an admin
    const ADMIN: address = @0x1;

    #[test]
    fun test_init_test() {
        // let mut scenario = ts::begin(ADMIN);
        let mut scenario = ts::begin(ADMIN);

        // initiallize a module
        {
            ts::next_tx(&mut scenario, ADMIN);
            test_init(ts::ctx(&mut scenario));
        };

        // check of the collection is created
        {
            ts::next_tx(&mut scenario, ADMIN);
            assert!(ts::has_most_recent_for_sender<CollectionOfUsers>(&scenario), 0);
            let collection = ts::take_from_sender<CollectionOfUsers>(&scenario);
            assert!(collection_size(&collection) == 0, 1);
            ts::return_to_sender(&scenario, collection);
        };

        ts::end(scenario);


    }


    #[test]
    fun test_add_and_read_user_to_collection_entry() {
        let mut scenario = ts::begin(ADMIN);

        {
            ts::next_tx(&mut scenario, ADMIN);
            collectioning::test_init(ts::ctx(&mut scenario));
        };

        // add user
        {
            ts::next_tx(&mut scenario, ADMIN);
            let mut collection = ts::take_from_sender<CollectionOfUsers>(&scenario);

            add_user_to_collection_entry(
                &mut collection,
                std::string::utf8(b"mfoniso"),
                ts::ctx(&mut scenario)
            );

            ts::return_to_sender(&scenario, collection);
        };

        // read user
        {
            ts::next_tx(&mut scenario, ADMIN);
            let mut collection = ts::take_from_sender<CollectionOfUsers>(&scenario);

            let user = read_user(&collection, 0);
            let user_name = collectioning::get_user_name(user);
            let def_user = *user_name;

            assert!( def_user == std::string::utf8(b"mfoniso"), 2);

            ts::return_to_sender(&scenario, collection);

        };

        ts::end(scenario);
    }


}