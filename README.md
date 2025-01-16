# Move 101 with Supra

Move code is organized into modules that are uploaded to the Supra blockchain. Users can interact with the modules by calling functions from these modules via transactions. Modules are grouped into packages. When uploading code to the blockchain, an entire package of multiple modules will be uploaded.

Each Move module has a unique identifier comprising the address it's deployed at and the module name. The fully qualified name is of the format `<address>::<module_name>`

```move
module 0xcafe::Dinosaur_nest {
}
```
#### We'll create a DinosaurNest contract with the following features:

Keep track of all the Dinosaurs it has spawned.
Birth new Dinosaurs via a function
We'll generate a special Gendna code every time a Dinosaur is spawned to create a unique genetics for each Dinosaur. The special abilities genetic code has digits and looks like below:
`
1234567890
`

This special Gendna code represents each Dinosaur's unique attributes, with each 2 digits representing one, such as shirts, hats, and glasses. Later, you can have more fun and add new attributes by adding more digits to the special abilities code.

Let's start by adding a number to track the number of digits allowed in a Gendna code. This number will be stored on the blockchain (global storage). This data can be accessed and changed by the module's code as well as read by web UI.

On Supra, all data written to blockchain needs to be declared in a struct that has the key attribute. For now, take a look at the simple example below:

```
module 0xcafe::Dinosaur_nest {
    // All structs that are written to blockchain need to have the `key` attribute.
    struct DinosaurGendna has key {
        Gendna_digits: u64,
    }   
}
```
In the example above, we're storing a simple value (`Gendna_digits`) in global storage. This value can be read in functions later. One common confusion is between global storage and local variables. Unless explicitly declared in a `struct` with the `key` attribute, all variables declared and modified in a function are local variables and thus not stored on the blockchain (in global storage). Also note that the struct name is capitalized by convention (`DinosaurGendna` instead of `Dinosaur_Gendna`).

## Unsigned Integers: u8, u32, u64, u128, u256

Move supports multiple different types of unsigned integers. The values of these integers are always zero or larger. The different types of integers have different maximum values they can store. For example, `u8` can store values up to 255, while `u256` can store values up to 2^256 - 1. The most commonly used integer type is `u64`. Smaller types such as `u8` and `u32` are usually only used to save on gas (less storage space used). Larger sizes such as `u128` and `u256` are only used for when you need to store very large numbers.

Now that we have defined the `DinosaurGendna` struct, we need to set its initial value. We can’t set the initial value directly when defining a `struct`, so we'll need to create a function to do that. Recall that structs can be stored directly in global storage on Supra. Structs stored in global storage are called Resources. Each Resource needs to be stored at a specific address. This can be the same address where the module is deployed or any other user address. This is different from other blockchains - code and data can coexist at the same address on Supra. For our `Dinosaur_nest module`, we'll keep it simple and store the `DinosaurGendna` resource at the same address as the module. Let’s initialize it by writing the `init_module` function, where we get access to the signer of the address we're deploying to. `init_module` is called when the module is deployed to the blockchain and is the perfect place for initializing data. Don't worry about what a signer is for now - we'll cover that in later lessons. You just need to know that signer is required to create and store a new resource at an address the first time.

Moving on with our code:
```
module 0xcafe::Dinosaur_nest {
    struct DinosaurGendna has key {
        Gendna_digits: u64,
    }
    
    fun init_module(cafe_signer: &signer) {
        move_to(cafe_signer, DinosaurGendna {
            Gendna_digits: 10,
        });
    }
}
```
In the example above, we're creating a new `DinosaurGendna` resource with a default value (`Gendna_digits`) of 10 (our Gendna Value as shared earlier) and storing it at 0xcafe (same address as the module) with `move_to`.

`move_to is` a special function that requires a signer that can be called to store a resource at a specific address.

## Math in Move

Doing math in Move is easy and very similar to other programming languages:

