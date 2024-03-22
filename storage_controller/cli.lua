local M = {}

M.input_buffer = ""

function M.process_input(key)
  M.input_buffer = M.input_buffer + key
  print(M.input_buffer)
end

return M
