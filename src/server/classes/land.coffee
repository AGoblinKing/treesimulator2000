Entity = require "./entity"

class Land extends Entity
    init: ->
        # Because I override the defaults for Land, I must call entities...
        @sets Entity::defaults
        @setEvents Entity::events
        @phosphorus = Math.floor(Math.random()*100)
        @potassium = Math.floor(Math.random()*100)
        @nitrogen = Math.floor(Math.random()*100)

    eat: (what, howMuch, who) ->
        if @[what] and @[what] >= howMuch
            who.emit "feed", what, howMuch, @
            @[what] -= howMuch
            
    defaults:
        # brown
        phosphorus: 0 
        # yellow
        potassium: 0
        # green
        nitrogen: 0
    events: 
        "eat": "eat"
module.exports = Land