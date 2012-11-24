vows = require "vows"
assert = require "assert"
util = require "util"

Entity = require "../server/classes/entity"
World = require "../server/classes/world"

vows.describe("Actions").addBatch
    "Take and Give": 
        topic: () ->
            world = new World()

            world.add giver = new Entity().load
                properties:
                    test: 5
                    test2: 1
                    name: "giver"
                    x: 0
                    y: 0
                    z: 0

                goals: [
                    name: "give tests"
                    reactions: [{type: "take"}]
                ]

            world.add taker = new Entity().load
                properties:
                    test: 0
                    test2: 0
                    name: "taker"
                    x: 0
                    y: 0
                    z: 1
                view: 1
                goals: [
                    name: "take tests"
                    actions: [
                        type: "take"
                        what: 
                            test: 1
                            test2: 1
                    ],
                    reactions: [{type: "give"}]
                ]
            taker.on "change:test", =>
                @callback giver, taker

            taker.goals[0].execute()
            return

        "taker has taken": (giver, taker) ->
            assert.equal taker.test, 1

        "giver has given": (giver, taker) ->
            assert.equal giver.test, 4
.export module