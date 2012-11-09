Entity = require "./entity"
Land = require "./land"
Tree = require "./tree"
###
    The world object + persistence
###
class World extends Entity
    init: ->
        @locations = {}

    generate: (w, h) ->
        # Add some land
        for x in [0..w]
            for y in [0..h] 
                @add new Land 
                    x: x
                    y: y
                , @
        # Add 10 Trees
        for t in [0..10]
            @add new Tree
                x: Math.floor(Math.random()*w)
                y: Math.floor(Math.random()*h)
                z: 1

    loc: (event, fn) ->
        # Someone wanted to know something about a location.
        @on.apply @, arguments
        if @locations[event] 
            fn @locations[event].location, @locations[event]

    move: (entity, location) ->
        sLoc = location.join(":")
        dest = @locations[sLoc]
        if not dest
            @locations[sLoc] = entity
            @emit sLoc, location, entity
            entity.emit "moved", location
        else 
            entity.emit "collision", dest, location
            dest.emit "collision", entity, location

module.exports = World