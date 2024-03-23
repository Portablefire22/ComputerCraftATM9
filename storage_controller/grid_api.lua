local M = {}
local display = require("monitor_controller")

local Monitor = peripheral.find("monitor")

local Redstone_integrator = peripheral.wrap("redstoneIntegrator_3")
local Redstone_integrator_2 = peripheral.wrap("redstoneIntegrator_4")
local Buffer_barrel = peripheral.wrap("minecraft:barrel_3") -- To move items to and from the vault
local Input_barrel = peripheral.wrap("bottom") -- Insert items into the vault

M.Grabbed_vault = nil
M.Grid = {}
M.Vault = nil
M.POS_X = 1
M.POS_Y = 1
M.WIDTH = 21
M.HEIGHT = 11
M.GRID_CENTRE_X = 11
M.GRID_CENTRE_Y = 6


function M.Toggle_grabber()
  Redstone_integrator.setOutput("east", true)
  os.sleep(0.2)
  Redstone_integrator.setOutput("east", false)
end

function M.Extend_piston()
  --Chat_box.sendMessage("Extending")
  M.Stop(true)
  os.sleep(0.2)
  M.Set_Reverse(true)
  M.Set_Vert_Movement(true)
  M.Set_Horz_Movement(true)
  M.Stop(false)
  for i=1,3 do 
    M.Increment_position()
    os.sleep(0.2)
  end
end

function M.Retract_piston()
  M.Stop(true)
  --Chat_box.sendMessage("Retracting")
  os.sleep(0.2)
  M.Set_Reverse(false)
  M.Set_Vert_Movement(true)
  M.Set_Horz_Movement(true)
  M.Stop(false)
  for i=1,3 do 
    M.Increment_position()
    os.sleep(0.2)
  end
end

function M.Set_Horz_Movement(state)
  Redstone_integrator.setOutput("south", state) -- Stops if true
end

function M.Set_Vert_Movement(state)
  Redstone_integrator.setOutput("north", state)
end

function M.Set_Reverse(state)
  Redstone_integrator.setOutput("west", state)
end

function M.Stop(state)
  Redstone_integrator.setOutput("up", state)
end

function M.Increment_position()
  Redstone_integrator_2.setOutput("up", true)
  os.sleep(0.2)
  Redstone_integrator_2.setOutput("up", false)
  os.sleep(0.6)
end

function M.Home_gantry()
  -- I ain't got anything to figure out if it is home
  -- So I'll just send it home and wait 10s between each input

  -- Home it horizontally
  M.Stop(true)
  M.Set_Vert_Movement(false)
  M.Set_Horz_Movement(true)
  M.Set_Reverse(true)
  os.sleep(0.2)
  M.Stop(false)
  --Chat_box.sendMessage("Homing Horizontally")
  for i=1,21 do 
    M.Increment_position()
  end

  -- Home it vertically
  M.Stop(true)
  M.Set_Vert_Movement(true)
  M.Set_Horz_Movement(false)
  os.sleep(0.2)
  M.Stop(false)
  --Chat_box.sendMessage("Homing Vertically")
  for i=1,11 do 
    M.Increment_position()
  end

  -- Reset
  os.sleep(0.2)
  M.Stop(true)
  M.Set_Horz_Movement(false)
  M.Set_Vert_Movement(false)
  M.Set_Reverse(false)
  --Chat_box.sendMessage("Finished Homing")
  POS_X = 1
  POS_Y = 1
end

function M.Move_X(blocks, is_backward)
  M.Stop(true)
  M.Set_Vert_Movement(false)
  M.Set_Horz_Movement(true)
  M.Set_Reverse(is_backward)
  os.sleep(0.2)
  M.Stop(false)
  for i=1,blocks do 
    M.Increment_position()
    if is_backward then 
      M.POS_X = M.POS_X - 1
    else
      M.POS_X = M.POS_X + 1
    end
    M.Save_gantry_state()
  end
  M.Stop(true)
  M.Set_Reverse(false)
end

function M.Move_Y(blocks, is_backward)
  M.Stop(true)
  M.Set_Vert_Movement(true)
  M.Set_Horz_Movement(false)
  M.Set_Reverse(is_backward)
  os.sleep(0.2)
  M.Stop(false)
  for i=1,blocks do 
    M.Increment_position()
    if is_backward then
      M.POS_Y = M.POS_Y - 1
    else
      M.POS_Y = M.POS_Y + 1
    end
    M.Save_gantry_state()
  end
  M.Stop(true)
  M.Set_Reverse(false)
end

