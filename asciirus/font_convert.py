IN_FONT = 'CP866/Bolkhovityanov/bolkhov-CP866-one-8x16.fnt'

TYPE = 'db'
OUT_FONT = 'font1.asm'
MAX_LINE = 200


def main():
    with open(IN_FONT, 'rb') as font:
        with open(OUT_FONT, 'w') as out:
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
            print(IN_FONT, len(r), ' > ', OUT_FONT, len(asm), '\n', asm)


if __name__ == '__main__':
    main()
