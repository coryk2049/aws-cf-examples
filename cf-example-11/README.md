## cf-example-11

Cloudformation template to deploy a VPC with 1 AZ, DMZ, and ES cluster.

### Create ES service linked role prior to deploying CF template
```
# aws iam create-service-linked-role --aws-service-name es.amazonaws.com
```
Note: Not possible to do with CF at this time according to AWS

### Configure SSH tunnel for ES remote access from your laptop

```
# cat ~/.ssh/config

Host <MY-ES-TUNNEL>
HostName <MY-EC2-PUBLIC-IP-ADDRESS>
User ec2-user
IdentitiesOnly yes
IdentityFile ~/.ssh/<MY-AWS-ACCESS-KEY>.pem
LocalForward 9200 <MY-ES-VPC-END-POINT>:443
```

### Execute ES tunnel

```
# ssh <MY-ES-TUNNEL> -N
```

### How to remotely access ES Search and Kibana

```
ES Search: https://localhost:9200
ES Kibana: https://localhost:9200/_plugin/kibana
```
Note: Ignore browser SSL certification exceptions (e.g. curl -k)

### ES testing with mock data
```
Refer to JSON test files:
 - test_data_auto_id.json
 - test_data_custom_id.json
```

### References
ES SSH tunnel tip:
```
https://www.jeremydaly.com/access-aws-vpc-based-elasticsearch-cluster-locally/
```