function M.Vault_insertion_or_extraction()
  M.Extend_piston()
  M.Toggle_grabber()
  if M.Vault == nil then 
    M.Vault = {}
    M.Vault["X"] = M.POS_X
    M.Vault["Y"] = M.POS_Y
    M.Grid[M.POS_Y][M.POS_X] = {}
  else
    M.Grid[M.POS_Y][M.POS_X] = {0}
    M.Vault = nil
  end
  M.Save_grid_state()
  M.Retract_piston()
end

function M.Goto(X, Y)
  --Chat_box.sendMessage(string.format("Moving to (%d,%d)", X, Y))
  local delta_X = X - M.POS_X
  local delta_Y = Y - M.POS_Y
  local is_backward_x = false
  local is_backward_y = false 
  if delta_X < 0 then
    is_backward_x = true
  end
  if delta_Y < 0 then
    is_backward_y = true
  end
  M.Move_X(math.abs(delta_X), is_backward_x)
  M.Move_Y(math.abs(delta_Y), is_backward_y)
end

function M.Add_vault(x, y)
  if M.Does_vault_exist(x, y) then
    return false
  end
  if M.Grid[y] == nil then
    M.Grid[y] = {}
  end
  if M.Grid[y][x] == nil then
    M.Grid[y][x] = {}
  end
  M.Grid[y][x]["ITEMS"] = {1}
  M.Save_grid_state()
end

function M.Goto_Centre()
  -- Centre is (11,6) no matter the origin
  -- 4 blocks per grid
  M.Goto(11, 6)
end

function M.Setup_grid()
  for y=1,M.HEIGHT do
    M.Grid[y] = {}
    for x=1,M.WIDTH do
        M.Grid[y][x] = {}
    end
  end
end

function M.Does_vault_exist(X, Y)
  if M.Grid[Y] ~= nil then
    if M.Grid[Y][X] ~= nil then
      if next(M.Grid[Y][X]) ~= nil then
        return true
      end
    end
  end
  return false
end

function M.Load_vault(X, Y)
  M.Goto(X, Y)
  M.Vault_insertion_or_extraction()
  M.Goto_Centre()
  M.Vault_insertion_or_extraction()
end

function M.Move_vault(from_X, from_Y, to_X, to_Y)
  M.Goto(from_X, from_Y)
  M.Vault_insertion_or_extraction()
  M.Goto(to_X, to_Y)
  M.Vault_insertion_or_extraction()
end

function M.Unload_vault(X, Y)
  M.Goto_Centre()
  M.Vault_insertion_or_extraction()
  M.Goto(X, Y)
  M.Vault_insertion_or_extraction()
end

function M.Get_time_to_move(blocks)
  -- https://github.com/EvGamer/minecraft_cc_scripts/blob/master/create_gantry_test/move.lua
  local rpm = 256
  local tick_in_second = 20
  local speed_to_rpm = 512
  --Chat_box.sendMessage(string.format("Time: %f", math.abs(blocks) * speed_to_rpm / (rpm * tick_in_second)))
  return (math.abs(blocks) * speed_to_rpm / (rpm * tick_in_second)) + 0.2
end

function M.Attach_vault()
  M.Vault = peripheral.find("create:item_vault")
end

function M.Detach_vault()
  M.Vault = nil
end

function M.Save_gantry_state()
  local file = fs.open("gantry_state.dat", "w")
  local pos = {}
  pos["X"] = M.POS_X
  pos["Y"] = M.POS_Y
  file.write(textutils.serialize(pos))
  file.close()
end

function M.Save_grid_state()
  local file = fs.open("storage_state.dat", "w")
  file.write(textutils.serialize(M.Grid))
  file.close()
end

function M.Init_redstone()
  Redstone_integrator.setOutput("up", false)
  Redstone_integrator.setOutput("down", false)
  Redstone_integrator.setOutput("north", false)
  Redstone_integrator.setOutput("south", false)
  Redstone_integrator.setOutput("east", false)
  Redstone_integrator.setOutput("west", false)
end

function M.Reload_state()
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
    M.Setup_grid()
    M.Save_grid_state()
    grid = true
  else
    M.Grid = textutils.unserialize(file.readAll())
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
    M.Home_gantry()
    pos = true
    M.Save_gantry_state()
  else
    local position = textutils.unserialize(position_file.readAll())
    print(position)
    M.POS_X = position["X"]
    M.POS_Y = position["Y"]
  end
  if not grid or not pos then
    os.sleep(2.5) -- Allow the user to read it?
  end
end

function M.Init()
  M.Init_redstone()
  M.Reload_state()
end

return M
