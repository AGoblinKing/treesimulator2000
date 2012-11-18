Entity = require "../classes/entity"
    
class Action extends Entity

class Give extends Action
    defaults:
        what: []
        max: 0
        min: 0
        howMuch: 0
    events: 
        "take": ({what, howMuch}) -> 

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
    events: 
        "give": ({what, howMuch}) ->


class Move extends Action
    defaults:
        where: [0, 0, 0]

    # Attempt to move towards target
    do: () ->
            

module.exports =
    Move: Move
    Take: Take
    Action: Action
    Give: Give