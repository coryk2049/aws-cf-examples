#!/bin/bash 
for FN in $(ls *.yaml);
do
	echo $FN
	aws cloudformation validate-template --template-body file://$FN;
done
