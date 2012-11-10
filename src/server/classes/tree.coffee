Entity = require "./entity"

class Tree extends Entity
    init: ->
        if @world
            @getEating()

    getEating: ->
        @eater = setTimeout =>
            @doEat()
            @getEating()
        , Math.floor((@minEatTime + Math.random()*(@maxEatTime-@minEatTime))*@eatTimeRate)

    doEat: ->
        # Go through view, take some minerals from surrounding area
        for location, entity of @map
            if entity.id != @id
                for nutrient in @bindings.nutrients
                    entity.emit "eat", 
                        what: nutrient
                        howMuch: @eatRate
                        who: @
    
    getFed: ({what, howMuch, who}) ->
        @[what] += howMuch 

    maxEatTime: 2
    minEatTime: .5
    eatTimeRate: 1000*60*60
    eatRate: 1
    defaults: 
        potassium: 0
        nitrogen: 0
        phosphorus: 0
    view: 1
    events: 
        "feed": "getFed"
    bindings: 
        nutrients: ["potassium", "nitrogen", "phosphorus"]

module.exports = Tree