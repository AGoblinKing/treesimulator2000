Actions = require "../actions"
Triggers = require "../triggers"
logger = require "../logger"


class Goal
    constructor: (args = {}) ->
        @actions = []
        @triggers = []
        @reactions = []
        {@name, actions, conditionals, triggers, reactions} = args 

        @conditionals = conditionals ? []
        @registerType actions, Actions, @actions
        @registerType reactions, Actions, @reactions
        @registerType triggers, Triggers, @triggers

    registerType: (types, classHolder, localHolder) ->
        if types
            for type in types
                type.type = type.type.charAt(0).toUpperCase() + type.type.slice(1)
                if classHolder[type.type]
                    localHolder.push new classHolder[type.type](type)
                else 
                    logger.error "Unable to load type for goal #{type.type}"
    start: ->
        @setReactions @reactions
        @setActions @actions
        @setTriggers @triggers

    register: (@entity) ->
        @start()

    destroy: () ->

    execute: () ->
        # Check Conditionals
        doExecute = true
        for conditional in @conditionals
            doExecute = doExecute and conditional.call @
        if doExecute
            for action in @actions
                action.do.apply action, arguments

    applyInfo: (item) ->
        item.entity = @entity
        item.goal = @

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