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
        newViews = []
        if not @viewBindings
            @viewBindings = {}

        if @view > -1
            loc = @location
            for offsetX in [-@view..@view]
                for offsetY in [-@view..@view]
                    for offsetZ in [0..1]
                        event = [loc[0]+offsetX, loc[1]+offsetY, offsetZ].join ":"
                        newViews.push event
                        if not @viewBindings[event]?
                            @viewBindings[event] = (bindEvent) =>
                                locationT = bindEvent.location.join ":"
                                @map[locationT] = bindEvent.entity

                                if bindEvent.type == "move" and bindEvent.oldLocation and (oldLocT = bindEvent.oldLocation.join ":") != locationT
                                    @map[oldLocT] = undefined
                                    delete @map[oldLocT]

                                @emit "change:view", bindEvent
                            # Override on so that the world will immediately respond if there is something there?
                            @world.loc event, @viewBindings[event]

            #clean up old view bindings if they're not in the newViews
            for event, fn of @viewBindings when newViews.indexOf(event) == -1
                @world.removeListener event, fn if fn?
                delete @viewBindings[event]
                
                oldEntity = undefined

                if @map[event]?
                    oldEntity = @map[event]
                    @map[event] =  undefined
                    delete @map[event] 

                # Tell myself about the fog
                @emit "change:view", 
                    location: loc
                    type: "fog"
                    entity: oldEntity


    
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
    