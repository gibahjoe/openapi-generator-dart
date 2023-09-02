#!/bin/bash
# A simple bash script that sets up the local stack testing environment for AWS Remote specs
awslocal s3 mb s3://bucket
SPEC="$(curl -XGET https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml)"
echo "$SPEC" >> oasspec.yaml
awslocal s3api put-object --bucket bucket --key openapi.yaml --body oasspec.yaml