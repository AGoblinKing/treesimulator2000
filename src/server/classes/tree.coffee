Entity = require "./entity"

class Tree extends Entity
    setWorld: (@world) ->
        super @world
        @getEating()
        @getBreeding()

    getBreeding: () ->
        @breeder = setTimeout =>
            if @potassium > @spawnCost and @nitrogen > @spawnCost  and @phosphorus > @spawnCost 
                @spawn()
            @getBreeding()
        , Math.floor((@minSpawnRate + Math.random()*(@maxSpawnRate-@minSpawnRate))*@timeRate)

    getEating: ->
        @eater = setTimeout =>
            @doEat()
            @getEating()
        , Math.floor((@minEatTime + Math.random()*(@maxEatTime-@minEatTime))*@timeRate)

    getSpawnDistance: () ->
        Math.floor(@minSpawnDistance + Math.random()*(@maxSpawnDistance-@minSpawnDistance+1)) * -Math.round(Math.random())
    spawn: ->
        for nutrient in @bindings.nutrients
            @[nutrient] -= @spawnCost

        tree = new Tree 
            x: @x + @getSpawnDistance()
            y: @y + @getSpawnDistance()
            z: 1

        @world.add tree


    upkeep: ->
        for nutrient in @bindings.nutrients
            @[nutrient] -= @upkeepRate

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
    maxSpawnDistance: 3
    minSpawnDistance: 2
    spawnCost: 20
    maxSpawnRate: 10
    minSpawnRate: 5
    timeRate: 1000
    eatRate: 2
    defaults: 
        potassium: 5
        nitrogen: 5
        type: "tree"
        phosphorus: 5
    view: 1
    events: 
        "feed": "getFed"
 
    bindings: 
        nutrients: ["potassium", "nitrogen", "phosphorus"]

module.exports = Tree