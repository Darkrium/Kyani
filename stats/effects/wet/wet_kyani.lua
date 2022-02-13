local oldinit = init

function init()
oldinit()
effect.addStatModifierGroup({{stat = "kyani_wet", amount = 1}})
end 