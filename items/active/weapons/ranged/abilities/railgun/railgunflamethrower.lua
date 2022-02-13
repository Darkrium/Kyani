require "/items/active/weapons/ranged/gunfire.lua"

FlamethrowerAttack = GunFire:new()

function FlamethrowerAttack:init()
  GunFire.init(self)

  self.active = false
  script.setUpdateDelta(1)
end

function FlamethrowerAttack:update(dt, fireMode, shiftHeld)
  GunFire.update(self, dt, fireMode, shiftHeld)

  if self.weapon.currentAbility == self then
    if not self.active then self:activate() end
  elseif self.active then
    self:deactivate()
  end
end

function FlamethrowerAttack:muzzleFlash()
  --disable normal muzzle flash
end

function FlamethrowerAttack:activate()
  self.active = true
end

function FlamethrowerAttack:deactivate()
  self.active = false
end
