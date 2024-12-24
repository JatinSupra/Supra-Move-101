module deploy_addr::Dinosaur_Park {
    use supra_framework::event;
    use std::vector;

    struct DinosaurGendna has key {
        gendna_digits: u64,
        gendna_modulus: u64,
    }

    struct Dinosaur has key, store { 
        gendna: u64, 
    }

    #[event]
    struct SpawnDinosaurEvent has drop, store {
        gendna: u64,
    } 
    struct DinosaurSwarm has key {
        dinosaurs: vector<Dinosaur>,
    }

    fun init_module(cafe_signer: &signer) {
        let gendna_modulus = 10 ^ 10;
        move_to(cafe_signer, DinosaurGendna {
            gendna_digits: 10,
            gendna_modulus,
        });
        move_to(cafe_signer, DinosaurSwarm {
            dinosaurs: vector[],
        });
    }

    public fun spawn_Dinosaur(gendna: u64) acquires DinosaurSwarm {
        let dinosaur = Dinosaur {
            gendna,
        };
        let dinosaur_swarm = borrow_global_mut<DinosaurSwarm>(@deploy_addr);
        vector::push_back(&mut dinosaur_swarm.dinosaurs, dinosaur);

        event::emit(SpawnDinosaurEvent {
         gendna,
        });
    }

    public fun get_gendna_digits(): u64 acquires DinosaurGendna {
        borrow_global<DinosaurGendna>(@deploy_addr).gendna_digits
    }

    public fun set_gendna_digits(new_gendna_digits: u64) acquires DinosaurGendna {
        let dinosaur_Gendna = borrow_global_mut<DinosaurGendna>(@deploy_addr);
        dinosaur_Gendna.gendna_digits = new_gendna_digits;
    }

    public fun get_first_Dinosaur_Gendna(): u64 acquires DinosaurSwarm {
        let dinosaur_swarm = borrow_global<DinosaurSwarm>(@deploy_addr);
        let first_dinosaur: &Dinosaur = vector::borrow(&dinosaur_swarm.dinosaurs, 0);
        first_dinosaur.gendna
    }
}
