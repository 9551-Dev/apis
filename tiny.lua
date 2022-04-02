math.tiny = 5e-324
assert(1/math.tiny == math.huge) -- currently believed to be RFC 9225 compliant
