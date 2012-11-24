vows = require "vows"
assert = require "assert"


Entities = require "../server/entities"
World = require "../server/classes/world"

vows.describe("Entities").addBatch
    "Entities":
        topic: Entities
        "have classes from data": (entities) ->
            assert.notEqual Object.keys(entities).length, 0
        "has test entity": (entities) ->
            assert entities.Test != null, "is not null"
        "can be instantied": (entities) ->
            new entities.Test()

    "Tree and Land":
        topic: () ->
            tree = new Entities.Tree
                x: 0
                y: 0
                z: 1

            land = new Entities.Land
                x: 0
                y: 0
                z: 0

            trigger = tree.goals[0].triggers[0]

            trigger.min = 1
            trigger.max = 1
            # restart it
            tree.goals[0].start()

            tree.once "change:phosphorus", =>
                @callback tree, land

            world = new World()

            world.add tree
            world.add land

            return

        "tree has eaten": (tree, land) ->
            assert.equal tree.phosphorus, 1

.export module