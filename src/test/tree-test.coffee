vows = require "vows"
assert = require "assert"

Land = require "../server/classes/land"
World = require "../server/classes/world"
Tree = require "../server/classes/tree"

world = new World()
vows.describe("Tree").addBatch
    "A Tree":
        topic: new Tree
            x: 0
            y: 0
            z: 1
        , world
        "has nutrients": (tree) ->
            assert.isNumber tree.phosphorus
            assert.isNumber tree.potassium
            assert.isNumber tree.nitrogen

        "can eat":
            topic: (tree) ->
                # Get rid of the eat timeout
                clearTimeout tree.eater
                tree.once "change:view", =>
                     tree.doEat()

                tree.on "change:phosphorus", =>
                    @callback null, tree

                land = new Land
                    x: 0
                    y: 0
                    z: 0
                    phosphorus: 1
                , world

                return
            "has fed on phosphorus": (error, tree) ->
                assert.equal tree.phosphorus, 1

        "can eat on timeout": 
            topic: () ->
                tree = new Tree
                    x: 5
                    y: 5
                    z: 1
                    nitrogen: 0
                , world
                clearTimeout tree.eater
                tree.eatTimeRate = 1
                tree.minEatTime = 1
                tree.maxEatTime = 1
                tree.once "change:view", =>
                    tree.getEating()


                # TODO: Figure out why you're firing twice
                tree.once "change:nitrogen", (nitro) =>
                    clearTimeout tree.eater
                    @callback null, tree

                land = new Land
                    x: 5
                    y: 5
                    z: 0
                    nitrogen: 1
                , world
                
                return 
            "has fed on nitrogen": (error, tree) ->
                assert.equal tree.nitrogen, 1

        "can eat from multiple sources":
            topic: () ->
                world = new World()
                tree = new Tree
                    x: 0
                    y: 0
                    z: 1
                    nitrogen: 0
                , world
                clearTimeout tree.eater
                tree.on "change:nitrogen", (howMuch) =>
                    if howMuch == 4
                        @callback null, tree
                for x in [0..1]
                    for y in [0..1]
                        new Land
                            x: x
                            y: y
                            z: 0
                            nitrogen: 1
                        , world
                tree.doEat()
                return
            "has eaten 4 nitrogens": (error, tree) ->
                assert.equal tree.nitrogen, 4

.export module