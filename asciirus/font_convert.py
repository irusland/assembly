
LABEL = 'font1'
TYPE = 'db'
IN_FONT = 'rus_font.fnt'
OUT_FONT = 'font1.asm'
MAX_LINE = 100
def main():
    with open(IN_FONT, 'rb') as font:
        with open(OUT_FONT, 'w') as out:
            r = font.read()
            lines = []
            for i in range(0, len(r), MAX_LINE):
                take = r[i:i + MAX_LINE]
                array = ', '.join(map(str, take))
                lines.append(f'{TYPE} {array}')
            lines = "\n".join(lines)
            asm = f'{LABEL}: {lines}'
            out.write(asm)
            print(IN_FONT, len(r), ' > ', OUT_FONT, len(asm), '\n', asm)


if __name__ == '__main__':
    main()
