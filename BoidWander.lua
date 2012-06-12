--
-- Created by IntelliJ IDEA.
-- User: erik
-- Date: 5/7/12
-- Time: 5:02 PM
-- To change this template use File | Settings | File Templates.
--

local sprite = require( "sprite" )

BoidWander = {}

Vector2D = require("Vector2D")

function BoidWander:new(location, ms, mf, si, bsize, wt, wr, wd, ch)
    local object = {
        maxSpeed = ms,
        maxForce = mf,
        loc = location,
        vel = Vector2D:new(0,0),
        acc = Vector2D:new(0,0),
              displayObject = si,
        BOID_SIZE = bsize or 4,
        wanderTheta = wt or 0.0,
        wanderR = wr or 16.0,
        wanderD= wd or 60.0,
        change  = ch or 0.5
    }

    setmetatable(object, { __index = Boid })
    return object
end

function Boid:run(event)
    self:update()
    self:borders()
    self:render()
end

function Boid:update()
    -- Update velocity
    self.vel:add(self.acc)
    -- Limit speed
    self.vel:limit(self.maxSpeed)
    -- Move boid
    self.loc:add(self.vel)
    -- reset acceleration
    self.acc:mult(0)
end

function Boid:render()
    self.displayObject.x = self.loc.x
    self.displayObject.y = self.loc.y
end

function Boid:seek(target)
    self.acc = self:steer(target, false)
end

function Boid:arrive(target)
    self.acc = self:steer(target, true)
end

function Boid:steer(target, slowdown)
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

function Boid:borders()
    if self.loc.x + self.BOID_SIZE >= display.contentWidth - 5 then
        self.self.wanderTheta = math.pi
        self.loc.x = self.loc.x - 1
    end
    if self.loc.x <= 5 then
        self.self.wanderTheta = 0
        self.loc.x = self.loc.x + 1
    end

    if self.loc.y <= 5 then
        self.self.wanderTheta = math.pi/2
        self.loc.y = self.loc.y + 1
    end

    if self.loc.y + self.BOID_SIZE >= display.contentHeight - 5 then
        self.self.wanderTheta = (3 * math.pi) / 2
        self.loc.y = self.loc.y - 1
    end
end

function Boid:wander()


    local negChange = math.random(2)
    local randomNum = math.random() * self.change
    if negChange == 2 then
        self.self.wanderTheta = self.self.wanderTheta - randomNum
    else
        self.self.wanderTheta = self.self.wanderTheta + randomNum
    end

    local circleLoc = self.vel:copy()

    circleLoc:normalize()
    circleLoc:mult(wanderD)
    circleLoc:add(self.loc)

    local circleOffset = Vector2D:new(self.wanderR*math.cos(self.self.wanderTheta), self.wanderR*math.sin(self.self.wanderTheta))
    local target = circleLoc:copy()
    target:add(circleOffset)

    self.acc:add(self:steer(target))
end

return Boid