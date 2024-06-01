# Mint Character

## Initialize

Initialize a mint by sending a message with `Action = "MintCharacter` and `Rarity` equal to any of the available rarities: "Common", "Uncommon", "Rare", "Epic", "Legendary"

An offer will be generated based on the adjusted cost of the selected rarity at the time of the message, and a return message will provide the cost to the user.

The offer will be valid for 30 blocks, or about 1 hour

Each rarity level of character will cost more depending on how many of that rarity have been minted before

## Finalize

Once an offer is in place, Transfer KARD into the the game PiD. The game will look for an offer in the Sender's wallet with a matching price and finalize the mint of whatever matching offer it finds.

Include in the Transfer message the tag:

`X-Note = Mint Character`

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

If the moving character is a member of a party, all members of that party will also move. Location enter events will only trigger once.

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

All members of a party will enter combat together.

## Attack

While in combat, declares the attack your character will use, and processes one round of combat
Enemy IDs are an index of the number of enemies in combat.

`Action = "Attack"`: Declares the action you are trying to perform
`FromToken`: This is the TokenID of the character in combat
`Attack`: The name of the attack you want to perform. Used in single combat only. 
    Syntax: `Attack="<attackName>:<TargetID>"`
        `Attack = "Punch:1"`
`Attacks`: List of attacks being performed by all parties in combat.
    Syntax: `Attacks = "<TokenID>=<attackName>:<TargetID>, <TokenID>=<attackName>:<TargetID>"`
        `Attacks = "1=Punch:1, 2=Punch:1, 3=Punch:1"`

# Who Can I Fight

Gets a list of possible enemies for an area. Returns as a json encoded array of objects, containing the name and level of each potential enemy. This is NOT a combat message and will not contain `CombatInfo` or `IsEndCombat`

`Action = "WhoCanIFight"`: Declares the action you are trying to perform
`FromToken`: This is the TokenID of the character performing the action
`TargetLocation`: Optional, specify a location name to receive the enemy list for that location. If omitted, uses the current location of the token specified in `FromToken`

# Market Place

## Make Offer

Makes an offer to buy a character or piece of equipment from another holder.

`Action = "MakeBuyOffer"`: Declares the action you are trying to perform
`TokenID`: The Token ID of the token you are trying to purchase
`Offer`: The amount of your buy offer, in $Kants (Smallest unit of $KARD) - Minimum of 1000 (1 $Kard)

Making an additional offer for a lower amount on the same token will trigger a refund of the difference, if the offer is funded. An additional offer for a higher amount will trigger a message requesting additional funding.

No offer may be made on a token with an offer that has already been accepted, but has not been completed due to insufficient funding.

## Withdraw Offer

Withdraws a pending Buy offer

`Action = "WithdrawBuyOffer"`: Declares the action you are trying to perform.
`TokenID`: The token ID that the buy offer was for.

Any amount of $KARD that was funded on the offer will be refunded when an offer is withdrawn.

## Fund Offer

Buyers may put up the $KARD alongside their offer to allow instant transfer when the token owner accepts the offer. Transfer the offered amount of $KARD into the SpudScape process along with the added tag:

`X-Note = "fund for <TokenID>"`
    `X-Note = "fund for 1"`

Partial funding is supported, excess funding will result in a refund of the difference, and only the process or wallet that made the offer can fund an offer.
If an offer is accepted before it is funded, the transfer will be completed when the offer is funded.

## Accept offer

Accepts a buy offer, and initiates transfer of token if offer is funded.

`Action = "AcceptBuyOffer"`: Declares the action you are trying to perform
`TokenID`: The Token ID of the token you are accepting an offer for
`Quantity`: The amount of the offer you are accepting, in $Kants (Smallest unit of $KARD)

When an offer is accepted, all other offers for the same token are refunded and removed. No other offers may be made on the token until the transfer is complete.

If the accepted offer is funded, the transfer will occur at that point. If not, the buyer will be notified.

Characters will have all equipment removed from them at the time of the transfer, so only the character is transferred. 
An error will occur if the offer is for a piece of equipment that is equipped. SpudScape will eventually automatically unequip those items rather than error. 

If an error occurs during acceptance, the Seller will need to send an accept message again to transfer the token after the error has been resolved.

The seller will receive 95% of the purchase price. 
2.5% will go to the original minter of the token
2.5% will remain with SpudScape as a processing fee.

## Transfer

Allows for a free transfer of a character or equipment token

`Action = "TransferToken"`: Declares the action you are trying to perform
`TransferTo`: The target process or wallet you want to transfer tokens into
`TokenID`: The Token ID of the token you want to transfer


# Parties

## Set Party

Sets the makeup of a party of characters.

`Action = "SetParty"`: Declares the action you are trying to perform
`Party`: the TokenIDs of the characters you want to include in the party
    Syntax: `Party = "<TokenID>, <TokenID>, <TokenID>"`
        `Party = "1, 2, 3"`
`FromToken`: The Token ID of the token that will represent the head of the party (required, but not implemented)

All party members must be in the Tavern in order to join a party.
The party will move and enter combat together using the standard move and enter combat commands.

## Disband Party

YOU CAN'T!!!! HAHAHA YOU ARE STUCK FOREVER!!!!