- Add: `x + y`
- Subtract: `x - y`
- Multiply: `x * y`
- Divide: `x / y`
- Mod: `x % y`
- Exponential: `x ^ y`

Note that this is integer math, which means results are rounded down. For example, `5 / 2 = 2`

To make sure our Dinosaur's Gendna is only 10 digits, let's make another `u64` value equal to 10^10. That way we can later use the modulus operator `%` to create valid Gendna codes from any randomly generated numbers. 

Create another integer value named `Gendna_modulus` in the DinosaurGendna struct, and set it equal to 10 to the power of `Gendna_digits` :

```
module 0xcafe::Dinosaur_nest {
    struct DinosaurGendna has key {
        Gendna_digits: u64,
        Gendna_modulus: u64, 
    }

    fun init_module(cafe_signer: &signer) {
        move_to(cafe_signer, DinosaurGendna {
            Gendna_digits: 10,
            Gendna_modulus: 10 ^ 10,
        });
    }
}
```

### Wanna make it interesting?

So far we've seen different types of integers: `u8`, `u32`, `u64`, `u128`, `u256`. Although math can be done easily among integers of the same type, it's not possible to do math directly between integers of different types, 

EXAMPLE APPROACH BELOW

```
fun mixed_types_math(): u64 {
    let x: u8 = 1;
    let y: u64 = 2;
    // This will fail to compile as x and y are different types. One is u8, the other is u64.
    x + y
}
```

-> **Let’s cast Gendna_modulus to u256 with (Gendna_modulus as u256). Remember that the parentheses () are required when typecasting, EXAMPLE BELOW**

```
fun mixed_types_math(): u64 {
    let x: u8 = 1;
    let y: u64 = 2;
    // This will fail to compile as x and y are different types. One is u8, the other is u64.
    (x as u64) + y
}
```
-> **The actual contract would look like this:**

```
module 0xcafe::Dinosaur_nest {
    struct DinosaurGendna has key {
        Gendna_digits: u64,
        Gendna_modulus: u256,
    }

    fun init_module(cafe_signer: &signer) {
        let Gendna_digits = 10;
        let Gendna_modulus = 10 ^ Gendna_digits;
        move_to(cafe_signer, DinosaurGendna {
            Gendna_digits,
            Gendna_modulus: (Gendna_modulus as u256),
        });
    }
}
```

## Vectors
When you want a list of values, use vectors. A `vector` in Move is dynamic by default and has no fixed size. It can get larger or smaller as needed. Vector in Supra and Aptos are available to import and use at `std::vector`. 

You just need to do “`use std::vector`” at the top of your module to be able to access it.

You can also store structs in vectors, Note that for structs that are stored in a resource struct, you need to add the store attribute to the struct, **for example**:
```
    struct Balance has store {
        owner: address,
        balance: u64,
    }

    struct GlobalData has key {
        balances: vector<Balance>,
    }
 ```

When creating an empty vector you can use the following syntax:
```let empty_vector = vector[];```

We need to track all the Dinosaurs created from Dinosaur_nest, We can do this by declaring two new structs: 

`Dinosaur` Struct having Key and a new resource struct named `DinosaurSwarm` which has a vector of Dinosaur structs, this resource needs to be stored at `0xcafe` in `init_module` with an empty vector of Dinosaurs to start with.

**Code Follows like:**

```
module 0xcafe::Dinosaur_nest {
   use std::vector;

    struct DinosaurGendna has key {
        Gendna_digits: u64,
        Gendna_modulus: u256,
    }

    struct Dinosaur has store {
        Gendna: u64,
    }
    
    struct DinosaurSwarm has store {
        Dinosaurs: vector<Dinosaur>,
    }

    fun init_module(cafe_signer: &signer) {
        let Gendna_digits = 10;
        let Gendna_modulus = 10 ^ Gendna_digits;
        move_to(cafe_signer, DinosaurGendna {
            Gendna_digits,
            Gendna_modulus: (Gendna_modulus as u256),
        });
    move_to(cafe_signer, DinosaurSwarm {
            Dinosaurs: vector[],
        });    
        
    }
}
```

