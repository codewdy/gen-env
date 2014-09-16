from plugin_base import plugin, run_shell, ab_path

@plugin("ln")
def ln(src, dst):
    run_shell("mkdir -p {}", dst)
    run_shell("ln -s {} {}", ab_path(src), dst)
