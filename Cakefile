{exec}  = require "child_process"
fs = require "fs"
walk = require "walk"
watch = require "watch"
path = require "path"
mkpath = require "mkpath"

launch = (path, opts = {}) ->
    app = exec path, opts
    app.stdout.pipe process.stdout 
    app.stderr.pipe process.stderr

cloneFile = (src, dest) ->
    (file) ->
        if path.extname(file) != ".coffee"
            mkpath path.dirname(file.replace(src, dest)), () ->
                fs.readFile file, 'utf8', (err, data) ->
                    console.log "Moved #{file}"
                    fs.writeFile (file.replace src, dest), data
deleteFile = (src, dest) ->
    (file) ->
        if path.extname(file) != ".coffee"
            console.log "Deleted #{file}"
            fs.unlink (file.replace src, dest)

task "compile", "compile EVERYTHING", ->
    walker = walk.walk "./src"
    walker.on "file", (root, fileStats, next) ->
        cloneFile "#{root}/#{fileStats.name}"
        next()
    launch "coffee -o lib/ -c src"
    launch "browserify ./lib/client/app.js -o ./lib/web/app.js"

task "watch", "watch all sources", ->
    invoke "compile"
    watch.createMonitor "./src", (monitor) ->
        monitor.on "created", cloneFile("src", "lib")
        monitor.on "changed", cloneFile("src", "lib")
        monitor.on "removed", deleteFile("src", "lib")
    watch.createMonitor "./lib/client/workers", (monitor) ->
        monitor.on "created", cloneFile("client", "web")
        monitor.on "changed", cloneFile("client", "web")
        monitor.on "removed", deleteFile("client", "web")
    launch "coffee -o lib/ -cw src",
        customFds: [0,1,2] 
    launch "browserify ./lib/client/app.js -wo ./lib/web/app.js"

task "test", "test the code", ->
    launch "vows --spec -r",
        cwd: "#{__dirname}/lib",
        customFds: [0,1,2] 
