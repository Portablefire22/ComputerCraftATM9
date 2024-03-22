local M = {}

M.input_buffer = ""

function M.process_input(raw_key)
  term.clear()
  term.setCursorPos(1,1)
  local key = keys.getName(raw_key)
  if key == "space" then
    key = " "
  elseif key == "slash" then
    key = "/"
  elseif key == "zero" then
    key = "0"
  elseif key == "one" then
    key = "1"
  elseif key == "two" then
    key = "2"
  elseif key == "three" then
    key = "3"
  elseif key == "four" then
    key = "4"
  elseif key == "five" then
    key = "5"
  elseif key == "six" then
    key = "6"
  elseif key == "seven" then
    key = "7"
  elseif key == "eight" then
    key = "8"
  elseif key == "nine" then
    key = "9"
  end
  if key == "backspace" then
    M.input_buffer = M.input_buffer:sub(1, -2)
  else
    M.input_buffer = M.input_buffer .. key
  end
  print(M.input_buffer)
end

return M
