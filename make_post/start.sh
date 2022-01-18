#!/bin/bash
function cd_physical_path() {
        # debug_log here
        source /usr/local/bin/hlib.sh

        # below directory independent method will work:
        # 1. if this script will be run from symlinked directory 
        # 2. it this script will be run by symlink itself
        # 3. and of course if this scipt was called directly
        this_script_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
        debug_log "Real path of this script is $this_script_dir"
        cd "$this_script_dir"
}; cd_physical_path

torsocks ./run.sh "$@"
