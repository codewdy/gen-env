from sys import argv
import os
import os.path
from plugin import run_file
fn = argv[:-1]
if fn[-4:] != ".txt":
    fn = "lns.txt"

def p(x):
    print x
#os.system = lambda x: p(x)

rt = os.path.realpath(".")

run_file(fn)
