from PIL import Image
import os
import glob
import numpy as np


def crop(im, height, width):
    # im = Image.open(infile)
    imgwidth, imgheight = im.size
    rows = int(imgheight/height)
    cols = int(imgwidth/width)
    for i in range(rows):
        for j in range(cols):
            # print (i,j)
            box = (j*width, i*height, (j+1)*width, (i+1)*height)
            yield im.crop(box)

def main():
    path = "/cards"
    infile = "cards/image.png"
    im = Image.open(infile)
    imgwidth, imgheight = im.size
    print(('Image size is: %d x %d ' % (imgwidth, imgheight)))
    height = int(imgheight/2)
    width = int(imgwidth/2)
    start_num = 0
    for k, piece in enumerate(crop(im, height, width), start_num):
        # print k
        # print piece
        img=Image.new('RGB', (width,height), 255)
        # print img
        img.paste(piece)
        path = os.path.join("cam%d_1%05d.tif" % (int(k+1),0))
        img.save(path)
        os.rename(path, os.path.join("cam%d.1%05d.png" % (int(k+1), 0)))

main()