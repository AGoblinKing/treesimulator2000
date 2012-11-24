# Load data :D
fs = require "fs"
file = require "file"
CSON = require "cson"
path = require "path"
logger = require "../logger"
Entity = require "../classes/entity"

# Be smart about the directories
dir = process.cwd().split(path.sep)

if dir[dir.length-1] == "lib"
    dir.splice -1, 1

Entities = {}
addEntity = (name, data) ->
    if data.message
        logger.error "Unable to parse data file #{name}: #{data.message}"
        return

    Entities[name] = Entities[name.charAt(0).toUpperCase() + name.slice(1)] = class DataEntity extends Entity
        init: () ->
            properties = {}
            for property, value of data.properties
                if typeof value == "object"
                    switch value.type
                        when "range" 
                            if value.min? && value.max?
                                value = value.min + Math.random()*(value.max-value.min)
                            else 
                                logger.error "Invalid range attribute found in data entry: #{name}:#{property}"
                                value = 0
                properties[property] = value

            @load 
                properties: properties
                goals: data.goals
                view:  data.view
                debug: data.debug

file.walkSync "#{dir.join(path.sep)}\\data\\entities", (dir, dirs, files) ->
    for file in files 
        contents = fs.readFileSync "#{dir}/#{file}", "utf8"
        addEntity path.basename(file, ".cson"), CSON.parseSync contents

module.exports = Entities