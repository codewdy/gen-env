from pkgutil import walk_packages
from importlib import import_module
import os

def run_shell(s, *args):
    os.system(s.format(*args))

def ab_path(f):
    return os.path.realpath("dotfile") + "/" + f


plugins = {}


def sp_core(s):
    skip_flag = False
    cur = 0
    for i in range(len(s)):
        if skip_flag:
            skip_flag = False
            continue
        if s[i] == "\\":
            skip_flag = True
        elif s[i] == " ":
            yield s[cur:i]
            cur = i + 1
    yield s[cur:] 

def sp(s):
    for x in sp_core(s):
        if x != "":
            yield x

def run(s):
    if s == "":
        return
    elif s[0] == "#":
        return
    else:
        lst = list(sp(s))
        return plugins[lst[0]](*lst[1:])

class plugin(object):
    inst = ""

    def __init__(self, inst):
        self.inst = inst

    def __call__(self, func):
        if self.inst in plugins:
            raise Exception("Re Define Plugin {}!".format(self.inst))
        plugins[self.inst] = func
        return func

