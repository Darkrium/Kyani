KyaniItemMagnet = WeaponAbility:new()

function KyaniItemMagnet:init()
self.range = config.getParameter("magnetrange") or 1000

end

function KyaniItemMagnet:update(dt)
activeItem.setItemForceRegions({{type = "RadialForceRegion", categoryWhitelist = {"itemdrop"}, outerRadius = self.range, innerRadius = 2, controlForce = 200, targetRadialVelocity = -120}})
end
function KyaniItemMagnet:reset()
  self.active = false
end
function KyaniItemMagnet:uninit()
end