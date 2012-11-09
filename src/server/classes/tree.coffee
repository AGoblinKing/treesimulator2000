Entity = require "./entity"

class Tree extends Entity
    init: ->
        @sets Entity::defaults
        @setBindings Entity::bindings
        @setEvents Entity::events
        @getEating()

    getEating: ->
        @eater = setTimeout =>
            @doEat()
            @getEating()
        , @minEatTime + Math.random()*(@maxEatTime-@minEatTime)

    doEat: ->
        # Go through view, take some minerals from surrounding area
        for entity in @map
            for nutrient in @bindings.nutrients
                if entity[nutrient] and entity[nutrient] > 0
                    entity.emit "eat", nutrient, @eatRate, @
    
    getFed: (what, howMuch, who) ->
        @[what] += howMuch 

    maxEatTime: 2
    minEatTime: .5
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


