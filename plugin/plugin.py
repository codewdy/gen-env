from utils import shsplit, color_print
from utils import run_shell
from functools import wraps
import shlex

plugins = {}

class plugin_raw(object):
    inst = ""

    def __init__(self, inst):
        self.inst = inst

    def __call__(self, func):
        if self.inst in plugins:
            raise Exception("Re Define Plugin {}!".format(self.inst))
        plugins[self.inst] = func
        return func


class plugin(object):
    inst = ""

    def __init__(self, inst):
        self.inst = inst

    def __call__(self, func):
        if self.inst in plugins:
            raise Exception("Re Define Plugin {}!".format(self.inst))
        @wraps(func)
        def wrapper(s):
            return func(*shsplit(s))
        plugins[self.inst] = wrapper
        return func

def run(s):
    s = s.strip(" \t\n\r")
    if s == "":
        return
    elif s[0] == "#":
        color_print(s, 0, 31, 44)
        return
    else:
        dec = shlex.shlex(s)
        op = dec.get_token()
        return plugins[op](dec.instream.read())

def ConflictException(Exception):
    pass
