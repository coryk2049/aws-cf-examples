## cf-example-13

Cloudformation template to demonstrate CodeDeploy (bluegreen deployment) using a simple web application.

### Procedure
- Provision CF template to setup AWS infrastructure (e.g. Workstation, Blue WebServer ASG, Green WebServer ASG)
- Point browser to ELB DNS name to view current version (e.g. version 1.0) of web page deployed on Blue WebServer ASG
- On Workstation EC2 instance, to remotely manage CodeDeploy expect to find these scripts:
```
scripts/setupAwsProfile
scripts/pushNewVersion.sh
scripts/updateDeploymentGroup.sh
scripts/cleanup.sh
newVersion/appspec.yml
newVersion/content/index.php
newVersion/scripts/beforeInstall.sh
```
- Source  `scripts/setupAwsProfile`
- Execute `scripts/pushNewVersion.sh` to push new source code bundle to S3 bucket but do not deploy as prompted
- Execute `scripts/updateDeploymentGroup.sh` to prepare deployment of Green WebServer ASG when deploy in next step
- CodeDeploy via AWS Management Console or AWS CLI instructions prompted earlier by the push script
- Navigate to EC2 tab in AWS Management Console to monitor Green WebServer ASG being spun up
- Point browser to ELB DNS name to view new version (e.g. version 2.0) of web page deployed
- Execute `scripts/cleanup.sh` to remove deployment bundle from S3 bucket, and both ASGs
```
# Check ASG deployment status
aws autoscaling describe-auto-scaling-groups \
 --query 'AutoScalingGroups[].[AutoScalingGroupName,VPCZoneIdentifier]' \
 --output text
```
- Delete CF stack created earlier to finish off cleaning up!

### References
- https://github.com/aws/aws-codedeploy-agent/issues/14
- https://aws.amazon.com/blogs/devops/performing-bluegreen-deployments-with-aws-codedeploy-and-auto-scaling-groups/
