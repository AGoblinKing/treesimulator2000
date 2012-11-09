{EventEmitter} = require "events"
uuid = require "node-uuid"
###
    Basic Entity class
###
class Entity extends EventEmitter
    constructor: (overrides = {}, @world) ->
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

        if @world 
            @move @location

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
        @world.move @, location

    set: (name, value) ->
        @properties[name] = value
        if not @__lookupGetter__ name
            @__defineGetter__ name, ->
                @properties[name]
            @__defineSetter__ name, (val) ->
                oldProp = @properties[name]
                @properties[name] = val
                @emit "changed", name, val, oldProp
                @emit "change:#{name}", val, oldProp

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
        child.emit "added", @
        @emit "add", child, @children

    remove: (child) ->
        location = @children.indexOf child
        if location != -1
            @children.splice location, 1
            child.parent = undefined
            @emit "remove", child, @children
            child.emit "removed", @

    setEvents: (events) ->
        for event, handler of events
            if typeof handler == "function"
                @on event, handler
            else if typeof handler == "string"
                @on event, @[handler]

    setBindings: (bindings)->
        for binding, values of bindings
            do (binding, values) =>
                @__defineGetter__ binding, ->
                    ret = []
                    for prop in values 
                        ret.push @[prop]
                    ret

                @__defineSetter__ binding, (value) ->
                    for prop, i in value
                        if @[values[i]] != prop
                            @[values[i]] = prop
                    @emit "change:#{binding}", @[binding]
                for prop in values 
                    do (binding, prop) =>
                        @on "change:#{prop}", (value) ->
                            @emit "change:#{binding}", @[binding]
    setViewBindings: () ->
        # TODO: Only remove the old ones, keep the ones to be reused
        #clean up old view
        if @viewBindings
            for event, fn of @viewBindings
                @world.removeEventListener event, fn
                @viewBindings[event] = undefined
        else 
            @viewBindings = {}

        if @view > -1
            loc = @location
            for offsetX in [-@view..@view]
                for offsetY in [-@view..@view]
                    for offsetZ in [0..1]
                        event = [loc[0]+offsetX, loc[1]+offsetY, offsetZ].join ":"
                        @viewBindings[event] = (location, entity) =>
                            @map[location.join ":"] = entity
                            @emit "change:view", location, entity
                        # Override on so that the world will immediately respond if there is something there?
                        @world.loc event, @viewBindings[event]
    
    setView: (@view) ->
        @setViewBindings()

    bindings: 
        "location": ["x", "y", "z"]

    events: 
        "moved": (location) ->
            @location = location

        "changed": (name, val, oldProp) ->
            if @world
                @world.emit (@location.join ":"), @location, @, name, val

        "change:location":() ->
            @setViewBindings()

    defaults: 
        x: 0,
        y: 0,
        z: 0,
    view: -1


module.exports = Entity
    