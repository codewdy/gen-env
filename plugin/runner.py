from plugin import run

def run_file(s):
    f = open(s)
    for inst in f:
        run(inst)
