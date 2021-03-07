import os

paths = [
    'LOADER.COM',
    'PROGRAM.COM'
]

img = 'dmg.img'

tracks = 40
sectors = 9
capacity = 512
tracks_per_file = 2

with open(img, 'wb') as f:
    f.write(bytearray(tracks * sectors * capacity))
    f.seek(0)
    for i, path in enumerate(paths):
        with open(path, 'rb') as file:
            binary = file.read()
            start = sectors * capacity * tracks_per_file * i
            f.seek(start)
            f.write(binary)
            print(f'{path} -> {img}[{i}] ({start}:{len(binary)})')
    print(f'{img} image created, size {os.stat(img).st_size}B')
