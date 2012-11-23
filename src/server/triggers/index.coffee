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
        maxTime: 100
        minTime: 10
        interval: false

    register: (fn) ->
        setTimeout =>
            fn()
            @register fn if interval
        , @minTime+Math.ranregisterm()*(@maxTime-@minTime)

# Wake up when map changes with property
class Reactive extends Trigger
    defaults:
        what: []

    register: (fn) -> 
        @entity.on "view:change", (entity, name, value) =>
            if name in @what
                fn entity, name, value

class Immediately extends Trigger
    register: (fn) ->
        fn()

module.exports = 
    Immediately: Immediately
    Reactive: Reactive
    Time: Time
    Trigger: Trigger

 
