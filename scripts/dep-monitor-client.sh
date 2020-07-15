#!/bin/bash -x

# check if variable Auth has been set

if [ -z "$DEP_MONITOR_AUTH" ]; then 
    echo "DEP_MONITOR_AUTH is not set. Please set it when starting the pipeline"
    exit 1
fi

apt-get update && apt-get install -y jq
cd /builds/gitlab-org/gitlab
du -h -d 1 . | sort -h
tar -czf gitlab.tgz --exclude=".git" --exclude="node_modules" --exclude="doc" .
curl --silent -X POST -H "Authorization: Basic c29tZWJlcnQ6ajN2ZXBlNHlNQ21JKzY0bw==" \
                      -H "Content-Type: application/octet-stream" \
                      --data-binary @gitlab.tgz 46.101.173.169:3000/monitor/project \
    | tee /tmp/jobid.txt | jq . && JOBID=$(jq .id /tmp/jobid.txt); JOBID=${JOBID:1:36}


STATUS=$(curl --silent -G -d "id=$JOBID" 46.101.173.169:3000 | jq -r .status)
set +x
echo "analysing dependencies"
while ( [ "$STATUS" = "pending" ] )
do
    echo .
    sleep 2
    STATUS=$(curl --silent -G -d "id=$JOBID" 46.101.173.169:3000 | jq -r .status)
done

echo "Details"
curl --silent -G -d "id=$JOBID" 46.101.173.169:3000 | jq .

echo "Summary"
curl --silent -G -d "id=$JOBID" 46.101.173.169:3000 \
  | jq .result[].rule \
  | sort \
  | uniq -c
