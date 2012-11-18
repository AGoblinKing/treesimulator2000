# Wake up every so often
class Time extends Trigger
    defaults: 
        time: 100
        interval: false
    do: (fn) ->
        setTimeout =>
            fn()
            @do fn if interval
        , @time

class VariableTime extends Trigger
	defaults: 
		maxTime: 100
		minTime: 10
		interval: false
	do: (fn) ->
        setTimeout =>
            fn()
            @do fn if interval
        , @minTime+Math.random()*(@maxTime-@minTime)
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


module.exports = 
	Immediately: Immediately
	Reactive: Reactive
	Time: Time