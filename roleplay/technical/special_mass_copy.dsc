

special_mass_copy_danary_impl:
    type: task
    debug: false
    definitions: part
    script:
    # FULL: #- run special_mass_copy_task def.from_min:<location[-928,0,-608,danary_test]> def.from_max:<location[2528,500,1258,danary_test]> def.to_min:<location[0,0,7248,superflat]>
    - define low <location[-928,0,-608,danary_test]>
    - define high <location[2528,500,1258,danary_test]>
    - define to <location[0,0,7248,superflat]>
    # Rendered 1: 224,-304   to   864,64
    # and 2, ...
    - define key_x_min <element[224].sub[-928]>
    - define key_x_max <element[864].sub[-928]>
    - define key_z_min <element[-304].sub[-608]>
    - define key_z_max <element[64].sub[-608]>
    - define key2_x_max <element[1200].sub[-928]>
    - define actual_x_max <element[2528].sub[-928]>
    - define actual_z_max <element[1258].sub[-608]>
    - if <[part]> == 1:
        - define alt_low <[low].add[<[key_x_min]>,0,<[key_z_min]>]>
        - define alt_high <[low].add[<[key_x_max]>,500,<[key_z_max]>]>
        - define alt_to <[to].add[<[key_x_min]>,0,<[key_z_min]>]>
        - run special_mass_copy_task def.from_min:<[alt_low]> def.from_max:<[alt_high]> def.to_min:<[alt_to]>
    - else if <[part]> == 2:
        - define alt_low <[low].add[<[key_x_max]>,0,<[key_z_min]>]>
        - define alt_high <[low].add[<[key2_x_max]>,500,<[key_z_max]>]>
        - define alt_to <[to].add[<[key_x_max]>,0,<[key_z_min]>]>
        - run special_mass_copy_task def.from_min:<[alt_low]> def.from_max:<[alt_high]> def.to_min:<[alt_to]>
    - else if <[part]> == 3:
        - define alt_low <[low].add[<[key2_x_max]>,0,<[key_z_min]>]>
        - define alt_high <[low].add[<[actual_x_max]>,500,<[key_z_max]>]>
        - define alt_to <[to].add[<[key2_x_max]>,0,<[key_z_min]>]>
        - run special_mass_copy_task def.from_min:<[alt_low]> def.from_max:<[alt_high]> def.to_min:<[alt_to]>
    - else if <[part]> == 4:
        - define alt_low <[low].add[0,0,<[key_z_min]>]>
        - define alt_high <[low].add[<[key_x_min]>,500,<[key_z_max]>]>
        - define alt_to <[to].add[0,0,<[key_z_min]>]>
        - run special_mass_copy_task def.from_min:<[alt_low]> def.from_max:<[alt_high]> def.to_min:<[alt_to]>
    - else if <[part]> == 5:
        - define alt_low <[low].add[0,0,0]>
        - define alt_high <[low].add[<[actual_x_max]>,500,<[actual_z_max]>]>
        - define alt_to <[to].add[0,0,0]>
        - run special_mass_copy_task def.from_min:<[alt_low]> def.from_max:<[alt_high]> def.to_min:<[alt_to]>
    - else if <[part]> == 6:
        - define alt_low <[low].add[0,0,<[key_z_max]>]>
        - define alt_high <[low].add[<[actual_x_max]>,500,<[actual_z_max]>]>
        - define alt_to <[to].add[0,0,<[key_z_max]>]>
        - run special_mass_copy_task def.from_min:<[alt_low]> def.from_max:<[alt_high]> def.to_min:<[alt_to]>




special_mass_copy_new_danary:
    type: task
    debug: false
    script:
    # Orig: 1848, 8213

    # New: 920, 357
    - define x_off <element[920].sub[1848]>
    - define z_off <element[357].sub[8213]>
    - define min <location[1766,0,7866,superflat]>
    #- define max <location[1766,300,8746,superflat]>
    - define max <location[2264,300,8746,superflat]>

    - run special_mass_copy_task def.from_min:<[min]> def.from_max:<[max]> def.to_min:<[min].add[<[x_off]>,0,<[z_off]>].with_world[danary]>

special_mass_copy_task:
    type: task
    debug: false
    definitions: from_min|from_max|to_min
    script:
    - define min_y <[from_min].y>
    - define max_y <[from_max].y>
    - define first_from_chunk <[from_min].chunk>
    - define chunk_count_x <[from_max].chunk.x.sub[<[first_from_chunk].x>]>
    - define chunk_count_z <[from_max].chunk.z.sub[<[first_from_chunk].z>]>
    - define first_to_chunk <[to_min].chunk>
    - narrate "from <[from_min]> to <[from_max]> copied to <[to_min]>"
    - narrate "Expecting X: <[chunk_count_x]> chunks (<[chunk_count_x].mul[256]> blocks), Z: <[chunk_count_z]> chunks (<[chunk_count_z].mul[256]> blocks), Total: <[chunk_count_x].mul[<[chunk_count_z]>]> chunks (<[chunk_count_x].mul[<[chunk_count_z]>].mul[256]>)"
    - define start_time <util.time_now>
    - repeat <[chunk_count_x]> as:x:
        - announce to_console "On X <[x]> / <[chunk_count_x]>, took <util.time_now.duration_since[<[start_time]>].in_seconds.round> seconds"
        - define start_time <util.time_now>
        - repeat <[chunk_count_z]> as:z:
            - define pre_time <util.current_time_millis>
            - define from_chunk <[first_from_chunk].add[<[x]>,<[z]>]>
            - chunkload <[from_chunk]> duration:10s
            - define min <[from_chunk].cuboid.min.with_y[<[min_y]>]>
            - define max <[from_chunk].cuboid.max.with_y[<[max_y]>]>
            - schematic create name:mass_copy_helper <[min]> area:<[min].to_cuboid[<[max]>]> flags entities
            - define to_chunk <[first_to_chunk].add[<[x]>,<[z]>]>
            - chunkload <[to_chunk]> duration:10s
            - wait <server.flag[mass_copywait_time]||3t>
            - schematic paste name:mass_copy_helper <[to_chunk].cuboid.min.with_y[<[min_y]>]> flags entities
            - schematic unload name:mass_copy_helper
            #- narrate "Chunk copy took <server.current_time_millis.sub[<[pre_time]>]>ms"
            - wait <server.flag[mass_copywait_time]||3t>
            - if <server.recent_tps.first> < 19:
                - wait <server.flag[mass_copywait_time]||3t>
                - wait 15t
            - if <server.recent_tps.first> < 15:
                - wait <server.flag[mass_copywait_time]||3t>
                - wait 2s
            - while <server.recent_tps.first> < 13:
                - wait 1s
    - narrate done
