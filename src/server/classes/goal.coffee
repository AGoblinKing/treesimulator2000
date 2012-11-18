Entity = require "./entity"

# Wake up every so often
class Time extends Trigger
    defaults: 
        time: 100
        interval: false
    do: (fn) ->
        setTimeout =>
            fn()
            @execute fn if interval
        , @time

# Wake up when map changes with property
class Reactive extends Trigger
    defaults:
        what: []
    do: (fn) -> 
        @entity.on "view:change", (entity, name, value) =>
            if name in @what
                fn entity, name, value

class Immediately extends Trigger
    do: (fn) ->
        fn()

class Move extends Action
    defaults:
        where: [0, 0, 0]

    # Attempt to move towards target
    do: () ->

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

class Breed extends Action
    defaults: 
        what