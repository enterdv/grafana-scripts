Bash scripts to export and import all dashboards JSON files from Grafana
====
Requirements MacOS
---
* brew
* gnu-sed
* jq
* curl
* grafana api token

Requirements Linux
---
* jq
* sed
* curl
* grafana api token

Backup usage
---
```text
backup_dash_linux.sh [-p PATH] [-t TARGET_HOST] [-k API_KEY]
Script to backup dashboards from Grafana
    -t      Required. The full URL of the target host
    -k      Required. The API key to use on the target host
    -p      Required. Root path for JSON exports of the dashboards

    -h      Display this help and exit
```
Import usage
---
```text
import_dash.sh [-p PATH] [-t TARGET_HOST] [-k API_KEY]
Script to import dashboards into Grafana
    -t      Required. The full URL of the target host
    -k      Required. The API key to use on the target host
    -p      Required. Root path containing JSON exports of the dashboards you want imported.

    -h      Display this help and exit.
```
Example
---
```shell script
./backup_dash_macos.sh -t http://localhost:3000  -k <secret_token> -p dashboards
```