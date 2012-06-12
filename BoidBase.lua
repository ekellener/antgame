--
-- Created by IntelliJ IDEA.
-- User: erik
-- Date: 5/7/12
-- Time: 5:02 PM
-- To change this template use File | Settings | File Templates.
--

require 'middleclass'
local sprite = require( "sprite" )
Vector2D = require("Vector2D")

BoidBase = class('BoidBase')
function BoidBase:initialize(location, ms, mf, displayobject, bsize)
    local object = {
        maxSpeed = ms,
        maxForce = mf,
        loc = location,
        vel = Vector2D:new(0,0),
        acc = Vector2D:new(0,0),
        displayObject = displayobject,
        boidsize = bsize,
        wanderTheta = 0.0

    }

  --  setmetatable(object, { __index = BoidBase })
  --  return object
end

function BoidBase:run(event)
    self:update()
    self:borders()
    self:render()
end

function BoidBase:update()
    -- Update velocity
    self.vel:add(self.acc)
    -- Limit speed
    self.vel:limit(self.maxSpeed)
    -- Move boid
    self.loc:add(self.vel)
    -- reset acceleration
    self.acc:mult(0)
end

function BoidBase:render()
    self.displayObject.x = self.loc.x
    self.displayObject.y = self.loc.y
end

function BoidBase:seek(target)
    self.acc = self:steer(target, false)
end

function BoidBase:arrive(target)
    self.acc = self:steer(target, true)
end

function BoidBase:steer(target, slowdown)
    local steer
    local desired = Vector2D:Sub(target, self.loc)
    local d = desired:magnitude()

    if d > 0 then
        desired:normalize()

        if slowdown and d < 100.0 then
            local dampSpeed = self.maxSpeed*(d/100.0) -- This damping is somewhat arbitrary
            desired:mult(dampSpeed)
        else
            desired:mult(self.maxSpeed)
        end

        steer = Vector2D:Sub(desired, self.vel)
        steer:limit(self.maxForce)
    else
        steer = Vector2D:new(0,0)
    end

    return steer
end

function BoidBase:borders()
    if self.loc.x + self.boidsize >= display.contentWidth - 5 then
        self.wanderTheta = math.pi

        self.loc.x = self.loc.x - 1
    end
    if self.loc.x <= 5 then
        self.wanderTheta = 0
        self.loc.x = self.loc.x + 1
    end

    if self.loc.y <= 5 then
        self.wanderTheta = math.pi/2
        self.loc.y = self.loc.y + 1
    end

    if self.loc.y + self.boidsize >= display.contentHeight - 5 then
        self.loc.y = self.loc.y - 1
        self.wanderTheta = (3 * math.pi) / 2
    end
end


function BoidBase:wander()
    local wanderR = 16.0
    local wanderD = 60.0
    local change  = 0.5

    local negChange = math.random(2)
    local randomNum = math.random() * change
    if negChange == 2 then
        self.wanderTheta = self.wanderTheta - randomNum
    else
        self.wanderTheta = self.wanderTheta + randomNum
    end

    local circleLoc = self.vel:copy()

    circleLoc:normalize()
    circleLoc:mult(wanderD)
    circleLoc:add(self.loc)

    local circleOffset = Vector2D:new(wanderR*math.cos(self.wanderTheta), wanderR*math.sin(self.wanderTheta))
    local target = circleLoc:copy()
    target:add(circleOffset)

    self.acc:add(self:steer(target))
end

--return BoidBase