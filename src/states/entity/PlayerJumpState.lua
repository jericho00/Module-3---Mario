
PlayerJumpState = Class{__includes = BaseState}

function PlayerJumpState:init(player, gravity)
    self.player = player
    self.gravity = gravity
    self.animation = Animation {
        frames = {3},
        interval = 1
    }
    self.player.currentAnimation = self.animation
end

function PlayerJumpState:enter(params)
    gSounds['jump']:play()
    self.player.dy = PLAYER_JUMP_VELOCITY
end

function PlayerJumpState:update(dt)
    self.player.currentAnimation:update(dt)
    self.player.dy = self.player.dy + self.gravity
    self.player.y = self.player.y + (self.player.dy * dt)

    if self.player.dy >= 0 then
        self.player:changeState('falling')
    end

    self.player.y = self.player.y + (self.player.dy * dt)

    local tileLeft = self.player.map:pointToTile(self.player.x + 3, self.player.y)
    local tileRight = self.player.map:pointToTile(self.player.x + self.player.width - 3, self.player.y)

    if (tileLeft and tileRight) and (tileLeft:collidable() or tileRight:collidable()) then
        self.player.dy = 0
        self.player:changeState('falling')

    elseif love.keyboard.isDown('left') then
        self.player.direction = 'left'
        self.player.x = self.player.x - PLAYER_WALK_SPEED * dt
        self.player:checkLeftCollisions(dt)
    elseif love.keyboard.isDown('right') then
        self.player.direction = 'right'
        self.player.x = self.player.x + PLAYER_WALK_SPEED * dt
        self.player:checkRightCollisions(dt)
    end

    for k, object in pairs(self.player.level.objects) do
        if object:collides(self.player) then
            if object.solid then
                object.onCollide(object)

                self.player.y = object.y + object.height
                self.player.dy = 0
                
                if self.player.keyPicked and object.texture == 'keys-and-locks' then
                    table.remove(self.player.level.objects, k)
                end

                self.player:changeState('falling')
            elseif object.consumable then
                object.onConsume(self.player)
                table.remove(self.player.level.objects, k)
            end
        end
    end

    for k, entity in pairs(self.player.level.entities) do
        if entity:collides(self.player) then
            gSounds['death']:play()
            gStateMachine:change('start')
        end
    end
end