#!/bin/bash

info() {
    echo -e "[`date '+%m/%d/%Y-%H:%M:%S'`]::INFO::---------------------------------------------------"
    echo -e "[`date '+%m/%d/%Y-%H:%M:%S'`]::INFO::$1"
    echo -e "[`date '+%m/%d/%Y-%H:%M:%S'`]::INFO::---------------------------------------------------"
}

YAML_FILES="main vpc sg ec2 alb"
for FNAME in ${YAML_FILES}; do
    FULL_FNAME=${FNAME}.yaml
	info "Checking CF template file: ${FULL_FNAME}"
    aws cloudformation validate-template --template-body file://${FULL_FNAME}
done
