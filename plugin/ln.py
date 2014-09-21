from plugin import plugin, ConflictException
from utils import run_shell, gen_src
from os import path

@plugin("ln")
def ln(src, dst):
    src = gen_src(src)
    dstTrue = path.join(dst, path.basename(src))
    if path.exists(dstTrue):
        if path.samefile(src, dstTrue):
            return
        else:
            raise ConflictException(dstTrue)
    run_shell("mkdir -p {}", dst)
    run_shell("ln -s {} {}", src, dst)
