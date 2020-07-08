#!/bin/bash -x
apt-get update && apt-get install -y jq
cd /builds/gitlab-org/gitlab
du -h -d 1 . | sort -h
tar -czf gitlab.tgz --exclude=".git" --exclude="node_modules" --exclude="doc" .
curl --silent -X POST -H "Authorization: Basic c29tZWJlcnQ6ajN2ZXBlNHlNQ21JKzY0bw==" -H "Content-Type: application/octet-stream" --data-binary @gitlab.tgz 46.101.173.169:3000/monitor/project | tee /tmp/jobid.txt | jq . && JOBID=$(jq .id /tmp/jobid.txt); JOBID=${JOBID:1:36}


while ( $(curl --silent -G -d "id=$JOBID" 46.101.173.169:3000 | jq .status) == "pending" )
do
    echo .
    sleep 1
done

curl --silent -G -d "id=$JOBID" 46.101.173.169:3000