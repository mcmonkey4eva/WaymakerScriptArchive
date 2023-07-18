autosaver_world:
    type: world
    debug: false
    events:
        on delta time minutely every:30:
        - announce to_console Autosaving...
        - adjust server save
        - announce to_console "Autosave took <queue.time_ran.in_milliseconds.round>ms"
