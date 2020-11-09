#!/bin/python3

import PIL.Image as Image
import sys

image  = Image.open(sys.argv[1])
pixels = bytes(image.getdata())
sys.stdout.buffer.write(pixels)
