from plugin import plugin
import os
from utils import color_print, gen_src

@plugin("cd")
def cd(src):
    src = gen_src(src)
    color_print("chdir to {}".format(src), 0, 34, 47)
    os.chdir(src)
