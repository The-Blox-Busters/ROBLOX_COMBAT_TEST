--!strict

type BaseItem = {
	Category: string,
	Name: string,
	Width: number,
	Height: number,
	MaxStack: number,
	Color: Color3,
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

export type ItemProperties = BaseItem | EmptyItem | WeaponItem

local ItemDatabase: { [string]: ItemProperties } = {
	empty = {
		Category = "Empty",
		Name = ".",
		Width = 1,
		Height = 1,
		MaxStack = 1,
		Color = Color3.fromHex("#0222ff"),
	} :: EmptyItem,
	pistol = {
		Category = "Weapon",
		Name = "Pistol",
		Width = 2,
		Height = 1,
		MaxStack = 1,
		Color = Color3.fromHex("ab0cdf"),
	} :: WeaponItem,
	ammo = {
		Category = "Ammo",
		Name = "Ammo",
		Width = 1,
		Height = 1,
		MaxStack = 50,
		Color = Color3.fromHex("#fbff02"),
	},
	medkit = {
		Category = "MedKit",
		Name = "MedKit",
		Width = 1,
		Height = 1,
		MaxStack = 10,
		Color = Color3.fromHex("#ff0000"),
	},
}

return ItemDatabase
