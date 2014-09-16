from plugin_base import plugin, run_shell, ab_path

@plugin("git")
def git(src, dst):
    run_shell("mkdir -p {}", dst)
    run_shell("git clone {} {}", src, dst)
