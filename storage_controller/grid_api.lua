local grid_module = {}

local Monitor = peripheral.find("monitor")

local Redstone_integrator = peripheral.wrap("redstoneIntegrator_3")
local Redstone_integrator_2 = peripheral.wrap("redstoneIntegrator_4")
local Buffer_barrel = peripheral.wrap("minecraft:barrel_3") -- To move items to and from the vault
local Input_barrel = peripheral.wrap("bottom") -- Insert items into the vault

local Grabbed_vault = nil
local Grid = {}
local Vault = nil
local POS_X = 1
local POS_Y = 1
local WIDTH = 21
local HEIGHT = 11


function grid_module.Toggle_grabber()
  Redstone_integrator.setOutput("east", true)
  os.sleep(0.2)
  Redstone_integrator.setOutput("east", false)
end

function grid_module.Extend_piston()
  --Chat_box.sendMessage("Extending")
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

function grid_module.Retract_piston()
  Stop(true)
  --Chat_box.sendMessage("Retracting")
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

function grid_module.Set_Horz_Movement(state)
  Redstone_integrator.setOutput("south", state) -- Stops if true
end

function grid_module.Set_Vert_Movement(state)
  Redstone_integrator.setOutput("north", state)
end

function grid_module.Set_Reverse(state)
  Redstone_integrator.setOutput("west", state)
end

function grid_module.Stop(state)
  Redstone_integrator.setOutput("up", state)
end

function grid_module.Increment_position()
  Redstone_integrator_2.setOutput("up", true)
  os.sleep(0.2)
  Redstone_integrator_2.setOutput("up", false)
  os.sleep(0.6)
end

function grid_module.Home_gantry()
  -- I ain't got anything to figure out if it is home
  -- So I'll just send it home and wait 10s between each input

  -- Home it horizontally
  Stop(true)
  Set_Vert_Movement(false)
  Set_Horz_Movement(true)
  Set_Reverse(true)
  os.sleep(0.2)
  Stop(false)
  --Chat_box.sendMessage("Homing Horizontally")
  for i=1,21 do 
    Increment_position()
  end

  -- Home it vertically
  Stop(true)
  Set_Vert_Movement(true)
  Set_Horz_Movement(false)
  os.sleep(0.2)
  Stop(false)
  --Chat_box.sendMessage("Homing Vertically")
  for i=1,11 do 
    Increment_position()
  end

  -- Reset
  os.sleep(0.2)
  Stop(true)
  Set_Horz_Movement(false)
  Set_Vert_Movement(false)
  Set_Reverse(false)
  --Chat_box.sendMessage("Finished Homing")
  POS_X = 1
  POS_Y = 1
end

function grid_module.Move_X(blocks, is_backward)
  Stop(true)
  Set_Vert_Movement(false)
  Set_Horz_Movement(true)
  Set_Reverse(is_backward)
  os.sleep(0.2)
  Stop(false)
  for i=1,blocks do 
    Increment_position()
    if is_backward then 
      POS_X = POS_X - 1
    else
      POS_X = POS_X + 1
    end
    Save_gantry_state()
  end
  Stop(true)
  Set_Reverse(false)
end

function grid_module.Move_Y(blocks, is_backward)
  Stop(true)
  Set_Vert_Movement(true)
  Set_Horz_Movement(false)
  Set_Reverse(is_backward)
  os.sleep(0.2)
  Stop(false)
  for i=1,blocks do 
    Increment_position()
    if is_backward then
      POS_Y = POS_Y - 1
    else
      POS_Y = POS_Y + 1
    end
    Save_gantry_state()
  end
  Stop(true)
  Set_Reverse(false)
end

function grid_module.Vault_insertion_or_extraction()
  Extend_piston()
  Toggle_grabber()
  if Vault == nil then 
    Vault = {}
    Vault["X"] = POS_X
    Vault["Y"] = POS_Y
    Grid[POS_Y][POS_X] = {}
  else
    Grid[POS_Y][POS_X] = {0}
    Vault = nil
  end
  Retract_piston()
end

function grid_module.Goto(X, Y)
  --Chat_box.sendMessage(string.format("Moving to (%d,%d)", X, Y))
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
  grid_module.Move_X(math.abs(delta_X), is_backward_x)
  grid_module.Move_Y(math.abs(delta_Y), is_backward_y)
end

function grid_module.Goto_Centre()
  -- Centre is (11,6) no matter the origin
  -- 4 blocks per grid
  grid_module.Goto(11, 6)
end

function grid_module.Setup_grid()
  for y=1,HEIGHT do
    Grid[y] = {}
    for x=1,WIDTH do
        Grid[y][x] = {}
    end
  end
end

function grid_module.Load_vault(X, Y)
  grid_module.Goto(X, Y)
  grid_module.Vault_insertion_or_extraction()
  grid_module.Goto_Centre()
  grid_module.Vault_insertion_or_extraction()
end

function grid_module.Move_vault(from_X, from_Y, to_X, to_Y)
  grid_module.Goto(from_X, from_Y)
  grid_module.Vault_insertion_or_extraction()
  grid_module.Goto(to_X, to_Y)
  grid_module.Vault_insertion_or_extraction()
end

function grid_module.Unload_vault(X, Y)
  grid_module.Goto_Centre()
  grid_module.Vault_insertion_or_extraction()
  grid_module.Goto(X, Y)
  grid_module.Vault_insertion_or_extraction()
end

function grid_module.Get_time_to_move(blocks)
  -- https://github.com/EvGamer/minecraft_cc_scripts/blob/master/create_gantry_test/move.lua
  local rpm = 256
  local tick_in_second = 20
  local speed_to_rpm = 512
  --Chat_box.sendMessage(string.format("Time: %f", math.abs(blocks) * speed_to_rpm / (rpm * tick_in_second)))
  return (math.abs(blocks) * speed_to_rpm / (rpm * tick_in_second)) + 0.2
end

function grid_module.Attach_vault()
  Vault = peripheral.find("create:item_vault")
end

function grid_module.Detach_vault()
  Vault = nil
end

function grid_module.Save_gantry_state()
  local file = fs.open("gantry_state.dat", "w")
  local pos = {}
  pos["X"] = POS_X
  pos["Y"] = POS_Y
  file.write(textutils.serialize(pos))
  file.close()
end

function grid_module.Save_grid_state()
  local file = fs.open("storage_state.dat", "w")
  file.write(textutils.serialize(Grid))
  file.close()
end

function grid_module.Init_redstone()
  Redstone_integrator.setOutput("up", false)
  Redstone_integrator.setOutput("down", false)
  Redstone_integrator.setOutput("north", false)
  Redstone_integrator.setOutput("south", false)
  Redstone_integrator.setOutput("east", false)
  Redstone_integrator.setOutput("west", false)
end

function grid_module.Reload_state()

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
    Monitor.setCursorPos(1,3)
    Monitor.write("Blank grid created!")
    grid_module.Setup_grid()
    grid_module.Save_grid_state()
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
    grid_module.Home_gantry()
    pos = true
    grid_module.Save_gantry_state()
  end

  if not grid then
    grid_module.Grid = textutils.unserialize(file.readAll())
  end
  if not pos then
    local position = textutils.unserialize(position_file.readAll())
    print(position)
    grid_module.POS_X = position["X"]
    grid_module.POS_Y = position["Y"]
  end
  if not grid or not pos then 
    os.sleep(2.5) -- Allow the user to read it?
  end
end

function grid_module.Init()
  grid_module.Init_redstone()
  grid_module.Reload_state()
end

return grid_module