We've only been using the `init_module` function, which is called when the module is deployed to initialize default values. we'll create one more function that will later be called by the user to create a new Dinosaur.

**-> Let’s create a new function named `spawn_Dinosaur` that takes one argument of type `u64` named `Gendna` and returns a Dinosaur struct with that Gendna:**

**NOTE:** this function is public, which means it can be called from any other Move module. we'll keep all functions public, except for init_module. init_module has to be private because it's called only once when the module is deployed.

```
module 0xcafe::Dinosaur_nest {
    use std::vector;

    struct DinosaurGendna has key {
        Gendna_digits: u64,
        Gendna_modulus: u64,
    }

    struct Dinosaur has store {
        Gendna: u64,
    }

    struct DinosaurSwarm has key {
        Dinosaurs: vector<Dinosaur>,
    }

    fun init_module(cafe_signer: &signer) {
        let Gendna_digits = 10;
        let Gendna_modulus = 10 ^ Gendna_digits;
        move_to(cafe_signer, DinosaurGendna {
            Gendna_digits,
            Gendna_modulus: (Gendna_modulus as u256),
        });
        move_to(cafe_signer, DinosaurSwarm {
            Dinosaurs: vector[],
        });
    }
     
public fun spawn_Dinosaur(Gendna: u64): Dinosaur {
    Dinosaur {
            Gendna,
        } 
}
}
```
## `borrow_global`: read an existing resource struct

We just need to call `borrow_global` with the right resource type and address. The address can be passed into the function as an argument or referred to specifically with @ such as `@0xcafe`. A signer is not required here. If the resource is not found at the address, the function will error out when the code is run on the blockchain. The function that calls `borrow_global` also needs to declare that it does so by adding “`acquires ResourceName`” at the end. 

**-> Let’s write a new function named get_Gendna_digits that returns the Gendna_digits field of the DinosaurGendna resource stored at 0xcafe:**
```
module 0xcafe::Dinosaur_nest {
    use std::vector;

    struct DinosaurGendna has key {
        Gendna_digits: u64,
        Gendna_modulus: u64,
    }

    struct Dinosaur has store {
        Gendna: u64,
    }

    struct DinosaurSwarm has key {
        Dinosaurs: vector<Dinosaur>,
    }

    fun init_module(cafe_signer: &signer) {
        let Gendna_digits = 10;
        let Gendna_modulus = 10 ^ Gendna_digits;
        move_to(cafe_signer, DinosaurGendna {
            Gendna_digits,
            Gendna_modulus: (Gendna_modulus as u256),
        });
        move_to(cafe_signer, DinosaurSwarm {
            Dinosaurs: vector[],
        });
    }

    public fun spawn_Dinosaur(Gendna: u64): Dinosaur {
        Dinosaur {
            Gendna,
        }
    }

public fun get_Gendna_digits(): u64 acquires DinosaurGendna {
borrow_global<DinosaurGendna>(@0xcafe).Gendna_digits
}
}
```

## pass-by-value & pass-by-reference

In Move, when you pass a simple value as u64 to a function, you might be making a copy of it. This is called pass-by-value, **FOR EXAMPLE:**

```
fun add_one(value: u64) {
    // This doesn't change the original value!
    value = value + 1;
}

fun call_add_one() {
    let value = 10;
    // This is wrong as it makes a copy of value!
    add_one(value);

    // This will error out as the value is still 10!
    assert!(value == 11, 0);
}
```

**So how do we modify the original value?**

We need to pass a mut reference (`&mut`) to the value instead of the value itself. This is called pass-by-reference. This is similar to how you pass a pointer to a value in C/C++ or Rust.

There are two types of references in Move: `references` (&) and `mutable references` (&mut). The immutable reference (&) is often used to pass a value such as vector to a function that only intends to read data instead of writing it. A function that takes a reference needs to explicitly declare so: **FOR EXAMPLE**

