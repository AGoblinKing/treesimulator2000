vows = require "vows"
assert = require "assert"
util = require "util"

Entity = require "../server/classes/Entity"
World = require "../server/classes/World"

vows.describe("Entity").addBatch
    "An Entity": 
        topic: new Entity()
        "has default properties": (entity) ->
            assert.equal entity.x, 0
        "has change events": 
            topic: () ->
                entity  = new Entity()
                entity.once "change:x", ({value}) =>
                    @callback null, value, entity
                entity.x = 1
                return
            "that fire when property is changed": (err, value, entity) ->
                assert.equal value, 1
            "has bindings": (err, value, entity) ->
                assert.deepEqual entity.location, [1,0,0] 
        "has binding change events":
            topic: () ->
                entity = new Entity()
                entity.once "change:location", ({value}) =>
                    @callback null, value
                entity.x = 5
                return
            "that fire when a binding is changed": (value) ->
                assert.deepEqual value, [5,0,0]
        "has children": (entity) ->
            assert.isArray entity.children
        "can add children":
            topic: (entity) ->
                child = new Entity()
                entity.add child
                [entity, child]
            "that are present": ([entity, child]) ->
                assert.equal entity.children[0], child
            "that can be removed": ([entity, child]) ->
                entity.remove child 
                assert.equal entity.children.length, 0
        "can simplify":
            topic: new Entity {id: "foo", x:1}
            "with no children": (entity) ->
                assert.deepEqual entity.simplify(), 
                    properties: 
                        x: 1
                        y: 0
                        z: 0
                        id: "foo"
                    children:[]
            "with children": (entity) ->
                child = new Entity() 
                entity.add child
                assert.deepEqual entity.simplify(),
                    properties: 
                        x: 1
                        y: 0
                        z: 0
                        id: "foo"
                    children: [child.simplify()]
        "has a map": (entity) ->
            assert.isObject entity.map

        "can instantiate from data": 
            topic: ->
                csonData = """
                {
                    type: "Tree"
                    properties: 
                        phosphorus: 0
                        potassium: 0
                        nitrogen: 0
                        x: 5
                        y: 2
                        z: 3
                    goals: [
                        name: "Eat some food!"
                        actions: [
                            type: "Take"
                            howMuch: 1
                            what: ["poo"]
                            distance: 1
                        ]
                        triggers: [
                            
                        ]
                        reactions: [
                            type: "Take"
                            howMuch: 1
                            what: ["poo"]
                        ]
                    ]
                }
                """
                entity = new Entity()
                entity.fromCSON csonData
                entity

            "has properties set": (entity) ->
                assert.equal entity.x, 5
                assert.equal entity.potassium, 0

            "has a goal": (entity) ->
                assert.isArray entity.goals
                assert.equal entity.goals?.length, 1

        "handles view changes": 
            topic: () ->
                world = new World()
                world.add e1 = new Entity
                    x: 0
                    y: 0
                    z: 0
                    id: "e1"
                e1.setView 1

                e1.once "change:view", ({location, entity}) =>
                    @callback null, location, entity, e1

                world.add e2 = new Entity
                    x: 1
                    y: 0
                    z: 0
                    id: "e2"

                return 
            "when an entity is added": (error, location, entity) ->
                assert.equal entity.id, "e2"
                assert.deepEqual entity.location, location
            "its map is also updated": (error, location, entity, e1) ->
                assert.equal e1.map[location.join ":"].id, entity.id

            "when an entity moves": 
                topic: (location, e2, e1) ->
                    e1.once "change:view", ({location, entity}) =>
                        @callback null, location, entity, e1
                    e2.move [1, 0, 1]
                    return

                "its view is updated": (error, location, e2, e1) ->
                    assert.equal e1.map["1:0:1"].id, e2.id

                "and the old location is cleared": (error, location, e2, e1) ->
                    assert.equal e1.map["1:0:0"], undefined  
.export module

