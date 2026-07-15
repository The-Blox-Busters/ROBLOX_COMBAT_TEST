--!strict

-- ! Must Read
-- TODO: in future this module will be moved from inventory folder and shared with weapon system and other systems
type BaseItem = {
	Category: string,
	Width: number,
	Height: number,
	MaxStack: number,
}

export type WeaponItem = BaseItem & {
	Category: "Weapon",
	--Damage: number, -- ? Use this for weapon system
	--FireRate: number,
}
export type MidKetItem = BaseItem & {
	Category: "MidKet",
	Recovery: number,
}

export type ItemProperties = WeaponItem | MidKetItem

local ItemDatabase: { [string]: ItemProperties } = {
	pistol = {
		Category = "Weapon",
		Width = 2,
		Height = 1,
		MaxStack = 1,
	} :: ItemProperties,
}

return ItemDatabase
