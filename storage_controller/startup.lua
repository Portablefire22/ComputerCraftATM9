Chat_box = peripheral.find("chatBox")
Inventory_manager = peripheral.find("inventoryManager")
Buffer_chest = peripheral.find("sophisticatedstorage:chest") -- Holds items for crafting
Buffer_barrel = peripheral.find("minecraft:barrel") -- To move items to and from the vault
Redstone_integrator = peripheral.find("redstoneIntegrator")
Monitor = peripheral.find("monitor")
Grid = {}
POS_X = 0
POS_Y = 0
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
  os.sleep(3)
end

function Retract_piston()
  Stop(true)
  Chat_box.sendMessage("Retracting")
  os.sleep(0.2)
  Set_Reverse(false)
  Set_Vert_Movement(true)
  Set_Horz_Movement(true)
  Stop(false)
  os.sleep(3)
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
  os.sleep(10)

  -- Home it vertically
  Stop(true)
  Set_Vert_Movement(true)
  Set_Horz_Movement(false)
  os.sleep(0.2)
  Stop(false)
  Chat_box.sendMessage("Homing Vertically")
  os.sleep(10)

  -- Reset
  os.sleep(0.2)
  Stop(true)
  Set_Horz_Movement(false)
  Set_Vert_Movement(false)
  Set_Reverse(false)
  Chat_box.sendMessage("Finished Homing")
  POS_X = 0
  POS_Y = 0
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
  os.sleep(Get_time_to_move(blocks))
  Stop(true)
end

function Move_Y(blocks, is_backward)
  Stop(true)
  Set_Vert_Movement(true)
  Set_Horz_Movement(false)
  Set_Reverse(is_backward)
  os.sleep(0.2)
  Stop(false)
  os.sleep(Get_time_to_move(blocks))
  Stop(true)
end

function Goto_Centre()
  -- Centre is (10,5) no matter the origin
  -- 4 blocks per grid
  local delta_X = 10 - POS_X
  local delta_Y = 5 - POS_Y
  local is_backward_x = false
  local is_backward_y = false 
  if delta_X < 0 then
    is_backward_x = true
  end
  if delta_Y < 0 then
    is_backward_y = true
  end
  Move_X(delta_X * 4, is_backward_x)
  Move_Y(delta_Y * 4, is_backward_y)
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
  Chat_box.sendMessage("Extending")

function Get_time_to_move(blocks)
  -- https://github.com/EvGamer/minecraft_cc_scripts/blob/master/create_gantry_test/move.lua
  local rpm = 256
  local tick_in_second = 20
  local speed_to_rpm = 512
  Chat_box.sendMessage(string.format("Time: %f", math.abs(blocks) * speed_to_rpm / (rpm * tick_in_second)))
  return (math.abs(blocks) * speed_to_rpm / (rpm * tick_in_second)) * 1.1
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
  Extend_piston()
  Toggle_grabber()
  Retract_piston()
  Goto_Centre()
  Extend_piston()
  Toggle_grabber()
  Retract_piston()
  Home_gantry()
end

Start()
