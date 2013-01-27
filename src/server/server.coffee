# Setup Socket.IO
express = require("express")
app = express.createServer()
io = require("socket.io").listen(app)
logger = require "./logger"

app.use express.static "#{__dirname}/../web" 

world = new (require "./classes/world")
world.generate 20, 20

Player = require "./classes/player"

io.set('log level', 1)
io.sockets.on "connection", (socket) ->
    world.add player = socket.player = new Player()
    player.setSocket socket

port = process.env.PORT || 8088
app.listen port

console.log "App listening on #{port}" 
