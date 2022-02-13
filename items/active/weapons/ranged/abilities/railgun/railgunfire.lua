require "/scripts/util.lua"
require "/scripts/interp.lua"

RailgunFire = WeaponAbility:new()

function RailgunFire:init()
  self.weapon:setStance(self.stances.idle)

  self.reloadTimer = self.reloadTime

  self.currentStack = 0

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

function RailgunFire:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.reloadTimer = math.max(0, self.reloadTimer - self.dt)

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and self.reloadTimer == 0
    and not self.weapon.currentAbility
    and not world.lineTileCollision(mcontroller.position(), self:firePosition())
    and not status.resourceLocked("energy") then

    self:setState(self.charge)
  end
end

function RailgunFire:charge()

  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    if self.reloadTimer == 0
        and self.currentStack < 0.9999
        and status.overConsumeResource("energy", self.energyPerShot) then

      self.currentStack = self.currentStack + self.chargeStep
      self:reload()
    end

    status.setResourcePercentage("energyRegenBlock", 1.0)

    coroutine.yield()
  end

  self:setState(self.fire)
end

function RailgunFire:reload()
  self.reloadTimer = self.reloadTime
  
  animator.playSound("reload")
end

function RailgunFire:fire()
  if world.lineTileCollision(mcontroller.position(), self:firePosition()) then
    self:setState(self.cooldown)
	self.currentStack = 0
    return
  end
    if self.currentStack < 0.9999 then
    self:setState(self.cooldown)
	self.currentStack = 0
    return
  end

  self.weapon:setStance(self.stances.fire)

  animator.playSound("fire")

  self:fireProjectiles()
  self.currentStack = 0
  self:reload()

  if self.stances.fire.duration then
    util.wait(self.stances.fire.duration)
  end

  self:setState(self.cooldown)
end

function RailgunFire:cooldown()
  self.weapon:setStance(self.stances.cooldown)
  self.weapon:updateAim()

  local progress = 0
  util.wait(self.stances.cooldown.duration, function()
    local from = self.stances.cooldown.weaponOffset or {0,0}
    local to = self.stances.idle.weaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.armRotation, self.stances.idle.armRotation))

    progress = math.min(1.0, progress + (self.dt / self.stances.cooldown.duration))
  end)
end

function RailgunFire:fireProjectiles()
  local params = copy(self.projectileParameters)
  params.power = self.baseDamage * config.getParameter("damageLevelMultiplier")
  params.powerMultiplier = activeItem.ownerPowerMultiplier()


  for i = 1, self.currentStack do
    projectileId = world.spawnProjectile(
        self.projectileType,
        self:firePosition(),
        activeItem.ownerEntityId(),
        self:aimVector(currentAngle),
        false,
        params
      )
    currentAngle = currentAngle 
  end
end

function RailgunFire:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function RailgunFire:aimVector()
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle)
  aimVector[1] = aimVector[1] * self.weapon.aimDirection
  return aimVector
end

function RailgunFire:uninit()

end
