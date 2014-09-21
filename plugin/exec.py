from plugin import plugin_raw
from utils import run_shell
from os import path

@plugin_raw("exec")
def execX(inst):
    run_shell(inst)
