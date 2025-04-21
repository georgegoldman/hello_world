module hello_world::collectioning {
    use std::string::String;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::vector;

    // Removed unused constant
    // const USER1: address = @0x123;

    public struct User has key, store {
        id: UID,
        name: String
    }

    public struct CollectionOfUsers has key, store {
        id: UID,
        users: vector<User>
    }

    // Initialize the module
    fun init(ctx: &mut TxContext) {
        let new_user_collection = CollectionOfUsers {
            id: object::new(ctx),
            users: vector::empty()
        };
        transfer::transfer(new_user_collection, tx_context::sender(ctx));
    }

    // Test-only version of init for test access
    // note just included this 
    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx)
    }

    // Create user - internal function
    fun create_user(ctx: &mut TxContext, name: String): User {
        User {
            id: object::new(ctx),
            name
        }
    }

    // Add user to collection - entry function
    public entry fun add_user_to_collection_entry(
        the_collection: &mut CollectionOfUsers, 
        name: String,
        ctx: &mut TxContext
    ) {
        let user = create_user(ctx, name);
        vector::push_back(&mut the_collection.users, user);
    }

    // Add user to collection (internal method)
    public fun add_user_to_collection(user: User, the_collection: &mut CollectionOfUsers) {
        vector::push_back(&mut the_collection.users, user);
    }

    // Read user
    public fun read_user(the_collection: &CollectionOfUsers, index: u64): &User {
        vector::borrow(&the_collection.users, index)
    }

    // Get user name - useful for tests
    public fun get_user_name(user: &User): &String {
        &user.name
    }

    // Get collection size
    public fun collection_size(the_collection: &CollectionOfUsers): u64 {
        vector::length(&the_collection.users)
    }

    // Update user
    public entry fun update_user(
        new_name: String, 
        the_collection: &mut CollectionOfUsers, 
        index: u64
    ) {
        let user = vector::borrow_mut(&mut the_collection.users, index);
        user.name = new_name;
    }

    // Delete user
    public entry fun delete_user(
        index: u64, 
        the_collection: &mut CollectionOfUsers
    ) {
        let user = vector::remove(&mut the_collection.users, index);
        let User { id, name: _ } = user;
        object::delete(id);
    }
}