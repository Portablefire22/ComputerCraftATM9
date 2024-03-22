local M = {}

M.input_buffer = ""
M.shift = false
M.caps = false

function M.process_key_toggles(raw_key)
  local key = keys.getName(raw_key)
  if key == "rightShift" or "leftShift" then
    M.shift = false
  end
end

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
  print(tryWrite(M.input_buffer, " > ", colour.orange))
end

local function tryWrite( sLine, regex, colour )
  local match = string.match( sLine, regex )
  if match then
        if type(colour) == "number" then
          term.setTextColour( colour )
        else
          term.setTextColour( colour(match) )
        end
        term.write( match )
        term.setTextColour( textColour )
        return string.sub( sLine, string.len(match) + 1 )
  end
  return nil
end

return M
