local M = {}

M.input_buffer = ""

function M.process_input(raw_key)
  term.clear()
  term.setCursorPos(1,1)
  local key = keys.getName(raw_key)
  if key == "space" then
    key = " "
  else if key == "slash" then
    key = "/"
  end
  M.input_buffer = M.input_buffer .. key
  print(M.input_buffer)
end

return M
