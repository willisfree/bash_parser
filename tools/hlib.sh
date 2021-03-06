# set of useful bash functions
# this file must be always in the same directory (e.g /usr/local/bin)
# just source this file from your script and enjoy

function debug_log() {
        local msg=$1
        printf "%s\n" "$msg" 1>&2
}

# below directory independent method will work
# 1. if this script will be run from symlinked directory 
# 2. it this script will be run by symlink itself
function cd_physical_path() {
	local this_script_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
	debug_log "Real path of this script is $this_script_dir"
	cd "$this_script_dir"
}
