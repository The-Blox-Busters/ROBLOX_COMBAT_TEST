--!strict

type BaseItem = {
	Category: string,
	Name: string,
	Width: number,
	Height: number,
	MaxStack: number,
}

type EmptyItem = BaseItem & {
	Category: "Empty",
	Name: "Empty",
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

export type ItemProperties = EmptyItem | WeaponItem | MidKetItem

local ItemDatabase: { [string]: ItemProperties } = {
	empty = {
		Category = "Empty",
		Name = ".",
		Width = 1,
		Height = 1,
		MaxStack = 1,
	} :: EmptyItem,
	pistol = {
		Category = "Weapon",
		Name = "Pistol",
		Width = 2,
		Height = 1,
		MaxStack = 1,
	} :: WeaponItem,
}

return ItemDatabase
