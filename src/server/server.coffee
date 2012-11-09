# Setup Socket.IO
express = require("express")
app = express.createServer()
io = require("socket.io").listen(app)

app.use express.static "#{__dirname}/../web" 

World = new (require "./classes/world")
World.generate 50, 50

io.sockets.on "connection", (socket) ->
    socket.emit "view", World.simplify()

app.listen 8088