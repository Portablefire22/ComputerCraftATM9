local grid_api = require("grid_api")

Chat_box = peripheral.find("chatBox")
Inventory_manager = peripheral.find("inventoryManager")
Buffer_chest = peripheral.find("sophisticatedstorage:chest") -- Holds items for crafting
Monitor = peripheral.find("monitor")


Item_map = {}

function Display_grid()
  Monitor.clear()
  Monitor.setCursorPos(1,1)
  Monitor.setTextColour(colours.blue)
  for y in pairs(grid_api.Grid) do
    Monitor.setCursorPos(1,y)
    for x in pairs(grid_api.Grid[y]) do
      if y == 6 and x == 11 then 
        Monitor.setTextColour(colours.orange)
      end
      Monitor.write("[")
      if next(grid_api.Grid[y][x]) ~= nil then
        Monitor.setTextColour(colours.white)
        Monitor.write("X")
        Monitor.setTextColour(colours.blue)
      else
        Monitor.write(" ") -- Keep it all in line
      end
      if y == 6 and x == 11 then 
        Monitor.setTextColour(colours.orange)
      end
      Monitor.write("]")
      Monitor.setTextColour(colours.blue)
    end
  end
end

function Save_items()
  local file = fs.open("stored_items.map", "w")
  file.write(textutils.serialize(Item_map))
  file.close()
end

function Cmd()
  local input = read()
end

function Runtime()
  grid_api.Load_vault(1,1)
  Display_grid()
  os.sleep(2)
  grid_api.Unload_vault(15, 3)
  grid_api.Display_grid()
  grid_api.Move_vault(15, 3, 1, 1)
  Display_grid()
end

function Start()
  grid_api.Init()
  Monitor.clear()
  Monitor.setCursorPos(1,1)
  Monitor.setTextColour(colours.white)
  Monitor.write("Initialising Storage...")
  Display_grid()
  Runtime()
  --Load_vault(1,1)
  --os.sleep(2)
  --Unload_vault(15, 3)
  --Move_vault(15, 3, 1, 1)
end

Start()
