## cf-example-12

Cloudformation template to demonstrate CodeDeploy (in-place deployment) using a simple web application.

### Procedure
- Ensure that source code in `SampleApp_Linux` folder is ready for deployment (e.g. checked out version from SCM)
- Provision CF template to setup AWS infrastructure (e.g. IAM, EC2)
- Execute `awsConfigCodeDeploy.sh` to push source code bundle to S3 bucket, and then perform CodeDeploy to EC2 instance provisioned earlier with CF

### References
https://github.com/aws/aws-codedeploy-agent/issues/14
