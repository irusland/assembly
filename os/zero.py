# 180 kB = 360 sector

with open('zerofile', 'wb') as f:
    l = bytearray(184320 - 512)
    f.write(l)
