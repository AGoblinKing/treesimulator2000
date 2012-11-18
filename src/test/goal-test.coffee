vows = require "vows"
assert = require "assert"

Goal = require "../server/classes/Goal"

vows.describe("Goal").addBatch
    "A Goal":
        topic: new Goal()
        "has an area": (goal) ->
            assert.deepEqual goal.area[0], [0, 0, 0]
            assert.deepEqual goal.area[1], [0, 1, 0]