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
instance_name = "webapp"
instance_type = "t3.micro"
key_name      = "vijay_keypair"
ebs_volume_size = "20"
ebs_volume_type = "gp2"
root_volume_size = "20"
root_volume_type = "gp2"
health_check_type = "EC2"
asg_min_size      = 1
asg_max_size      = 1
asg_desired_capacity = 1
asg_wait_for_capacity_timeout = "5m"

##
## RDS
##
rds_mysql_username = "admin"
rds_mysql_password = "admin-password"
engine = "mysql"
engine_version = "5.7.19"
instance_class = "db.t3.medium"
allocated_storage = 20
backup_retention_period = "7"
maintenance_window = "Mon:00:00-Mon:03:00"
backup_window = "03:00-06:00"
multi_az = true
family = "mysql5.7"
major_engine_version = "5.7"
