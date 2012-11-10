vows = require "vows"
assert = require "assert"

World = require "../server/classes/world"
Entity = require "../server/classes/entity"

vows.describe("World").addBatch
    "A World":
        topic: new World()
        "can inform about location": 
            "when occupied":
                topic: (world) ->
                    world.on "1:1:0", ({location, entity}) =>
                        @callback null, location, entity

                    world.add new Entity
                        x: 1
                        y: 1
                        z: 0
                    return
                "is returned": (error, location, entity) ->
                    assert.deepEqual entity.location, [1, 1, 0]
        "will collide entities":
            topic: (world) ->
                world.add e1 = new Entity 
                    x: 5
                    y: 5
                    z: 0

                world.add e2 = new Entity
                    x: 5
                    y: 6
                    z: 0

                e1.on "collision", ({entity, location}) =>
                    @callback null, entity, location, e2
                
                e2.move e1.location
                return
            "and inform them of each other": (error, entity, location, e2) ->
                assert.equal entity.id, e2.id

            "and not move the collider": (error, entity, location, e2) ->
                assert.notEqual e2.location, location
.export module