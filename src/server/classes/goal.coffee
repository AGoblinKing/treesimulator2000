Actions = require "../actions"
Triggers = require "../triggers"
logger = require "../logger"
Base = require "./base"
Promise = require "node-promise"


class Goal extends Base
    constructor: (args = {}) ->
        @actions = []
        @triggers = []
        @reactions = []
        @goals = []
        {@name, actions, conditionals, triggers, reactions, goals, properties} = args 
        super properties
        @conditionals = conditionals ? []
        if goals? then @loadGoals goals
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
        goal.start() for goal in @goals
        @setReactions @reactions
        @setActions @actions
        @setTriggers @triggers

    register: (@entity) ->
        @start()

    destroy: () ->

    addGoal: (goal) ->
        goal.parent = this
        @goals.push goal

    loadGoals: (goals) ->
        @addGoal new Goal(goal) for goal in goals

    execute: () ->
        # Check Conditionals
        doExecute = true
        for conditional in @conditionals
            doExecute = doExecute and conditional.call @
        if doExecute
            promises = (action.do.apply action, arguments for action in @actions)
        
        Promise.when promises, () =>
            @emit 

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
        simple.goals = (goal.simplify() for goal in @goals) 
        simple.reactions.push reaction.simplify for reaction in @reactions
        simple.triggers.push trigger.simplify() for trigger in @triggers
        simple.conditionals.push conditional.simplify() for conditional in @conditionals
        simple.actions.push action.simplify() for action in @actions
        simple

module.exports = Goal