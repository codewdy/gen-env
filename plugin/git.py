from plugin import plugin
from utils import run_shell, run_shell_text,ab_path
from os import path

@plugin("git")
def git(src, dst):
    if path.exists(dst):
        if path.isdir(dst):
            x =run_shell_text("cd {}; git remote show origin -n", dst)
            if x.find(src):
                run_shell("cd {}; git pull", dst)
                return
        raise ConflictException(dstTrue)
    run_shell("mkdir -p {}", dst)
    run_shell("git clone {} {}", src, dst)
