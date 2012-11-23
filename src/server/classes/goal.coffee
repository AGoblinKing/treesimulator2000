Actions = require "../actions"
Conditionals = require "../conditionals"
Triggers = require "../triggers"


class Goal
    constructor: (args = {}) ->
        @actions = []
        @conditionals = []
        @triggers = []
        @reactions = []
        {@name, actions, conditionals, triggers, reactions} = args 

        if actions
            for action in actions
                if Actions[action.type]
                    @actions.push new Actions[action.type](action)
        if conditionals
            for conditional in conditionals?
                if Conditionals[conditional.type]
                    @conditionals.push new Conditionals[conditional.type](conditional)
        if triggers
            for trigger in triggers
                if Triggers[trigger.type]
                    @triggers.push new Triggers[trigger.type](trigger)
        if reactions
            for reaction in reactions
                if Actions[reaction.type]
                    @reactions.push new Actions[reaction.type](reaction)


    start: ->
        @setReactions @reactions
        @setActions @actions
        @setConditionals @conditionals
        @setTriggers @triggers

    register: (@entity) ->
        @start()

    execute: () ->
        # Check Conditionals
        for action in @actions
            action.do.apply action, arguments

    applyInfo: (item) ->
        item.entity = @entity
        item.goal = @

    setConditionals: (conditionals) ->
        for conditional in conditionals
            @applyInfo conditional

    setActions: (actions) ->
        for action in actions
            @applyInfo action
            
    setTriggers: (triggers) ->
        for trigger in triggers
            @applyInfo trigger
            trigger.register =>
                @execute.apply @, arguments

    setReactions: (reactions) ->
        for reaction in reactions
            @applyInfo reaction
            for event, fn of reaction.reactions
                do (event, fn) =>
                    @entity.on event, =>
                        fn.apply reaction, arguments
    simplify: ->
        simple = @parent()
        simple.triggers = []
        simple.conditionals = []
        simple.actions = []
        simple.reactions = []
        simple.reactions.push reaction.simplify for reaction in @reactions
        simple.triggers.push trigger.simplify() for trigger in @triggers
        simple.conditionals.push conditional.simplify() for conditional in @conditionals
        simple.actions.push action.simplify() for action in @actions
        simple

module.exports = Goal