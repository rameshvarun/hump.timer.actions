# hump.timer.actions [![Build Status](https://travis-ci.org/rameshvarun/hump.timer.actions.svg?branch=master)](https://travis-ci.org/rameshvarun/hump.timer.actions)
Composable actions, powered by [hump.timer](https://hump.readthedocs.org/en/latest/timer.html). Inspired by [LibGDX actions](https://github.com/libgdx/libgdx/wiki/Scene2d#actions). Represents a `monoid`. This approach also lends itself to manipulation by higher order functions (similar to parser combinators).

## Example
```lua
local Actions = require "actions"
local Timer = require "hump.timer"

local objectA = {val = 0}, objectB = {val = 0}
local action = Actions.Sequence(
	Actions.Print("Started action..."),
	Actions.Wait(3),
	Actions.Print("3 seconds passed..."),
	Actions.Parallel(
		Actions.Tween(3.0, objectA, {val=10}, 'linear'),
		Actions.Tween(2.0, objectB, {val=10}, 'linear')
	)
)

--[[ Play the action by calling it as a function.
The first argument is the Hump.Timer object used to run
events, and the second argument is a continuation to
be run on the completion of the action. ]]--
action(Timer, function()
	print("Continuation...")
end)
```

## Documentation
### Action Primitives
These functions return actions that, when played, will do something.
#### `Actions.Empty()`
An empty 'identity' action which does nothing.
#### `Actions.Wait(duration)`
An action which waits for the provided amount of seconds.
#### `Actions.Do(func)`
An action which invokes the provided function, then continues.
#### `Actions.Print(func)`
An action which prints to the console.
#### `Actions.Tween(duration, subject, target, method, ...)`
Tweens an object. See [Timer.tween](https://hump.readthedocs.org/en/latest/timer.html#Timer.tween) for more details.

### Combinators
Combinators take in actions, compose them, and return new actions that can be further composed.
#### `Actions.Sequence(...)`
Takes in a variable number of actions, and returns a new action which plays them all in sequence.
#### `Actions.Parallel(...)`
Takes in a variable number of actions, and returns a new action which plays them all in parallel. The continuation is invoked when

### Creating a Custom Action Primitive
Part of what makes this approach effective is that you can create your own Action primitives. Here are some examples.

```lua
function Actions.PlaySource(source)
  return function(timer, cont)
    love.audio.play(source)
    cont()
  end
end

function Actions.DestroyEntity(entity)
  return function(timer, cont)
    entity:destroy()
    cont()
  end
end
```
