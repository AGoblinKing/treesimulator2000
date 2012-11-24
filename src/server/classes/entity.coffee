Base = require "./base"
Goal = require "./goal"
CSON = require "cson"
###
    Basic Entity class
###
class Entity extends Base
    constructor: (overrides = {}) ->
        # Do the work for defaults
        @map = {}
        @debug = false
        @goals = []
        super overrides
                
    setWorld: (@world) ->
        @move @location

    move: (location) ->
        if @phantom
            @location = location
        else 
            @world.move @, location

    # TODO: Add bindings to property list

    mapSimplify: () ->
        view = []
        for location, entity of @map
            view.push entity.simplify() if entity
        view

    setViewBindings: () ->
        # TODO: Only remove the old ones, keep the ones to be reused
        #clean up old view
        if @viewBindings
            for event, fn of @viewBindings
                @world.removeListener event, fn if fn?
                delete @viewBindings[event]
        else 
            @viewBindings = {}

        if @view > -1
            loc = @location
            for offsetX in [-@view..@view]
                for offsetY in [-@view..@view]
                    for offsetZ in [0..1]
                        event = [loc[0]+offsetX, loc[1]+offsetY, offsetZ].join ":"
                        @viewBindings[event] = (event) =>
                            locationT = event.location.join ":"
                            @map[locationT] = event.entity

                            if event.type == "move" and event.oldLocation and (oldLocT = event.oldLocation.join ":") != locationT
                                @map[oldLocT] = undefined
                                delete @map[oldLocT]

                            @emit "change:view", event
                        # Override on so that the world will immediately respond if there is something there?
                        @world.loc event, @viewBindings[event]
    
    fromCSON: (cson) ->
        data = CSON.parseSync cson
        @load data

    load: (data = {}) ->
        @sets data.properties if data.properties
        @loadGoals data.goals if data.goals
        @view = data.view if data.view
        @debug = data.debug if data.debug
        return @

    loadGoals: (goals) ->
        for goal in goals
            newGoal = new Goal goal
            @addGoal newGoal

    addGoal: (goal) ->
        @goals.push goal
        goal.register @

    setView: (@view) ->
        @setViewBindings()

    bindings: 
        location: ["x", "y", "z"]

    events: 
        "changed": ({name, value, oldValue}) ->
            if @debug
                console.log @id, name, value, oldValue
            @world?.emit (@location.join ":"), 
                type: "property"
                name: name
                value: value
                oldValue: oldValue
                location: @location
                entity: @

        "change:location": () ->
            @setViewBindings()

    defaults: 
        x: 0
        y: 0
        z: 0
    # The viewing range for an entity
    view: -1
    # Whether an entity exists or not for collisions/viewing
    phantom: false
    


module.exports = Entity
    