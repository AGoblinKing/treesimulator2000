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
        parseProperties: (dataProperties) ->
            properties = {}
            for property, value of dataProperties
                if typeof value == "object"
                    switch value.type
                        when "range" 
                            if value.min? && value.max?
                                value = value.min + Math.random()*(value.max-value.min)
                            else 
                                logger.error "Invalid range attribute found in data entry: #{name}:#{property}"
                                value = 0
                properties[property] = value
            properties
        init: () ->
            if not data.propeties?
                data.propreties = {}
            if not data.privates?
                data.privates = {}
            @load 
                properties: @parseProperties data.properties
                privates: @parseProperties data.privates
                conditionals: data.conditionals
                goals: data.goals
                view:  data.view
                debug: data.debug

file.walkSync path.join("#{dir.join(path.sep)}", "data", "entities"), (dir, dirs, files) ->
    for file in files 
        contents = fs.readFileSync "#{dir}/#{file}", "utf8"
        addEntity path.basename(file, ".cson"), CSON.parseSync contents

module.exports = Entities