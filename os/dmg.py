with open('d1.img', 'wb') as f:
    with open('MBR1.COM', 'rb') as com:
        c = com.read()
        f.write(c)
        f.write(bytearray(184320 - 512))