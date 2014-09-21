#coding=utf-8
from pkgutil import walk_packages
from importlib import import_module
import os
import shlex

def color_print(msg, attr = 0, fore = 37, back = 40):
    
    u"""
    0  All attributes off 默认值
    1  Bold (or Bright) 粗体 or 高亮
    4  Underline 下划线
    5  Blink 闪烁
    7  Invert 反显
    30 Black text
    31 Red text
    32 Green text
    33 Yellow text
    34 Blue text
    35 Purple text
    36 Cyan text
    37 White text
    40 Black background
    41 Red background
    42 Green background
    43 Yellow background
    44 Blue background
    45 Purple background
    46 Cyan background
    47 White background
    """
    color = "\x1B[%d;%d;%dm" % (attr,fore,back)
    print "%s%s\x1B[0m" % (color, msg)

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

class tsudoC:
    pass
sudoC = tsudoC()
sudoC.depth = 0

def cmd(s, *args):
    args = [arg_encode(i) for i in args]
    ret = s.format(*args)
    if sudoC.depth > 0:
        ret = r'sudo su -c {}'.format(arg_encode(ret))
    return ret

def run_shell(s, *args):
    c = cmd(s, *args)
    color_print(c, 0, 34, 47)
    return os.system(c)

def run_shell_text(s, *args):
    return os.popen(cmd(s, *args)).read()

def ab_path(s):
    return os.path.realpath(".") + "/" + s

def shsplit(s):
    ret = shlex.split(s)
    ret = [arg_decode(i) for i in ret]
    return ret

def gen_src(s):
    if s[0] != "/":
        s = ab_path(s)
    return s
