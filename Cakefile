{exec}  = require "child_process"

launch = (path, opts = {}) ->
    app = exec path, opts
    app.stdout.pipe process.stdout 
    app.stderr.pipe process.stderr

task "watch", "watch all sources", ->
    launch "coffee -o lib/ -cw src",
        customFds: [0,1,2] 
task "test", "test the code", ->
    launch "vows --spec -r",
        cwd: "#{__dirname}/lib",
        customFds: [0,1,2] 