```
// get_first_element takes a reference to a vector and returns the first element.
fun get_first_element(values: &vector<u64>): u64 {
    // vector::borrow also takes a vector reference and returns a reference to the value.
    // * is needed here to dereference the value and make a copy of it to return.
    *vector::borrow(values, 0)
}
```
You can also pass a reference to a struct and modify it: **FOR EXAMPLE**

```
struct Balance {
    value: u64,
}

// This would fail if the function takes &Balance instead of &mut Balance.
fun double_balance(balance: &mut Balance): u64 {
    balance.value = balance.value * 2;
}
``` 

**-> Now, Write a function in `Dinosaur_nest` that returns the `Gendna` of the first Dinosaur in the `DinosaurSwarm`. Don’t forget the “`acquires`” declaration!**

```
module 0xcafe::Dinosaur_nest {
    use std::vector;

    struct DinosaurGendna has key {
        Gendna_digits: u64,
        Gendna_modulus: u64,
    }

    struct Dinosaur has store {
        Gendna: u64,
    }

    struct DinosaurSwarm has key {
        Dinosaurs: vector<Dinosaur>,
    }

    fun init_module(cafe_signer: &signer) {
        let Gendna_digits = 10;
        let Gendna_modulus = 10 ^ Gendna_digits;
        move_to(cafe_signer, DinosaurGendna {
            Gendna_digits,
            Gendna_modulus: (Gendna_modulus as u256),
        });
        move_to(cafe_signer, DinosaurSwarm {
            Dinosaurs: vector[],
        });
    }

    public fun spawn_Dinosaur(Gendna: u64): Dinosaur {
        Dinosaur {
            Gendna,
        }
    }

    public fun get_Gendna_digits(): u64 acquires DinosaurGendna {
        borrow_global<DinosaurGendna>(@0xcafe).Gendna_digits
    }

    public fun set_Gendna_digits(new_Gendna_digits: u64) acquires DinosaurGendna {
        let Dinosaur_Gendna = borrow_global_mut<DinosaurGendna>(@0xcafe);
        Dinosaur_Gendna.Gendna_digits = new_Gendna_digits;
    }

public fun get_first_Dinosaur_Gendna(): u64 acquires DinosaurSwarm {
        let Dinosaur_swarm = borrow_global<DinosaurSwarm>(@0xcafe);    
        let first_Dinosaur = vector::borrow(&Dinosaur_swarm.Dinosaurs, 0);
        first_Dinosaur.Gendna        
}
}
```

## `vector::push_back`: add all the things we've learned

We can add all the things we've learned so far to create a more complex module. One more thing you can do now that you know references: You can add an element to a vector using `vector::push_back` and pass a mutable reference to the vector.

-> **Let’s Modify `spawn_Dinosaur` to add the new Dinosaur to the DinosaurSwarm's vector of Dinosaurs instead of returning it.**

```
module 0xcafe::Dinosaur_nest {
    use std::vector;

    struct DinosaurGendna has key {
        Gendna_digits: u64,
        Gendna_modulus: u64,
    }

    struct Dinosaur has store {
        Gendna: u64,
    }

    struct DinosaurSwarm has key {
        Dinosaurs: vector<Dinosaur>,
    }

    fun init_module(cafe_signer: &signer) {
        let Gendna_digits = 10;
        let Gendna_modulus = 10 ^ Gendna_digits;
        move_to(cafe_signer, DinosaurGendna {
            Gendna_digits,
            Gendna_modulus: (Gendna_modulus as u256),
        });
        move_to(cafe_signer, DinosaurSwarm {
            Dinosaurs: vector[],
        });
    }

    public fun spawn_Dinosaur(Gendna: u64) acquires DinosaurSwarm {
        let Dinosaur = Dinosaur {
            Gendna,
        };
        let Dinosaur_swarm = borrow_global_mut<DinosaurSwarm>(@0xcafe);
        vector::push_back(&mut Dinosaur_swarm.Dinosaurs, Dinosaur);
          }

    public fun get_Gendna_digits(): u64 acquires DinosaurGendna {
        borrow_global<DinosaurGendna>(@0xcafe).Gendna_digits
    }

    public fun set_Gendna_digits(new_Gendna_digits: u64) acquires DinosaurGendna {
        let Dinosaur_Gendna = borrow_global_mut<DinosaurGendna>(@0xcafe);
        Dinosaur_Gendna.Gendna_digits = new_Gendna_digits;
    }

    public fun get_first_Dinosaur_Gendna(): u64 acquires DinosaurSwarm {
        let Dinosaur_swarm = borrow_global<DinosaurSwarm>(@0xcafe);
        let first_Dinosaur = vector::borrow(&Dinosaur_swarm.Dinosaurs, 0);
        first_Dinosaur.Gendna
    }
}
```

