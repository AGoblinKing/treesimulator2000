# Setup Socket.IO
express = require("express")
app = express.createServer()
io = require("socket.io").listen(app)

app.use express.static "#{__dirname}/../web" 

world = new (require "./classes/world")
world.generate 50, 50

Player = require "./classes/player"

io.set('log level', 1)
io.sockets.on "connection", (socket) ->
    world.add player = socket.player = new Player()
    player.setSocket socket

app.listen 8088