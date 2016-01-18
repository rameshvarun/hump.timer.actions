--[[
The MIT License (MIT)

Copyright (c) 2015 Varun Ramesh

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local Actions = {}

-- Empty action.
function Actions.Empty()
  return function(timer, cont) cont() end
end

-- Wait action.
function Actions.Wait(duration)
  return function(timer, cont)
    timer.after(duration, function() cont() end)
  end
end

-- Run a function.
function Actions.Do(func)
  return function(timer, cont)
    func()
    cont()
  end
end

-- Print action.
function Actions.Print(...)
  local args = {...}
  return function(timer, cont)
    print(unpack(args))
    cont()
  end
end

-- Tween action.
function Actions.Tween(duration, subject, target, method, ...)
  local extraArgs = {...}
  return function(timer, cont)
    timer.tween(duration, subject, target, method, cont, unpack(extraArgs))
  end
end

-- Shallow clone helper function. Taken from lume.
local function shallow_clone(t)
  local rtn = {}
  for k, v in pairs(t) do rtn[k] = v end
  return rtn
end

-- Sequence combinator.
function Actions.Sequence(...)
  local args = {...}

  return function(timer, cont)
    local actions = shallow_clone(args)
    if #actions == 0 then cont()
    else
      local head = table.remove(actions, 1)
      head(timer, function() Actions.Sequence(unpack(actions))(timer, cont) end)
    end
  end
end

-- Parallel combinator.
function Actions.Parallel(...)
  local args = {...}

  return function(timer, cont)
    local actions = shallow_clone(args)
    local numCompleted = 0
    local onCompletion = function()
      numCompleted = numCompleted + 1
      if numCompleted == #actions then cont() end
    end

    for _, action in ipairs(actions) do
      action(timer, onCompletion)
    end
  end
end

return Actions
