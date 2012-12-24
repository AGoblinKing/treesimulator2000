{EventEmitter} = require "events"
uuid = require "node-uuid"
###
    Basic Entity class
###
class Base extends EventEmitter
    constructor: (overrides = {}) ->
        # Do the work for defaults
       
        @children = []
        @properties = {}
        @privates = {}
        ## Setup Supers as well
        @handleSupers @constructor, @sets, "defaults"
        @sets @defaults

        @handleSupers @constructor, @sets, "privates", @privates
        @sets @privates
        # Setup ID
        @set "id", uuid.v4()
        # Do the work for overrides

        ## Setup supers as well
        @handleSupers @constructor, @setBindings, "bindings"
        @setBindings @bindings

        @init()
        for name, value of overrides
            @[name] = value
        @setMaxListeners 0

        ## Setup supers as well
        @handleSupers @constructor, @setEvents, "events"
        @setEvents @events

    handleSupers: (level, fn, prop, additional) ->
        if level.__super__[prop]
            fn.call @, level.__super__[prop], additional
            @handleSupers level.__super__.constructor, fn, prop, additional
            
    init: ->

    sets: (values, container = @properties) ->
        @set name, value, container for name, value of values

    set: (name, value, container = @properties) ->
        container[name] = value
        if not @__lookupGetter__ name
            @__defineGetter__ name, ->
                container[name]
            @__defineSetter__ name, (val) ->
                oldProp = container[name]
                container[name] = val
                @emit "change",
                    name: name
                    value: val
                    oldValue: oldProp
                    dif: oldProp - value
                @emit "change:#{name}", 
                    value: val
                    oldValue: oldProp
                    dif: oldProp - value

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


                # TODO: Fix reverse bindings
                if typeof values == "string"
                    bind = values.split " "
                    @__defineGetter__ binding, ->
                        @[bind[0]][bind[1]]

                    @__defineSetter__ binding, (value) ->
                        @[bind[0]][bind[1]] = value
                        @emit "change:#{binding}",
                            value: value

                        @emit "change:#{bind[0]}", 
                            value: @[bind[0]]

                    @on "change:#{bind[0]}", ({value, oldValue}) ->
                        if not oldValue or value[bind[1]] != oldValue[bind[1]] 
                            @emit "change:#{binding}",
                                value: value
                                oldValue: oldValue[bind[1]]
                                dif: oldValue[bind[1]] - value
                else 
                    @__defineGetter__ binding, ->
                        ret = []
                        for prop in values 
                            ret.push @[prop]
                        ret

                    @__defineSetter__ binding, (value) ->
                        for prop, i in value
                            if @[values[i]] != prop
                                @[values[i]] = prop

                    for prop in values 
                        do (binding, prop) =>
                            @on "change:#{prop}", ({value}) ->
                                @emit "change:#{binding}", 
                                    value: @[binding]
module.exports = Base