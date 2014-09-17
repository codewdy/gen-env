from sys import argv
import os
import os.path
from plugin import run
fn = argv[:-1]
if fn[-4:] != ".txt":
    fn = "lns.txt"

def p(x):
    print x
#os.system = lambda x: p(x)

rt = os.path.realpath(".")

f = open(fn)
for line in f:
    line = line.strip("\n\r")
    run(line)
