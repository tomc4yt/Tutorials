'''
Created on Feb 10, 2015

@author: Tom
'''
from PIL import Image
from PIL import ImageChops

import numpy as np
import os
import re  

    
def trim(_directory, legend = True):
    os.chdir(_directory)
    for subdir, dirs, files in os.walk(_directory):
        for fn in files:
            fn = os.path.join(subdir, fn)
            if os.path.splitext(fn)[1] == '.png':
                im = Image.open(fn)
                bg = Image.new(im.mode, im.size, im.getpixel((0,0)))
                diff = ImageChops.difference(im, bg)
                diff = ImageChops.add(diff, diff, 2.0, -100)
                bbox = diff.getbbox()
                im = im.crop(bbox)
                data = np.asarray(im)
                                   
                if legend == True and (np.sum(data[::, data.shape[1] - 1,0]) > 255*1*data.shape[0]*.1 and \
                np.sum(data[::, data.shape[1] - 1,0]) < 255*1*data.shape[0]*.75) or \
                np.sum(data[::, data.shape[1] - 1,0]) == 0 or \
                re.search("TAT", os.path.splitext(fn)[0]):

                    i = data.shape[1] - 1
                    while np.sum(data[::,i,::]) <> 255*data.shape[2]*data.shape[0]:
                        i = i - 1
                    while np.sum(data[::,i,::]) == 255*data.shape[2]*data.shape[0]:
                        i = i - 1
                    w, h = im.size
                    im = im.crop((0,0,i,h))

                im.save(os.path.splitext(fn)[0]  + "_cut" + os.path.splitext(fn)[1])
                

def main():
    directory = input("Select a directory: ")
    trim(directory)

if __name__ == '__main__':
    main()