Redstone_integrator = peripheral.wrap("redstoneIntegrator_3")
Redstone_integrator_2 = peripheral.wrap("redstoneIntegrator_4")
Buffer_barrel = peripheral.wrap("minecraft:barrel_3") -- To move items to and from the vault
Input_barrel = peripheral.wrap("bottom") -- Insert items into the vault

Grabbed_vault = nil
Grid = {}
Vault = nil
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

function Retract_piston()
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

function Move_X(blocks, is_backward)
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

function Move_Y(blocks, is_backward)
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

function Vault_insertion_or_extraction()
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

function Goto(X, Y)
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
  Move_X(math.abs(delta_X), is_backward_x)
  Move_Y(math.abs(delta_Y), is_backward_y)
end

function Goto_Centre()
  -- Centre is (11,6) no matter the origin
  -- 4 blocks per grid
  Goto(11, 6)
end

function Setup_grid()
  for y=1,HEIGHT do
    Grid[y] = {}
    for x=1,WIDTH do
        Grid[y][x] = {}
    end
  end
end

function Load_vault(X, Y)
  Goto(X, Y)
  Vault_insertion_or_extraction()
  Goto_Centre()
  Vault_insertion_or_extraction()
end

function Move_vault(from_X, from_Y, to_X, to_Y)
  Goto(from_X, from_Y)
  Vault_insertion_or_extraction()
  Goto(to_X, to_Y)
  Vault_insertion_or_extraction()
end

function Unload_vault(X, Y)
  Goto_Centre()
  Vault_insertion_or_extraction()
  Goto(X, Y)
  Vault_insertion_or_extraction()
end

function Get_time_to_move(blocks)
  -- https://github.com/EvGamer/minecraft_cc_scripts/blob/master/create_gantry_test/move.lua
  local rpm = 256
  local tick_in_second = 20
  local speed_to_rpm = 512
  --Chat_box.sendMessage(string.format("Time: %f", math.abs(blocks) * speed_to_rpm / (rpm * tick_in_second)))
  return (math.abs(blocks) * speed_to_rpm / (rpm * tick_in_second)) + 0.2
end

function Attach_vault()
  Vault = peripheral.find("create:item_vault")
end

function Detach_vault()
  Vault = nil
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
