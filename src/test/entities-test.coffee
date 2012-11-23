vows = require "vows"
assert = require "assert"


Entities = require "../server/entities"

vows.describe("Entities").addBatch
    "Entities":
        topic: Entities
        "have classes from data": (entities) ->
            assert.notEqual Object.keys(entities).length, 0
        "has test entity": (entities) ->
            assert entities.test != undefined, "is not null"
        "can be instantied": (entities) ->
            new entities.test()
.export module