from pkgutil import walk_packages
from importlib import import_module
import os
from plugin_base import run


def init():
        init = lambda:None
        for loader, module_name, is_pkg in walk_packages(
                            [os.path.dirname(__file__)], __name__ + '.'):
                    import_module(module_name)

init()
