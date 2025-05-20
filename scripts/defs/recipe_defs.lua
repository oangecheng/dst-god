


local NORMAL = {

    { 
        name = "gears",
        data = {
            tech = TECH.LOST,
            filter = {  "REFINE" },
            make = { 
                goldnugget = 5, 
                nightmarefuel = 3
            },
        }
    },

    {
        name = "uggem_piece",
        data = {
            tech = TECH.SCIENCE_TWO,
            filter = { "REFINE" },
            make = { goldnugget = 10 },
            res = {
                xml = "ugitems",
                img = "uggem_piece"
            }
        }
    },


    {
        name = "ugmagic_plant_energy",
        data = {
            tech = TECH.MAGIC_TWO,
            filter = { "REFINE" },
            -- tag = "ugpick_item_maker",
            make = {
                dug_grass = 1, seeds = 3, rock_avocado_fruit_sprout = 1, dug_sapling = 1 
            },
            res = {
                xml = "ugitems",
                img = "ugmagic_plant_energy",
            }

        }
    },

    {
        name = "ugmagic_meat_rack",
        data = {
            tech = TECH.MAGIC_TWO,
            filter = {  "REFINE" },
            -- tag = "cook_item_maker"
            make = { 
                charcoal = 4, twigs = 3, rope = 2 
            },
            res = { 
                xml = "ugitems", 
                img = "ugmagic_meat_rack" 
            }
        }
    }
}





local GEMS = {

}




return JoinArrays(NORMAL)