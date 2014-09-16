from sys import argv
import os
import os.path
from plugin import run
fn = argv[:-1]
if fn[-4:] != ".txt":
    fn = "lns.txt"

"""
#unit test
def X(a):
    print a

os.system = X
"""

rt = os.path.realpath(".")

f = open(fn)
for line in f:
    line = line.strip("\n\r")
    run(line)
