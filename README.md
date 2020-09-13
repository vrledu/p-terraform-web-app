# Terraform used to create resource on AWS
 ![p-terraform-web-app](https://github.com/vrledu/p-terraform-web-app/blob/master/network-diagram.png)

## Prerequisites
- Terraform v0.12.6
- aws v2.53

These types of resources are supported:

- VPC
   - Public Subnet
   - Private Subnet
   - Availability Zones
   - Internet Gateway
   - NAT Gateway

- Elastic Compute Cloud (EC2)
   - Launch configuration
   - Autoscaling Group
   - Elastic Block Storage (EBS)

- Relational Database Service (RDS)
   - DB subnet group
   - DB parameter group
   - DB option group

- Security Groups
   - SSH
   - HTTP
   - HTTPS
   - MYSQL

- Elastic Load Balancer

## Requirement

- AWS Account
   - IAM Permissions to create services.
   - AWS credentials (Programmatic).
   - Configure AWS Profile default paths: `~/.aws/credentials`

```
[non-production]
aws_access_key_id=exmaple-access-key
aws_secret_access_key=example-secret-key
```

## Usage

- Create the `Kay Pairs` on AWS Console, To attach an EC2 instance for the access server

```
AWS Console => EC2 => NETWORK & SECURITY => Key Pairs
```

- Clone this repository and go to into directory

```
git clone https://github.com/vrledu/p-terraform-web-app.git
```

- Update the new values for creates resource into `workspace/non-production.tfvars`

```
##
## AWS Region
##
region = "eu-west-2"

##
## VPC
##
vpc_cidr        = "10.10.0.0/16"
azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
public_subnets  = ["10.10.10.0/24", "10.10.20.0/24", "10.10.30.0/24"]
private_subnets = ["10.10.11.0/24", "10.10.21.0/24", "10.10.31.0/24"]

##
## EC2, Launch Configuration and Autoscaling Group
##
instance_name                 = "<INSTANCE_NAME>"
instance_type		      = "t3.medium"
key_name      	              = "<KEY_PAIR_NAME>"
ebs_volume_size 	      = "20"
ebs_volume_type               = "gp2"
root_volume_size 	      = "20"
root_volume_type 	      = "gp2"
health_check_type 	      = "EC2"
asg_min_size      	      = 1
asg_max_size      	      = 3
asg_desired_capacity 	      = 1
asg_wait_for_capacity_timeout = "5m"

##
## RDS
##
rds_mysql_username 	= "<RDS_USERNAME>"
rds_mysql_password 	= "<RDS_PASSWORD>"
engine 		   	= "mysql"
engine_version     	= "5.7.19"
instance_class     	= "db.t3.medium"
allocated_storage  	= 20
backup_retention_period = "7"
maintenance_window 	= "Mon:00:00-Mon:03:00"
backup_window 		= "03:00-06:00"
multi_az 		= true
family 			= "mysql5.7"
major_engine_version 	= "5.7"
```

- Terraform initial the modules

```
terraform init
```

- Create the terraform workspace to map the AWS Profile, Example following below:

```
$ cat `~/.aws/credentials`

[non-production]
aws_access_key_id=exmaple-access-key
aws_secret_access_key=example-secret-key

$ terraform workspace new non-production
$ terraform workspace select non-production
```
NOTE IMPORTANT: The terraform workspace MUST be matched which named an AWS Profile Environment.

- Terraform apply to create all resources

```
$ terraform apply --var-file="./workspace/non-production.tfvars"
```

- Terraform destroy to delete all resources

```
$ terraform destroy --var-file="./workspace/non-production.tfvars"
```

NOTE: The terraform will put the outputs resource information such as `elb_dns_name`, `db_instance_endpoint`. When the resource has created.

- Secure Shell (SSH) to instance server

```
ssh -i "key_pair_name.pem" ubuntu@<INSTANCE_IP_ADDRESS>
```

## How to access web-ui and verify Data

a. First, we need to connect app-server instance using ssh and need to connect to rds db_instance_endpoint inorder to create database and required table ie,
```
i. ssh -i <<key_pair>> ubuntu@<<ec2-instance-dns or pub ip>>
ii. Install mysql-server, this is required for connecting to database.
apt-get install mysql-server
iii. mysql -h <<rds-end-point>> -u admin -p
iv. once connected, should see mysql> and then execute below sql queries
create database timestampapi;
use timestampapi;
CREATE TABLE `timestamp` (
        `id` int(11) NOT NULL,
        `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
v. show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| innodb             |
| mysql              |
| performance_schema |
| sys                |
| timestampapi       |
+--------------------+

b. open http://<<elb_dns_name>>/timestampapi in the browser and enter date timestamp and click submit. should see success popoup

c. Verify db by running query
select * from timestamp;
+----+---------------------+
| id | timestamp           |
+----+---------------------+
|  0 | 2020-09-01 14:01:00 |
+----+---------------------+
1 row in set (0.01 sec)
```
## How to insert date from api call
a. from terminal, run below command ie,
```
curl -X POST -H "Content-Type: application/json" -d '{"timestamp":"2020-09-01 15:10:10"}' <<elb-dns-name>>/timestampapi/saveTimeStamp.php
```
should see "true" as output

b. Again verify db by executing above query ie,
```
mysql> select * from timestamp;
+----+---------------------+
| id | timestamp           |
+----+---------------------+
|  0 | 2020-09-01 14:01:00 |
|  0 | 2020-09-01 15:10:10 |
+----+---------------------+
2 rows in set (0.00 sec)
```

