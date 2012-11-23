Entity = require "./entity"


###
    Player Class
    Instantiated per user, provides their area of concern
###
class Player extends Entity
    init: ->
        @updates = {}
    setSocket: (@socket) ->
        @socket.on "update", ({x, y, z}) =>
            x = Math.floor x
            y = Math.floor y
            z = Math.floor z
            @move [x, y, z]

        @socket.emit "update", @mapSimplify()
        setInterval =>
            @sendUpdates()
        , @updateTime
    phantom: true
    view: 10
    updateTime: 100
    sendUpdates: ->
        batch = []
        batch.push update for id, update of @updates
        if batch.length > 0
            @socket.emit "update", batch
    events: 
        "change:view": ({entity, name, value, oldValue}) ->
            # Only send delta 
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