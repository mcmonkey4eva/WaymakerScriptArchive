memoryinfo_command:
    type: command
    debug: false
    name: memoryinfo
    usage: /memoryinfo
    description: Shows memory usage information.
    permission: dscript.memoryinfo
    script:
    - narrate "<&[base]>TPS 1m: <&[emphasis]><server.recent_tps.get[1].round_to[2]><&[base]>, 5m: <&[emphasis]><server.recent_tps.get[2].round_to[2]><&[base]>, 15m: <&[emphasis]><server.recent_tps.get[3].round_to[2]>"
    - narrate "<&[base]>Memory total: Max: <&[emphasis]><util.ram_max.div[1024].div[1024].round> MiB<&[base]>, allocated: <&[emphasis]><util.ram_allocated.div[1024].div[1024].round> MiB<&[base]>, used: <&[emphasis]><util.ram_usage.div[1024].div[1024].round> MiB<&[base]>, free: <&[emphasis]><util.ram_free.div[1024].div[1024].round> MiB"
