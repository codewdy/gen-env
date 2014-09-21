from plugin import plugin_raw, run
from utils import run_shell, sudoC
import utils
from os import path

print sudoC.depth

@plugin_raw("sudo")
def sudo(inst):
    global sudoC
    sudoC.depth += 1
    run(inst)
    sudoC.depth -= 1
