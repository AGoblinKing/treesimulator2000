{exec}  = require "child_process"
fs = require "fs"
watch = require "watch"
path = require "path"

launch = (path, opts = {}) ->
    app = exec path, opts
    app.stdout.pipe process.stdout 
    app.stderr.pipe process.stderr

cloneFile = (file) ->
    if path.extname(file) != ".coffee"
        console.log "Moved #{file}"
        fs.readFile file, 'utf8', (err, data) ->
            fs.writeFile (file.replace /src/, "lib"), data
deleteFile = (file) ->
    if path.extname(file) != ".coffee"
        console.log "Deleted #{file}"
        fs.unlink (file.replace /src/, "lib")

task "watch", "watch all sources", ->
    watch.createMonitor "./src", (monitor) ->
        monitor.on "created", cloneFile
        monitor.on "changed", cloneFile
        monitor.on "removed", deleteFile
    launch "coffee -o lib/ -cw src",
        customFds: [0,1,2] 

task "test", "test the code", ->
    launch "vows --spec -r",
        cwd: "#{__dirname}/lib",
        customFds: [0,1,2] 
