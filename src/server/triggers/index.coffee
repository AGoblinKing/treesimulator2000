# Wake up every so often
Base = require "../classes/base"

class Trigger extends Base
    register: () ->

class Time extends Trigger
    defaults: 
        time: 100
        interval: false

    register: (fn) ->
        setTimeout =>
            fn()
            @register fn if interval
        , @time

class VariableTime extends Trigger
    defaults: 
        max: 100
        min: 10
        interval: false

    register: (fn) ->
        setTimeout =>
            fn()
            @register fn if @interval
        , @min+Math.random()*(@max-@min)

# Wake up when map changes with property
class Reactive extends Trigger
    defaults:
        what: []

    register: (fn) -> 
        @entity.on "view:change", ({entity}) =>
            if name in @what
                fn 
                    entity: entity

class Change extends Trigger
    defaults: 
        what: {}

    register: (fn) ->
        for prop, amount of @what
            do (prop, amount) =>
                @entity.on "change:#{prop}", ({dif}) =>
                    if Math.abs(dif) >= amount
                        fn 
                            entity: @entity

class Immediately extends Trigger
    register: (fn) ->
        fn()

module.exports = 
    Immediately: Immediately
    Reactive: Reactive
    Time: Time
    Change: Change
    Trigger: Trigger
    VariableTime: VariableTime

 
