Entity = require "./entity"
Base = require "./base"
###
    The world object + persistence
###
{Land, Tree} = require "../entities"

class World extends Base
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
        ###
        for t in [0..10]
            @add new Tree
                x: Math.floor(Math.random()*w)
                y: Math.floor(Math.random()*h)
                z: 1
        ### 
    add: (entity) ->
        entity.setWorld @
        super entity
    loc: (event, fn) ->
        # Someone wanted to know something about a location.
        @on.apply @, arguments
        if @locations[event] 
            fn 
                type: "look"
                location: @locations[event].location
                entity: @locations[event] 

    move: (entity, location) ->
        sLoc = location.join(":")
        dest = @locations[sLoc]

        if not dest
            @locations[sLoc] = entity
            if entity.location.join(":") != sLoc
                @locations[entity.location.join ":"] = undefined
            oldLoc = entity.location
            entity.location = location
            entity.emit "moved", location
            @emit sLoc,
                location: location
                entity: entity
                oldLocation: oldLoc
                type: "move"
        else 
            entity.emit "collision",
                entity: dest
                location: location

            dest.emit "collision", 
                entity: entity
                location: location

module.exports = World