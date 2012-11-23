Base = require "../classes/base"
    
class Action extends Base

class Give extends Action
    defaults:
        what: []
        max: 0
        min: 0
        howMuch: 0

    reactions: 
        "give": ({what, howMuch}) ->
            @entity[what] += howMuch
        

    # Attempt to give an item
    do: ({}) ->


class Take extends Action
    defaults:
        what: []
        howMuch: []
        distance: 0

    do: () ->
        for location, entity of @entity.map
            # Don't consume yourself
            if entity.id != @entity.id
                entity.emit "take", 
                    what: @what
                    with: @with
                    who: @
    reactions: 
        "take": ({what, howMuch, who}) ->
            if @entity[what] and @entity[what] > 0
                if @entity[what] <= howMuch
                    howMuch = @[what]


                # This could fail and the resources disappear
                @entity[what] -= howMuch
                who.emit "give",
                    what: what
                    howMuch: howMuch
                    who: @

module.exports =
    Take: Take
    Action: Action
    Give: Give