import os
from typing import List, Dict, Iterator

from PIL import Image
import numpy as np


def convert_images(directory) -> Dict[str, List[int]]:
    result_dict = {}
    for root, dirs, files in os.walk(directory):
        for file in sorted(files):
            path = os.path.join(root, file)
            result_dict.update({file: to_list(path)})

    return result_dict


def to_list(path) -> List[int]:
    return list(to_ints(path))


def to_ints(path) -> Iterator[int]:
    im = Image.open(path)
    p = np.array(im)
    for i in range(len(p[0])//8):
        start, stop = 8*i, 8*(i+1)
        part = p[:, start:stop]

        for j in range(len(part)):
            out = 0
            for bit in part[j]:
                out = (out << 1) | bit
            yield out


def save_as_font_asm(file: str, data: List[int], data_type: str = 'db', max_line: int = 200) -> None:
    with open(file, 'w') as out:
        lines = []
        part = max_line if max_line > 0 else len(data)
        for i in range(0, len(data), part):
            take = data[i:i + part]
            array = ', '.join(map(str, take))
            lines.append(f'{data_type} {array}')
        lines = "\n".join(lines)
        asm = f'{lines}'
        out.write(asm)
        print(len(data), ' > ', file, len(asm), '\n', asm)


if __name__ == '__main__':
    dict_ = convert_images('sprites')
    data = []
    for k, v in dict_.items():
        data.extend(v)
    save_as_font_asm('kalabok.sprites', data)
