vows = require "vows"
assert = require "assert"

Entity = require "../server/classes/Entity"
World = require "../server/classes/World"

vows.describe("Entity").addBatch
    "An Entity": 
        topic: new Entity()
        "has default properties": (entity) ->
            assert.equal entity.x, 0
        "has change events": 
            topic: (entity) ->
                entity.once "change:x", (value) =>
                    @callback null, value
                entity.x = 1
                return
            "that fire when property is changed": (value) ->
                assert.equal value, 1
        "has bindings": (entity) ->
            assert.deepEqual entity.location, [1,0,0] 
        "has binding change events":
            topic: (entity) ->
                entity.once "change:location", (value) =>
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

        "handles view changes": 
            topic: () ->
                world = new World()
                e1 = new Entity
                    x: 0
                    y: 0
                    z: 0
                , world
                e1.setView 1
                e1.on "change:view", (location, entity) =>
                    @callback null, location, entity, e1
                e2 = new Entity
                    x: 1
                    y: 0
                    z: 0
                    id: "foo"
                , world
                return 
            "when an entity is added": (error, location, entity) =>
                assert.equal entity.id, "foo"
                assert.deepEqual entity.location, location
            "its map is also updated": (error, location, entity, e1) =>
                assert.equal e1.map[location.join ":"].id, entity.id


.export module

