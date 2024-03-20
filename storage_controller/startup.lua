Chat_box = peripheral.find("chatBox")
Inventory_manager = peripheral.find("inventoryManager")
Buffer_chest = peripheral.find("sophisticatedstorage:chest") -- Holds items for crafting
Buffer_barrel = peripheral.find("minecraft:barrel") -- To move items to and from the vault
Monitor = peripheral.find("monitor")

function Start()
  Monitor.setTextColour(colours.blue)
  Monitor.write("Initialising Storage..")
end