## `Event::Emit` 

Events are a way for your contract to communicate that something happened on the blockchain to your app front-end, which can be 'listening' for certain events and take action when they happen.

In order to emit an event, you need to do three things:
- Define the event struct.
- Use ` event::emit`  to emit it

**Note:** Event structs need to be declared with the `#[event]` annotation.

**-> FINALLY, Let's add an event named `SpawnDinosaurEvent` that contains the new Gendna code & Emit `SpawnDinosaurEvent` when a Dinosaur is created.**

```
module 0xcafe::Dinosaur_nest {
    use supra_framework::account;
    use supra_framework::event;
   use std::vector;

    struct DinosaurGendna has key {
        Gendna_digits: u64,
        Gendna_modulus: u64,
    }

    struct Dinosaur has store {
        Gendna: u64,
    }

    #[event]
    struct SpawnDinosaurEvent has drop, store {
        Gendna: u64,
    } 
    struct DinosaurSwarm has key {
        Dinosaurs: vector<Dinosaur>,
    }

    fun init_module(cafe_signer: &signer) {
        let Gendna_modulus = 10 ^ 10;
        move_to(cafe_signer, DinosaurGendna {
            Gendna_digits: 10,
            Gendna_modulus,
        });
        move_to(cafe_signer, DinosaurSwarm {
            Dinosaurs: vector[],
        });
    }

    fun spawn_Dinosaur(Gendna: u64) acquires DinosaurSwarm {
        let Dinosaur = Dinosaur {
            Gendna,
        };
        let Dinosaur_swarm = borrow_global_mut<DinosaurSwarm>(@0xcafe);
        vector::push_back(&mut Dinosaur_swarm.Dinosaurs, Dinosaur);

        event::emit(SpawnDinosaurEvent {
         Gendna,
        });
    }

    public fun get_Gendna_digits(): u64 acquires DinosaurGendna {
        borrow_global<DinosaurGendna>(@0xcafe).Gendna_digits
    }

    public fun set_Gendna_digits(new_Gendna_digits: u64) acquires DinosaurGendna {
        let Dinosaur_Gendna = borrow_global_mut<DinosaurGendna>(@0xcafe);
        Dinosaur_Gendna.Gendna_digits = new_Gendna_digits;
    }

    public fun get_first_Dinosaur_Gendna(): u64 acquires DinosaurSwarm {
        let Dinosaur_swarm = borrow_global<DinosaurSwarm>(@0xcafe);
        let first_Dinosaur = vector::borrow(&Dinosaur_swarm.Dinosaurs, 0);
        first_Dinosaur.Gendna
    }
}
```

## Wrapping up,
Till now you must have gotten a good Idea of how things get Build and How Logic works in MOVE. You can find the Move.toml and Source File in the repo, fort it and run in your side to get a hands on and learn with building your version of the Move Module as well.

## Contribution
Feel free to contribute to this project by submitting pull requests or opening issues, all contributions that enhance the functionality or user experience of this project are welcome.
