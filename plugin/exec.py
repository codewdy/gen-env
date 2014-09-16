from plugin_base import plugin, run_shell, ab_path

@plugin("exec")
def execX(*args):
    run_shell(" ".join(args))
