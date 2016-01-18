local Timer = require "timer"
local Actions = require "actions"

local function nothing() end

describe("Action Primitives", function()
  describe("Actions.Empty", function()
    it("immediately invokes the continuation", function()
      local action, done = Actions.Empty(), false
      action(Timer, function() done = true end)
      assert.is_true(done)
    end)
  end)

  describe("Actions.Wait", function()
    it("invokes the contination after the duration", function()
      local action, done = Actions.Wait(2), false
      action(Timer, function() done = true end)
      assert.is_false(done)
      Timer.update(1)
      assert.is_false(done)
      Timer.update(1)
      assert.is_true(done)
    end)
  end)

  describe("Actions.Do", function()
    it("immediately invokes the provided function", function()
      local called = false
      local action, done = Actions.Do(function() called = true end), false
      action(Timer, function() done = true end)
      assert.is_true(done)
      assert.is_true(called)
    end)
  end)

  describe("Actions.Print", function()
    it("immediately prints to the console", function()
      local s = stub(_G, "print")
      local action = Actions.Print("message")
      action(Timer, nothing)
      assert.spy(print).was_called_with("message")
    end)
  end)

  describe("Actions.Tween", function()
    it("tweens the value", function()
      local object = { val = 0 }
      local action = Actions.Tween(2, object, { val = 100 }, 'linear')
      action(Timer, nothing)
      assert.are.equal(object.val, 0)
      Timer.update(1)
      assert.are.equal(object.val, 50)
      Timer.update(1)
      assert.are.equal(object.val, 100)
    end)
  end)
end)

describe("Action Combinators", function()
  describe("Actions.Sequence", function()
    it("executes a set of actions in sequence", function()
      local counter, done = 0, false
      local IncrementAction = Actions.Do(function()
        counter = counter + 1
      end)
      local action = Actions.Sequence(
        Actions.Wait(1), IncrementAction,
        Actions.Wait(1), IncrementAction
      )

      action(Timer, function() done = true end)
      assert.is_false(done)
      assert.are.equal(counter, 0)
      Timer.update(1)
      assert.is_false(done)
      assert.are.equal(counter, 1)
      Timer.update(1)
      assert.is_true(done)
      assert.are.equal(counter, 2)
    end)
  end)

  describe("Actions.Parallel", function()
    it("executes a set of actions in parallel", function()
      local counter, done = 0, false
      local IncrementAction = Actions.Do(function()
        counter = counter + 1
      end)
      local action = Actions.Parallel(
        Actions.Sequence(
          Actions.Wait(1), IncrementAction
        ),
        Actions.Sequence(
          Actions.Wait(1), IncrementAction
        )
      )

      action(Timer, function() done = true end)
      assert.is_false(done)
      assert.are.equal(counter, 0)
      Timer.update(1)
      assert.is_true(done)
      assert.are.equal(counter, 2)
    end)
  end)
end)
