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
        @sets @defaults
        # Setup ID
        @set "id", uuid.v4()
        # Do the work for overrides
        @init()
        @sets overrides
        @setMaxListeners 0
        @setBindings @bindings
        @setEvents @events

        if @world 
            @move @location


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
        "change:location":() ->
            @setViewBindings()

    defaults: 
        x: 0,
        y: 0,
        z: 0,
    view: -1


module.exports = Entity
    