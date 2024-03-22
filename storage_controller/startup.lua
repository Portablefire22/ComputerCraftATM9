Chat_box = peripheral.find("chatBox")
Inventory_manager = peripheral.find("inventoryManager")
Buffer_chest = peripheral.find("sophisticatedstorage:chest") -- Holds items for crafting
Monitor = peripheral.find("monitor")

os.loadAPI("grid_api.lua")
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


function Determine_state() -- Figure out what state the storage system was left in
  local file = fs.open("storage_state.dat", "r")
  local grid = false
  local pos = false
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
    Save_grid_state()
    grid = true
  end
  local position_file = fs.open("gantry_state.dat", "r")
  if position_file == nil then
    if grid then 
      Monitor.clear()
      Monitor.setCursorPos(1,1)
    else 
      Monitor.setCursorPos(1,4)
    end
    Monitor.write("Position not found, defaulting to (1,1)")
    Home_gantry()
    pos = true
    Save_gantry_state()
  end

  if not grid then
    grid_api.Grid = textutils.unserialize(file.readAll())
  end
  if not pos then
    local position = textutils.unserialize(position_file.readAll())
    print(position)
    grid_api.POS_X = position["X"]
    grid_api.POS_Y = position["Y"]
  end
  if not grid or not pos then 
    os.sleep(2.5) -- Allow the user to read it?
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
  grid_api.Display_grid()
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
  Determine_state()
  Display_grid()
  Runtime()
  --Load_vault(1,1)
  --os.sleep(2)
  --Unload_vault(15, 3)
  --Move_vault(15, 3, 1, 1)
end

Start()
