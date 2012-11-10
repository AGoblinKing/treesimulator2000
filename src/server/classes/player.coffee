Entity = require "./entity"


###
    Player Class
    Instantiated per user, provides their area of concern
###
class Player extends Entity
    setSocket: (@socket) ->
        @socket.on "update", ({x, y, z}) =>
            x = Math.floor x
            y = Math.floor y
            z = Math.floor z
            @move [x, y, z]

        @socket.emit "update", @mapSimplify()
    phantom: true
    view: 10
    events: 
        "change:view": ({entity}) ->
            @socket?.emit "update", [entity.simplify()]

module.exports = Player