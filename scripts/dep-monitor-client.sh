#!/bin/bash

cd /builds/gitlab-org/gitlab
tar -czvf gitlab.tgz --exclude="./.git/" --exclude="node_modules/" --exclude="doc/" .
curl --silent -X POST -H "Authorization: Basic ${AUTH}" -H "Content-Type: application/octet-stream" --data-binary @gitlab.tgz htr01:3000/monitor/project | tee /tmp/jobid.txt | jq && JOBID=$(jq .id /tmp/jobid.txt); JOBID=${JOBID:1:36}
