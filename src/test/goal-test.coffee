vows = require "vows"
assert = require "assert"
util = require "util"

Entity = require "../server/classes/Entity"
Goal = require "../server/classes/Goal"
Actions = require "../server/actions"
Triggers = require "../server/triggers"

vows.describe("Goal").addBatch
    "An Empty Goal":
        topic: new Goal()
        "has no actions": (goal) ->
            assert.deepEqual goal.actions, []

        "has no conditionals": (goal) ->
            assert.deepEqual goal.conditionals, []

        "has no triggers": (goal) ->
            assert.deepEqual goal.triggers, []

        "has no reactions": (goal) ->
            assert.deepEqual goal.reactions, []

    "A Filled Goal":
        topic: new Goal
            name: "bob"
            actions: [
                type: "Action"
                name: "swat"
            ]
            triggers: [
                type: "Trigger"
                name: "zomg"
            ]
            reactions: [
                type: "Action"
                name: "react to swat"
            ]
        "has reactions": (goal) ->
            assert.equal goal.reactions[0].name, "react to swat"
        "has triggers": (goal) ->
            assert.equal goal.triggers[0].name, "zomg"
        "has a name": (goal) ->
            assert.equal goal.name, "bob"
        "has actions": (goal) ->
            assert.equal goal.actions[0].name, "swat"

    "A registered goal":
        topic: () ->
            class TestAction extends Actions.Action
                defaults: 
                    rawr: "ohyeah?"

                reactions: 
                    "RAWR": ({who}) ->
                        who.emit "end", @rawr
                
                do: () ->
                    @entity.emit "RAWR", 
                        who: @entity

            class TestTrigger extends Triggers.Trigger
                defaults: 
                    event: "start"

                register: (fn) ->
                    @entity.on @event, fn

            goal = new Goal
                name: "bob"
            goal.actions.push new TestAction()
            goal.triggers.push new TestTrigger()
            goal.reactions.push new TestAction()

            entity = new Entity()
            entity.on "end", (message) =>
                @callback null, entity, message

            entity.addGoal goal

            entity.emit "start"
            
            return

        "recieves events and messages": (err, entity, message) ->
            assert.equal message, "ohyeah?"
            assert.equal entity.goals[0].name, "bob"

.export module