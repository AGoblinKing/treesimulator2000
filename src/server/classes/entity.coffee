{EventEmitter} = require "events"
uuid = require "node-uuid"
###
    Basic Entity class
###
class Entity extends EventEmitter
    constructor: (overrides = {}) ->
        # Do the work for defaults
        @map = {}
        @properties = {}
        @children = []

        ## Setup Supers as well
        @handleSupers @constructor, @sets, "defaults"
        @sets @defaults
        # Setup ID
        @set "id", uuid.v4()
        # Do the work for overrides

        ## Setup supers as well
        @handleSupers @constructor, @setBindings, "bindings"
        @setBindings @bindings

        @init()
        @sets overrides
        @setMaxListeners 0

        ## Setup supers as well
        @handleSupers @constructor, @setEvents, "events"
        @setEvents @events

    handleSupers: (level, fn, prop) ->
        if level.__super__[prop] and level.__super__.constructor.__super__
            fn.call @, level.__super__[prop]
            @handleSupers level.__super__.constructor, fn, prop
            
    setWorld: (@world) ->
        @move @location

    init: ->

    sets: (values) ->
        @set name, value for name, value of values

    move: (location) ->
        if @phantom
            @location = location
        else 
            @world.move @, location

    set: (name, value) ->
        @properties[name] = value
        if not @__lookupGetter__ name
            @__defineGetter__ name, ->
                @properties[name]
            @__defineSetter__ name, (val) ->
                oldProp = @properties[name]
                @properties[name] = val
                @emit "changed",
                    name: name
                    value: val
                    oldValue: oldProp
                @emit "change:#{name}", 
                    value: val
                    oldValue: oldProp

    # TODO: Add bindings to property list

    mapSimplify: () ->
        view = []
        for location, entity of @map
            view.push entity.simplify() if entity
        view

    simplify: () ->
        simple = 
            children: []
            properties: @properties

        for child in @children  
            simple.children.push child.simplify()

        simple

    toJSON: (recurse) ->
        if recurse 
            return JSON.stringify @simplify()
        else 
            return JSON.stringify @properties

    add: (child) ->
        @children.push child
        child.parent = @
        child.emit "added", 
            entity: @
        @emit "add",
            entity: child

    remove: (child) ->
        location = @children.indexOf child
        if location != -1
            @children.splice location, 1
            child.parent = undefined
            @emit "remove", 
                entity: child

            child.emit "removed", 
                entity: @

    setEvents: (events) ->
        for event, handler of events
            if typeof handler == "function"
                @on event, handler
            else if typeof handler == "string"
                @on event, @[handler]

    setBindings: (bindings)->
        for binding, values of bindings
            do (binding, values) =>
                @__defineGetter__ @properties[binding], =>
                    @[binding]

                @__defineGetter__ binding, ->
                    ret = []
                    for prop in values 
                        ret.push @[prop]
                    ret

                @__defineSetter__ binding, (value) ->
                    for prop, i in value
                        if @[values[i]] != prop
                            @[values[i]] = prop
                    @emit "change:#{binding}", 
                        value: @[binding]
                for prop in values 
                    do (binding, prop) =>
                        @on "change:#{prop}", ({value}) ->
                            @emit "change:#{binding}", 
                                value: @[binding]
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

                            @emit "change:view",
                                location: event.location
                                entity: event.entity
                        # Override on so that the world will immediately respond if there is something there?
                        @world.loc event, @viewBindings[event]
    
    setView: (@view) ->
        @setViewBindings()

    bindings: 
        "location": ["x", "y", "z"]

    events: 
        "changed": ({name, value, oldValue}) ->
            @world?.emit (@location.join ":"), 
                type: "property"
                name: name
                value: value
                location: @location
                entity: @

        "change:location":() ->
            @setViewBindings()

    defaults: 
        x: 0,
        y: 0,
        z: 0,
    # The viewing range for an entity
    view: -1
    # Whether an entity exists or not for collisions/viewing
    phantom: false


module.exports = Entity
    