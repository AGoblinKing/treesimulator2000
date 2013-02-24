{exec}  = require "child_process"
fs = require "fs"
walk = require "walk"
watch = require "watch"
path = require "path"
mkpath = require "mkpath"

launch = (path, opts = {}, callback) ->
    app = exec path, opts, callback
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
    walker = walk.walk "src"
    walker.on "file", (root, fileStats, next) ->
        cloneFile("src", "lib") "#{root}/#{fileStats.name}"
        next()
    launch "coffee -o lib/ -c src"

task "watch", "watch all sources", ->
    invoke "compile"
    watch.createMonitor "./src", (monitor) ->
        monitor.on "created", cloneFile("src", "lib")
        monitor.on "changed", cloneFile("src", "lib")
        monitor.on "removed", deleteFile("src", "lib")

    launch "coffee -o lib/ -cw src",
        customFds: [0,1,2] 

task "test", "test the code", ->
    launch "vows --spec -r",
        cwd: "#{__dirname}/lib",
        customFds: [0,1,2] 
