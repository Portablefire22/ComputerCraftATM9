Chat_box = peripheral.find("chatBox")
Inventory_manager = peripheral.find("inventoryManager")
Buffer_chest = peripheral.find("sophisticatedstorage:chest") -- Holds items for crafting
Buffer_barrel = peripheral.find("minecraft:barrel") -- To move items to and from the vault
Redstone_integrator = peripheral.wrap("redstoneIntegrator_3")
Monitor = peripheral.find("monitor")
Redstone_integrator_2 = peripheral.wrap("redstoneIntegrator_4")
Grid = {}
POS_X = 1
POS_Y = 1
WIDTH = 21
HEIGHT = 11

function Toggle_grabber()
  Redstone_integrator.setOutput("east", true)
  os.sleep(0.2)
  Redstone_integrator.setOutput("east", false)
end

function Extend_piston()
  Chat_box.sendMessage("Extending")
  Stop(true)
  os.sleep(0.2)
  Set_Reverse(true)
  Set_Vert_Movement(true)
  Set_Horz_Movement(true)
  Stop(false)
  for i=1,3 do 
    Increment_position()
    os.sleep(0.2)
  end
end

function Retract_piston()
  Stop(true)
  Chat_box.sendMessage("Retracting")
  os.sleep(0.2)
  Set_Reverse(false)
  Set_Vert_Movement(true)
  Set_Horz_Movement(true)
  Stop(false)
  for i=1,3 do 
    Increment_position()
    os.sleep(0.2)
  end
end

function Set_Horz_Movement(state)
  Redstone_integrator.setOutput("south", state) -- Stops if true
end

function Set_Vert_Movement(state)
  Redstone_integrator.setOutput("north", state)
end

function Set_Reverse(state)
  Redstone_integrator.setOutput("west", state)
end

function Stop(state)
  Redstone_integrator.setOutput("up", state)
end

function Increment_position()
  Redstone_integrator_2.setOutput("up", true)
  os.sleep(0.2)
  Redstone_integrator_2.setOutput("up", false)
  os.sleep(0.6)
end

function Home_gantry()
  -- I ain't got anything to figure out if it is home
  -- So I'll just send it home and wait 10s between each input

  -- Home it horizontally
  Stop(true)
  Set_Vert_Movement(false)
  Set_Horz_Movement(true)
  Set_Reverse(true)
  os.sleep(0.2)
  Stop(false)
  Chat_box.sendMessage("Homing Horizontally")
  for i=1,21 do 
    Increment_position()
  end

  -- Home it vertically
  Stop(true)
  Set_Vert_Movement(true)
  Set_Horz_Movement(false)
  os.sleep(0.2)
  Stop(false)
  Chat_box.sendMessage("Homing Vertically")
  for i=1,11 do 
    Increment_position()
  end

  -- Reset
  os.sleep(0.2)
  Stop(true)
  Set_Horz_Movement(false)
  Set_Vert_Movement(false)
  Set_Reverse(false)
  Chat_box.sendMessage("Finished Homing")
  POS_X = 1
  POS_Y = 1
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

function Move_X(blocks, is_backward)
  Stop(true)
  Set_Vert_Movement(false)
  Set_Horz_Movement(true)
  Set_Reverse(is_backward)
  os.sleep(0.2)
  Stop(false)
  for i=1,blocks+1 do 
    Increment_position()
    if is_backward then 
      POS_X = POS_X - 1
    else
      POS_X = POS_X + 1
    end
    Chat_box.sendMessage(string.format("X: %d", POS_X))
  end
  Stop(true)
end

function Move_Y(blocks, is_backward)
  Stop(true)
  Set_Vert_Movement(true)
  Set_Horz_Movement(false)
  Set_Reverse(is_backward)
  os.sleep(0.2)
  Stop(false)
  for i=1,blocks+1 do 
    Increment_position()
    if is_backward then
      POS_Y = POS_Y - 1
    else
      POS_Y = POS_Y + 1
    end
    Chat_box.sendMessage(string.format("Y: %d", POS_Y))

  end
  Stop(true)
end

function Vault_insertion_or_extraction()
  Extend_piston()
  Toggle_grabber()
  Retract_piston()
end

function Goto(X, Y)
  local delta_X = X - POS_X
  local delta_Y = Y - POS_Y
  local is_backward_x = false
  local is_backward_y = false 
  if delta_X < 0 then
    is_backward_x = true
  end
  if delta_Y < 0 then
    is_backward_y = true
  end
  Move_X(delta_X, is_backward_x)
  Move_Y(delta_Y, is_backward_y)
end

function Goto_Centre()
  -- Centre is (10,5) no matter the origin
  -- 4 blocks per grid
  Goto(10, 5)
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
    os.sleep(2.5)
  end
  local position_file = fs.open("gantry_state.dat", "r")
  if position_file == nil then
    if not grid then 
      Monitor.clear()
      Monitor.setCursorPos(1,1)
    else 
      Monitor.setCursorPos(1,4)
    end
    Monitor.Write("Position not found, defaulting to (1,1)")
    Save_gantry_state()
  end

  if not grid then
    Grid = textutils.unserialize(file.readAll())
  end
  if not pos then
    local position = textutils.unserialize(file.readAll())
    POS_X = position["X"]
    POS_Y = position["Y"]
  end
end

function Get_time_to_move(blocks)
  -- https://github.com/EvGamer/minecraft_cc_scripts/blob/master/create_gantry_test/move.lua
  local rpm = 256
  local tick_in_second = 20
  local speed_to_rpm = 512
  Chat_box.sendMessage(string.format("Time: %f", math.abs(blocks) * speed_to_rpm / (rpm * tick_in_second)))
  return (math.abs(blocks) * speed_to_rpm / (rpm * tick_in_second)) + 0.2
end

function Save_gantry_state()
  local file = fs.open("gantry_state.dat", "w")
  local pos = {}
  pos["X"] = POS_X
  pos["Y"] = POS_Y
  file.write(textutils.serialize(pos))
  file.close()
end

function Save_grid_state()
  local file = fs.open("storage_state.dat", "w")
  file.write(textutils.serialize(Grid))
  file.close()
end

function Start()
  Redstone_integrator.setOutput("up", false)
  Redstone_integrator.setOutput("down", false)
  Redstone_integrator.setOutput("north", false)
  Redstone_integrator.setOutput("south", false)
  Redstone_integrator.setOutput("east", false)
  Redstone_integrator.setOutput("west", false)
  Monitor.setCursorPos(1,1)
  Monitor.setTextColour(colours.white)
  Monitor.write("Initialising Storage...")
  Determine_state()
  Display_grid()
  Home_gantry()
  Vault_insertion_or_extraction()
  Goto_Centre()
  Vault_insertion_or_extraction()
  Home_gantry()
end

Start()
