local M = {}

local grid_api = require("grid_api")
local Monitor = peripheral.find("monitor")

M.isGrid = true

function M.Display_grid()
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

function M.Display_items()
  Monitor.setCursorPos(1,1)
  Monitor.setTextColour(colours.pink)
  Monitor.write("Displaying items not implemented!")
end

function M.Display()
  if M.isGrid then 
    M.Display_grid()
  else
    M.Display_items()
  end
end

function M.Init()
  Monitor.clear()
  Monitor.setCursorPos(1,1)
  Monitor.setTextColour(colours.white)
  Monitor.write("Initialising Storage...")
end


return M
