Chat_box = peripheral.find("chatBox")
Inventory_manager = peripheral.find("inventoryManager")
Buffer_chest = peripheral.find("sophisticatedstorage:chest") -- Holds items for crafting
Buffer_barrel = peripheral.find("minecraft:barrel") -- To move items to and from the vault
Redstone_integrator = peripheral.find("redstoneIntegrator")
Monitor = peripheral.find("monitor")
Grid = {}
WIDTH = 21
HEIGHT = 11

function Set_grabber(state)
  Redstone_integrator.setOutput("east", state)
end

function Set_Horz_Movement(state)
  Redstone_integrator.setOutput("south", not state) -- Stops if true
end

function Set_Vert_Movement(state)
  Redstone_integrator.setOutput("down", not state)
end

function Set_Movement(state)
  Redstone_integrator.setOutput("west", state)
end

function Set_clutch(state)
  Redstone_integrator.setOutput("up", state)
end

function Home_gantry()
  -- I ain't got anything to figure out if it is home
  -- So I'll just send it home and wait 10s between each input
  Set_Vert_Movement(true)
  Set_Horz_Movement(false)
  Set_Movement(true)
  os.sleep(10)
  Set_Movement(false)
  Set_Vert_Movement(false)
  Set_Horz_Movement(true)
  Set_Movement(true)
end

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
      else
        Monitor.write(" ") -- Keep it all in line
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
  Home_gantry()
end

Start()
