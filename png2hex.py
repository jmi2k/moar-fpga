#!/bin/python3

from PIL import Image
import sys

image  = Image.open(sys.argv[1])
pixels = image.getdata()
bits   = [format(p, '01b') for p in pixels]

print('\n'.join(bits))
