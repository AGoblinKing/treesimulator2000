vows = require "vows"
assert = require "assert"
util = require "util"

Entity = require "../server/classes/entity"
World = require "../server/classes/world"
Goal = require "../server/classes/goal"
{Action} = require "../server/actions"
{VariableTime} = require "../server/triggers"

class TestAction extends Action
    do: ->
        @entity.emit "executed"

vows.describe("Triggers").addBatch
    "VariableTime": 
        topic: () ->
            goal = new Goal 
                name: "variably timed test"

            goal.actions.push new TestAction()
            goal.triggers.push new VariableTime
                min: 1
                max: 1

            entity = new Entity()

            entity.on "executed", =>
                @callback true

            entity.addGoal goal
            return

        "is triggered": () ->
            assert.ok true, "is trigged"

.export module