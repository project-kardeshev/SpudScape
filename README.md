# Mint Character

## Initialize

Initialize a mint by sending a message with `Action = "MintCharacter` and `Rarity` equal to any of the available rarities: "Common", "Uncommon", "Rare", "Epic", "Legendary"

An offer will be generated based on the adjusted cost of the selected rarity at the time of the message, and a return message will provide the cost to the user.

The offer will be valid for 30 blocks, or about 1 hour

## Finalize

Once an offer is in place, Transfer KARD into the the game PiD. The game will look for an offer in the Sender's wallet with a matching price and finalize the mint of whatever matching offer it finds.

Refunds coming soon.

## Withdraw

withdraw a pending initialized mint offer

`Action = "WithdrawCharacterMint"`: Declares the action you are trying to perform
`Rarity`: Optional, can specify the specific Rarity offer that you are revoking. Otherwise, all initialized offers are withdrawn.

# Get Token Data

## Get Token By ID

Gets the current state of a token based on its TokenID. Returns as a json encoded object

`Action = "GetTokenByID"`: Declares the action you are trying to perform
`TokenID`: The Token ID of token you want to query

## Get Tokens

Gets all Tokens owned by a Pid or wallet. Returns as a json encoded array

`Action = "GetTokens"`: Declares the action you are trying to perform
`Owner`: Optional, specifies the Pid or wallet you want to tokens of. If not provided, the sender of the message will be used.

# Move

Move a selected token by sending a message with the following:

`Action = "Move"`: Declares the action you are trying to perform
`FromToken`: This is the TokenID of the character that will be moving
`TargetLocation`: This is the location you are trying to move to, Must match a location name exactly

Moving to certain locations can automatically trigger combat, or an interaction with an NPC.

## Where Can I move

Find the names of locations a character can move from their current location. Returns as a json encoded array in Data

`Action = "WhereCanIMove"`: Declares the action you are trying to perform
`FromToken`: This is the TokenID of the character that will be moving

# Talk To NPC

Interacting with an NPC Can provide information, advance quest lines, or give the user equipment items.

`Action = "TalkToNPC"`: Declares the action you are trying to perform
`FromToken`: This is the TokenID of the character that will be interacting with the NPC
`TargetNPC`: This is the name of the NPC you are trying to interact with

## Who Can I Talk To 

Find the names of NPCs you are able to talk to at your current location. Returns as a json encoded array in Data

`Action = "WhoCanITalkTo"`: Declares the action you are trying to perform
`FromToken`: This is the TokenID of the character that will be interacting with an NPC


# Equipment

## Equip

Equips a specified equipment to a specified character

`Action = "Equip"`: Declares the action you are trying to perform
`FromToken`: This is the TokenID of the character you want to equip to
`EquipmentID`: This is the TokenID of the equipment you want to place on the character

## Unequip

Removes a specified equipment from character

`Action = "Unequip"`: Declares the action you are trying to perform
`FromToken`: This is the TokenID of the character you want to remove an nequipment from
`EquipmentID`: This is the TokenID of the equipment you want to remove


# Spend Attribute Points

When you level up, you are awarded Attribute points you can spend on stats:  `Health`, `Power`, `Defense`, `Speed`, `Precision`, and `Evasion`

Currently, 3 points are awarded per level, and every point spend on `Health` gives you 10 additional health. Points must be spent individually.

`Action = "SpendPoint"`: Declares the Action you are trying to perform
`FromToken`: This is the TokenID of the character you want to spend attribute points
`SpendOn`: This is the name of the stat you want to improve

# Rename

The owner of a character may change its name. Equipment may not be renamed at this time

`Action = "Rename"`: Declares the action you are trying to perform
`FromToken`: This is the TokenID of the character to be renamed
`NewName`: This is the new name for the character

# Combat

All messages sent by Spudscape that relate to an active combat instance will contain a `CombatInfo` field containing the current state of the combat instance, including the list of attacks available to both the player and NPC. This is returned as a json encoded object.

These messages will also include a `IsEndCombat` field, returned as a stringified boolean, indicating whether combat has ended.

## Enter Combat

Enters combat with a randomly selected combat NPC available at your current location. You cannot be in more than one combat instance at a time.

`Action = "EnterCombat"`: Declares the action you are trying to perform
`FromToken`: This is the TokenID of the character that will be entering combat

## Attack

While in combat, declares the attack your character will use, and processes one round of combat

`Action = "Attack"`: Declares the action you are trying to perform
`FromToken`: This is the TokenID of the character in combat
`Attack`: The name of the attack you want to perform.

# Who Can I Fight

Gets a list of possible enemies for an area. Returns as a json encoded array of objects, containing the name and level of each potential enemy. This is NOT a combat message and will not contain `CombatInfo` or `IsEndCombat`

`Action = "WhoCanIFight"`: Declares the action you are trying to perform
`FromToken`: This is the TokenID of the character performing the action
`TargetLocation`: Optional, specify a location name to receive the enemy list for that location. If omitted, uses the current location of the token specified in `FromToken`
