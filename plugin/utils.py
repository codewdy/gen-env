from pkgutil import walk_packages
from importlib import import_module
import os
import shlex

def arg_encode(s):
    s = s.replace('\\', r'\\')
    s = s.replace(r'"', r'\"')
    s = '"{}"'.format(s)
    return s

_trans_dir = {
        "~" : os.popen("echo ~").read().strip("\n\r ")
}

def arg_decode(s):
    l = s.split("/")
    if l[0] in _trans_dir:
        l[0] = _trans_dir[l[0]]
    return "/".join(l)

def cmd(s, *args):
    args = [arg_encode(i) for i in args]
    return s.format(*args)

def run_shell(s, *args):
    return os.system(cmd(s, *args))

def run_shell_text(s, *args):
    return os.popen(cmd(s, *args)).read()

def ab_path(s):
    return os.path.realpath("dotfile") + "/" + s

def shsplit(s):
    ret = shlex.split(s)
    ret = [arg_decode(i) for i in ret]
    return ret

def gen_src(s):
    if s[0] != "/":
        s = ab_path(s)
    return s
