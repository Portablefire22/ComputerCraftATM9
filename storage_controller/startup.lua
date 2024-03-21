Chat_box = peripheral.find("chatBox")
Inventory_manager = peripheral.find("inventoryManager")
Buffer_chest = peripheral.find("sophisticatedstorage:chest") -- Holds items for crafting
Buffer_barrel = peripheral.find("minecraft:barrel") -- To move items to and from the vault
Monitor = peripheral.find("monitor")

function Determine_state() -- Figure out what state the storage system was left in
  local file = fs.open("storage_state.dat", "r")
  if file == nil then
    Monitor.clear()
    Monitor.setTextColour(colours.red)
    Monitor.setCursorPos(1,1)
    Monitor.write("Previous storage state was not saved!")
    Monitor.setCursorPos(1,2)
    Monitor.write("Assuming system is in perfect condition!")
    return
  end
end

function Start()
  Monitor.setCursorPos(1,1)
  Monitor.setTextColour(colours.white)
  Monitor.write("Initialising Storage...")
  Determine_state()
end

Start()
