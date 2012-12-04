Entity = require "./entity"
util = require "util"

###
    Player Class
    Instantiated per user, provides their area of concern
###
class Player extends Entity
    defaults:
        type: "player"
    init: ->
        @updates = {}   

    setSocket: (@socket) ->
        @socket.on "update", ({x, y, z}) =>
            x = Math.floor x
            y = Math.floor y
            z = Math.floor z   
            
            if  @x != x or @y != y or @z != y  
                @move [x, y, z]

        @socket.emit "update", @mapSimplify()
        setInterval =>
            @sendUpdates()
        , @updateTime

    phantom: true
    view: 5
    updateTime: 100
    sendUpdates: ->
        batch = []
        batch.push update for id, update of @updates
        if batch.length > 0
            @socket.emit "update", batch
        @updates = {}

    events: 
        "change:view": ({entity, name, value, oldValue, type}) ->
            # Only send delta 

            switch type
                when "fog"
                    if entity 
                        @updates[entity.id] =
                            type: "fog" 
                            properties: 
                                id: entity.id
                else
                    if name 
                        if not @updates[entity.id]
                            update = 
                                id: entity.id
                            update[name] = value
                            @updates[entity.id] = {properties:update}
                        else 
                            @updates[entity.id].properties[name] = value
                    else 
                        @updates[entity.id] = entity.simplify()

module.exports = Player