local M = {}
local pretty = require "cc.pretty"
local Monitor = peripheral.find("monitor")
local Redstone_integrator = peripheral.wrap("redstoneIntegrator_3")
local Redstone_integrator_2 = peripheral.wrap("redstoneIntegrator_4")
local Buffer_barrel = peripheral.wrap("minecraft:barrel_3") -- To move items to and from the vault
local Input_barrel = peripheral.wrap("bottom") -- Insert items into the vault

M.Grid = {}
M.Vault = nil
M.POS_X = 1
M.POS_Y = 1
M.WIDTH = 21
M.HEIGHT = 11
M.GRID_CENTRE_X = 11
M.GRID_CENTRE_Y = 6

M.Item_map = {}

function M.Get_item(slots_to_get)
  M.UUID_to_pos(312)
end

function M.UUID_to_pos(uuid)
  Monitor.clear()
  for y = 1, M.HEIGHT, 1 do
    for x = 1, M.WIDTH, 1 do
      Monitor.setCursorPos(1, y)
      Monitor.write(pretty.render(pretty.pretty(M.Grid[y][x])))
    end
  end
  os.sleep(50)
end

function M.Locate_item(item, count)
  local slots_to_get = {}
  local count_prog = count
  Monitor.clear()
  Monitor.setCursorPos(1,1)
  if M.Item_map[item] == nil then
    return false
  end
  for i, v in pairs(M.Item_map[item]) do
    local tmp = {}
    for j, slots in pairs (v) do
      for slot, slot_count in pairs(slots) do
        Monitor.setCursorPos(1, slot)
        Monitor.write(("%s | %s | %s"):format(slot, slot_count, count_prog))
        if count_prog == 0 then
          break
        end
        if slot_count == count_prog then
          table.insert(tmp, slot, slot_count)
          count_prog = 0
        elseif slot_count > count_prog then
          table.insert(tmp, slot, count_prog)
          count_prog = 0
        elseif slot_count < count_prog then
          table.insert(tmp, slot, slot_count)
          count_prog = count_prog - slot_count
        end
      end
      slots_to_get[i] = tmp
      if count_prog == 0 then
        goto got_item
      end
    end
  end
  ::got_item::
  Monitor.clear()
  Monitor.setCursorPos(1,1)
  Monitor.write(("%s"):format(pretty.render(pretty.pretty(slots_to_get))))
  M.Get_item(slots_to_get)
  return true
end

function M.Add_loaded_vault_to_item_map()
  -- Takes all items from the currently loaded vault and adds the vault to the correct branches
  -- of the item map
  local vault_items = {}
  for slot, item in pairs(M.Vault_per.list()) do
    if item == nil or slot == nil then
      goto continue
    end
    if vault_items[item.name] == nil then
      vault_items[item.name] = {}
    end
    local tmp = {}
    tmp[slot] = item.count
    table.insert(vault_items[item.name], tmp)
    ::continue::
  end

  for item_name, slot_info in pairs(vault_items) do
  if item_name:find(":") ~= nil then
    item_name = item_name:sub(item_name:find(":") + 1)
  end
    if M.Item_map[item_name] == nil then
      M.Item_map[item_name] = {}
    end
    M.Item_map[item_name][M.Grid[M.GRID_CENTRE_Y][M.GRID_CENTRE_X]["ID"]] = slot_info
    table.sort(M.Item_map[item_name], function(a, b) return a[M.Grid[M.GRID_CENTRE_Y][M.GRID_CENTRE_X]["ID"]] < b[M.Grid[M.GRID_CENTRE_Y][M.GRID_CENTRE_X]["ID"]] end)
  end
  M.Save_item_state()
end

local random = math.random
math.randomseed(os.time())
function M.uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end


function M.Read_vault_contents()
  M.Attach_vault()
  M.Grid[M.GRID_CENTRE_Y][M.GRID_CENTRE_X]["ITEMS"] = M.Vault_per.list()
  M.Add_loaded_vault_to_item_map()
  M.Detach_vault()
  M.Save_grid_state()
end

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
    M.Vault["ITEMS"] = M.Grid[M.POS_Y][M.POS_X]["ITEMS"]
    M.Vault["ID"] = M.Grid[M.POS_Y][M.POS_X]["ID"]
    M.Grid[M.POS_Y][M.POS_X] = {}
  else
    M.Grid[M.POS_Y][M.POS_X]["ITEMS"] = M.Vault["ITEMS"]
    M.Grid[M.POS_Y][M.POS_X]["ID"] = M.Vault["ID"]
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
  M.Grid[y][x]["ID"] = M.uuid()
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
  M.Read_vault_contents()
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
  M.Vault_per = peripheral.find("create:item_vault")
end

function M.Detach_vault()
  M.Vault_per = nil
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

function M.Save_item_state()
  local file = fs.open("item_state.dat", "w")
  file.write(textutils.serialize(M.Item_map))
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
  local itm = false
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
    if not grid then
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

  local item_file = fs.open("item_state.dat", "r")
  if item_file == nil then
    Monitor.setCursorPos(1,5)
    Monitor.write("Item state not found, defaulting to new")
    M.Item_map = {}
    M.Save_item_state()
    itm = true
  else
    M.Item_map = textutils.unserialize(item_file.readAll())
  end

  if not grid or not pos or not itm then
    os.sleep(2.5) -- Allow the user to read it?
  end
end

function M.Init()
  M.Init_redstone()
  M.Reload_state()
end

return M
