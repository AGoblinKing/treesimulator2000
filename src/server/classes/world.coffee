Entity = require "./entity"
Land = require "./land"

###
    The world object + persistence
###
class World extends Entity
    init: ->
        @locations = {}

    generate: (w, h) ->
        for x in [0..w]
            for y in [0..h] 
                @add new Land 
                    x: x
                    y: y
                , @
    loc: (event, fn) ->
        # Someone wanted to know something about a location.
        @on.call arguments
        fn @locations[event]

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