Entity = require "Entity"

class Tree extends Entity
    init: ->
        @sets Entity::defaults
        @setBindings Entity::bindings
        @getEating()

    getEating: ->
        @eater = setTimeout =>
            @eat()
            @getEating()
        , @minEatTime + Math.random()*(@maxEatTime-@minEatTime)

    eat: ->
        # Go through view, take some minerals from surrounding area
        for entity in @map
            for nutrient in @bindings.nutrients
                if entity[nutrient] and entity[nutrient] > 0
                    entity.emit "eat", nutrient, @eatRate, @

    maxEatTime: 2
    minEatTime: .5
    eatRate: 1
    defaults: 
        potassium: 0
        nitrogen: 0
        phosphorus: 0
    bindings: 
        nutrients: ["potassium", "nitrogen", "phosphorus"]


