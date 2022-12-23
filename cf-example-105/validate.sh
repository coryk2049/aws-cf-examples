#!/bin/bash

info() {
    echo -e "[`date '+%m/%d/%Y-%H:%M:%S'`]::INFO::---------------------------------------------------"
    echo -e "[`date '+%m/%d/%Y-%H:%M:%S'`]::INFO::$1"
    echo -e "[`date '+%m/%d/%Y-%H:%M:%S'`]::INFO::---------------------------------------------------"
}


for FN in $(ls *.yaml); do
	info "Validating CF template file: ${FN}"
	aws cloudformation validate-template --template-body file://$FN;
done
