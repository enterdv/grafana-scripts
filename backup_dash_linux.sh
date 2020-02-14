#!/bin/bash

OPTSPEC=":hp:t:k:"

show_help() {
cat << EOF
Usage: $0 [-p PATH] [-t TARGET_HOST] [-k API_KEY]
Script to backup dashboards from Grafana
    -t      Required. The full URL of the target host
    -k      Required. The API key to use on the target host
    -p      Required. Root path for JSON of the dashboards

    -h      Display this help and exit
EOF
}

###### Check script invocation options ######
while getopts "$OPTSPEC" optchar; do
    case "$optchar" in
        h)
            show_help
            exit
            ;;
        p)
            DASH_DIR="$OPTARG";;

        t)
            HOST="$OPTARG";;
        k)
            KEY="$OPTARG";;
        \?)
          echo "Invalid option: -$OPTARG" >&2
          exit 1
          ;;
        :)
          echo "Option -$OPTARG requires an argument." >&2
          exit 1
          ;;
    esac
done

if [ -z "$DASH_DIR" ] || [ -z "$HOST" ] || [ -z "$KEY" ]; then
    show_help
    exit 1
fi

# set some colors for status OK, FAIL and titles
SETCOLOR_SUCCESS="echo -en \\033[0;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"
SETCOLOR_TITLE_PURPLE="echo -en \\033[0;35m" # purple

# usage log "string to log" "color option"
function log_success() {
   if [ $# -lt 1 ]; then
       ${SETCOLOR_FAILURE}
       echo "Not enough arguments for log function! Expecting 1 argument got $#"
       exit 1
   fi

   timestamp=$(date "+%Y-%m-%d %H:%M:%S %Z")

   ${SETCOLOR_SUCCESS}
   printf "[${timestamp}] $1\n"
   ${SETCOLOR_NORMAL}
}

function log_failure() {
   if [ $# -lt 1 ]; then
       ${SETCOLOR_FAILURE}
       echo "Not enough arguments for log function! Expecting 1 argument got $#"
       exit 1
   fi

   timestamp=$(date "+%Y-%m-%d %H:%M:%S %Z")

   ${SETCOLOR_FAILURE}
   printf "[${timestamp}] $1\n"
   ${SETCOLOR_NORMAL}
}

function log_title() {
   if [ $# -lt 1 ]; then
       ${SETCOLOR_FAILURE}
       log_failure "Not enough arguments for log function! Expecting 1 argument got $#"
       exit 1
   fi

   ${SETCOLOR_TITLE_PURPLE}
   printf "|-------------------------------------------------------------------------|\n"
   printf "|$1|\n";
   printf "|-------------------------------------------------------------------------|\n"
   ${SETCOLOR_NORMAL}
}

function init() {
   # Check if hostname and key are provided
   if [ $1 -lt 2 ]; then
       ${SETCOLOR_FAILURE}
       log_failure "Not enough command line arguments! Expecting two: \$HOSTNAME and \$KEY. Recieved only $1."
       exit 1
   fi

   if [ ! -d "${DASH_DIR}" ]; then
   	 mkdir "${DASH_DIR}"
   else
   	log_title "----------------- A $DASH_DIR directory already exists! -----------------"
   fi
}

init $# $HOST $KEY

counter=0

for dashboard_uid in $(curl -sS -H "Authorization: Bearer $KEY" $HOST/api/search\?query\=\& | jq -r '.[] | select( .type | contains("dash-db")) | .uid'); do

   counter=$((counter + 1))
   dashboard_json="$(curl -sS -H "Authorization: Bearer $KEY" $HOST/api/dashboards/uid/$dashboard_uid)"
   dashboard_title="$(echo $dashboard_json | jq -r '.dashboard | .title' | sed -r 's/[ \/]+/_/g' )"
   dashboard_version="$(echo $dashboard_json | jq -r '.dashboard | .version')"
   folder_title="$(echo $dashboard_json | jq -r '.meta | .folderTitle')"

   mkdir -p "$DASH_DIR/$folder_title"
   echo $dashboard_json > "$DASH_DIR/$folder_title/${dashboard_title}.json"

   log_success "Dashboard has been saved\t\t title=\"${dashboard_title}\", uid=\"${dashboard_uid}\", path=\"${DASH_DIR}/$folder_title/${dashboard_title}.json\"."
done

log_title "${counter} dashboards were saved";

log_title "------------------------------ FINISHED ---------------------------------";
