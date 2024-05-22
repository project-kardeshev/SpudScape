State = State or {}

State.NextID = State.NextID or 1

State.Holders = State.Holders or {}

State.Tokens = State.Tokens or {}

State.ActiveCombat = State.ActiveCombat or {}

State.TransferOffers = State.TransferOffers or {
    Buy = {},
    Sell = {}
}

State.BaseCosts = {
    Common = 100000,
    Uncommon = 250000,
    Rare = 500000,
    Epic = 1000000,
    Legendary = 2500000
}

State.MintNumbers = State.MintNumbers or {
    Common = 0,
    Uncommon = 0,
    Rare = 0,
    Epic = 0,
    Legendary = 0
}

State.PendingMints = State.PendingMints or {}

State.priceModifiers = {
    Common = 1,
    Uncommon = 1.02,
    Rare = 1.05,
    Epic = 1.1,
    Legendary = 1.5
}


function State.ResetState()
State.MintNumbers = {
    Common = 0,
    Uncommon = 0,
    Rare = 0,
    Epic = 0,
    Legendary = 0
}

State.Holders = {}
State.Tokens = {}
State.PendingMints = {}
State.NextID = 1
State.ActiveCombat = {}
State.TransferOffers = {
    Buy = {},
    Sell = {}
}
end

return State