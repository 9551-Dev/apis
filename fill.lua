local function fill(wrapper, pos1, pos2, length, height)
  for x = 0, height - 1 do
    wrapper.setCursorPos(pos1, pos2 + x)
    wrapper.write(string.rep(" ", length))
  end
end
return {fill = fill}
