Chat_box = peripheral.find("chatBox")
Inventory_manager = peripheral.find("inventoryManager")
Buffer_chest = peripheral.find("sophisticatedstorage:chest") -- Holds items for crafting
Buffer_barrel = peripheral.find("minecraft:barrel") -- To move items to and from the vault
Monitor = peripheral.find("monitor")
Grid = {}
WIDTH = 21
HEIGHT = 11

function Display_grid()
  Monitor.clear()
  Monitor.setCursorPos(1,1)
  Monitor.setTextColour(colours.blue)
  for y in pairs(Grid) do
    Monitor.setCursorPos(1,y)
    for x in pairs(Grid[y]) do
      Monitor.write("[")
      if next(Grid[y][x]) ~= nil then
        Monitor.setTextColour(colours.white)
        Monitor.write("X")
        Monitor.setTextColour(colours.blue)
      end
      Monitor.write("]")
    end
  end
end

function Setup_grid()
  for y=1,HEIGHT do
    Grid[y] = {}
    for x=1,WIDTH do
      if x % 2 == 0 then 
        Grid[y][x] = {}
      else 
        Grid[y][x] = {0}
      end 
    end
  end
end

function Determine_state() -- Figure out what state the storage system was left in
  local file = fs.open("storage_state.dat", "r")
  if file == nil then
    Monitor.clear()
    Monitor.setTextColour(colours.red)
    Monitor.setCursorPos(1,1)
    Monitor.write("Previous storage state was not saved!")
    Monitor.setCursorPos(1,2)
    Monitor.write("Assuming system is completely empty!")
    Setup_grid()
    Monitor.setCursorPos(1,3)
    Monitor.write("Blank grid created!")
    os.sleep(2.5)
    return
  end
end

function Start()
  Monitor.setCursorPos(1,1)
  Monitor.setTextColour(colours.white)
  Monitor.write("Initialising Storage...")
  Determine_state()
  Display_grid()
end

Start()
