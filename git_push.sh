#!/bin/bash
cd /var/lib/rundeck/projects/Deploy/backup-grafana/dashboards/
git config --replace-all user.name rundeck
git config user.email rundeck@dsx.uk
git add -A && git diff-index --quiet HEAD || git commit -m "New files on `date +'%Y-%m-%d'`"
ssh-agent bash -c 'ssh-add /var/lib/rundeck/.ssh/bitbucket; git push -u origin dev'