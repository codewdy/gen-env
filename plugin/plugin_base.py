from pkgutil import walk_packages
from importlib import import_module
import os
from utils import shsplit, run_shell, color_print


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

def run(s):
    s = s.strip(" \t\n\r")
    if s == "":
        return
    elif s[0] == "#":
        color_print(s, 0, 31, 44)
        return
    elif s[:5] == "exec ":
        run_shell(s[5:])
    else:
        lst = list(shsplit(s))
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


def ConflictException(Exception):
    pass
