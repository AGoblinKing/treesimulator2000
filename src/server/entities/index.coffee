# Load data :D
fs = require "fs"
walk = require "walk"
CSON = require "cson"
path = require "path"
Entity = require "../classes/entity"

# Be smart about the directories
dir = process.cwd().split(path.sep)
if dir[dir.length-1] == "lib"
    dir.splice -1, 1

walker = walk.walkSync "#{dir.join(path.sep)}/data/entities"

Entities = {}
addEntity = (name, data) ->
    Entities[name] = class DataEntity extends Entity
        init: () ->
            properties = {}
            for property, value of data.properties
                if typeof value == "object"
                    switch value.type
                        when "range" 
                            value = value.min + Math.random*(value.max-value.min)
                properties[property] = value
            @sets properties
            @loadGoals data.goals

walker.on "file", (root, stat, next) ->
    contents = fs.readFileSync "#{root}/#{stat.name}", "utf8"
    addEntity path.basename(stat.name, ".cson"), CSON.parseSync contents


module.exports = Entities