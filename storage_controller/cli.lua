local M = {}

M.input_buffer = ""
M.frame_buffer = {}
M.shift = false
M.caps = false

function M.process_key_toggles(raw_key)
  local key = keys.getName(raw_key)
  if key == "rightShift" or "leftShift" then
    M.shift = false
  end
end

function M.process_input(raw_key)
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
  elseif key == "rightShift" or key == "leftShift" then 
    M.shift = true
    key = ""
  elseif key == "capsLock" then
    M.caps = not M.caps
    key = ""
  elseif key == "enter" then
    key = "\n"
  end
  if key == "backspace" then
    M.input_buffer = M.input_buffer:sub(1, -2)
  else
    if M.caps or M.shift then 
      key = key:upper()
    end
    M.input_buffer = M.input_buffer .. key
  end
  local temp = "The Grid> " .. M.input_buffer
  local i = 0
  local frame_temp = temp
  local w,h = term.getSize()
  local x = w
  if #M.frame_buffer == 0 then 
    M.frame_buffer[1] = temp
  end
  while string.len(frame_temp) > 0 do
    x = temp.find(frame_temp, "\n")
    if x ~= nil then
      M.Execute()
    end
    
    if string.len(frame_temp) >= w then
      M.frame_buffer[#M.frame_buffer+1] = frame_temp:sub(1, w)
      frame_temp = string.sub(frame_temp, w, string.len(frame_temp))
    else
      M.frame_buffer[#M.frame_buffer] = frame_temp
      frame_temp = ""
    end
  end
end

function M.Execute()
  M.frame_buffer[#M.frame_buffer+1] = M.input_buffer
end

function M.display_buffer()
  term.clear()
  local w, h = term.getSize()
  local lines = #M.frame_buffer
  local start = #M.frame_buffer - h
  if start < 1 then 
    start = 1
  end
  local line_pos = 1
  for line = start, #M.frame_buffer do
    term.setCursorPos(1,line_pos)
    line_pos = line_pos + 1
    local temp = M.frame_buffer[line]
    if temp == nil then 
      goto continue
    end
    print(temp)
    while string.len(temp) > 0 do
      temp = M.tryWrite(temp, "^[>]", colours.orange) or M.tryWrite(temp, "^[^>]", colours.white)
    end
      ::continue::
  end
end

function M.tryWrite( sLine, regex, colour )
  if #M.frame_buffer == 0 then
    return
  end
  local match = string.match( sLine, regex )
  if match then
    if type(colour) == "number" then
      term.setTextColour( colour )
    else
      term.setTextColour( colour(match) )
    end
    term.write(match)
    term.setTextColour(colours.white)
    return string.sub( sLine, string.len(match) + 1 )
  end
  return nil
end

return M
