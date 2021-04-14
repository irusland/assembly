import os

TYPE = 'db'
MAX_LINE = 200


def convert(in_font, out_font):
    with open(in_font, 'rb') as font:
        with open(out_font, 'w') as out:
            r = font.read()
            lines = []
            part = MAX_LINE if MAX_LINE > 0 else len(r)
            for i in range(0, len(r), part):
                take = r[i:i + part]
                array = ', '.join(map(str, take))
                lines.append(f'{TYPE} {array}')
            lines = "\n".join(lines)
            asm = f'{lines}'
            out.write(asm)
            print(in_font, len(r), ' > ', out_font, len(asm), '\n', asm)


def convert_many(listing):
    with open('labels.asm', 'w') as labels:
        with open(listing, 'r') as f:
            content = f.readlines()
            fonts = [x.strip() for x in content]
        for i, file in enumerate(fonts):
            out_name = os.path.join('fonts', f'font{i}.asm')
            convert(file, out_name)
            labels.write(f'font{i}:\ninclude {out_name}\n')


if __name__ == '__main__':
    convert_many('8x16_fonts_list')
