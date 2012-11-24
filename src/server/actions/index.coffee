Base = require "../classes/base"
    
class Action extends Base
    do: () ->
    reactions: {}

class Give extends Action
    defaults:
        what: []
        max: 0
        min: 0
        howMuch: []

    reactions: 
        "give": ({what}) ->
            for item, amount of what 
                @entity[item] += amount


class Take extends Action
    defaults:
        what: {}
        distance: 0

    do: () ->
        for location, entity of @entity.map
            # Don't consume yourself
            if entity.id != @entity.id
                entity.emit "take", 
                    what: @what
                    who: @entity
    reactions: 
        "take": ({what, who}) ->
            whatToGive = {}
            for item, amount of what
                if @entity[item] and @entity[item] > 0
                    if @entity[item] <= amount
                        amount = @entity[item]
                    # This could fail and the resources disappear
                    @entity[item] -= amount
                    whatToGive[item] = amount

            who.emit "give",
                what: whatToGive
                who: @entity

module.exports =
    Take: Take
    Action: Action
    Give: Give