local grid_api = require("grid_api")
local cli = require("cli")
local monitor_api = require("monitor_controller")

Chat_box = peripheral.find("chatBox")
Inventory_manager = peripheral.find("inventoryManager")
Buffer_chest = peripheral.find("sophisticatedstorage:chest") -- Holds items for crafting
Item_map = {}


function Save_items()
  local file = fs.open("stored_items.map", "w")
  file.write(textutils.serialize(Item_map))
  file.close()
end

function Cmd()
  local input = read()
end

function Runtime()
  while true do
    cli.display_buffer()
    local event, param1, param2, param3 = os.pullEvent()
    if event == "key" then
      cli.process_input(param1)
    elseif event == "key_up" then
      cli.process_key_toggles(param1)
    end
    monitor_api.Display_grid()
  end
end

function Start()
  grid_api.Init()
  monitor_api.Init()
  monitor_api.Display_grid()
  Runtime()
  --Load_vault(1,1)
  --os.sleep(2)
  --Unload_vault(15, 3)
  --Move_vault(15, 3, 1, 1)
end

Start()
