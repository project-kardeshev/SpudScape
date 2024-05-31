Handlers.add(
    "PrintMessages",
    Handlers.utils.hasMatchingTag("From-Process", game2),
   function (msg) 
    print(msg.Action)
    print(msg.Data)
   end
)