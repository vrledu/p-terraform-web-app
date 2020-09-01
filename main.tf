##
## Cloud provider
##
provider "aws" {
  profile = local.profile
  region  = var.region
}

##
## AWS Profile
##
locals {
  profile = "${terraform.workspace}"
}

##
## Data source to get the security group of VPC
##
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

##
## Data source to get AWS AMI (ubuntu)
##
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

##
## IAM Service Role
##
resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "A service linked role for autoscaling"
  custom_suffix    = "something2"

  ## Sometimes good sleep is required to have some IAM resources created before they can be used
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

##
## Security Groups
## 
resource "aws_security_group" "ssh" {
  name        = "ssh"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Security group with SSH ports open for everybody (IPv4 CIDR), egress ports are all world open"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH"
  }
}

resource "aws_security_group" "http" {
  name        = "http"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Security group with HTTP ports open for everybody (IPv4 CIDR), egress ports are all world open"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "HTTP"
  }
}

resource "aws_security_group" "https" {
  name        = "https"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Security group with HTTPS ports open for everybody (IPv4 CIDR), egress ports are all world open"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "HTTPS"
  }
}

resource "aws_security_group" "mysql" {
  name        = "mysql"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Security group with MySQL ports,  Allow ingress rules to be accessed only within current VPC."
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySQL"
  }
}

##
## User data
##
data "template_file" "user_data_web_application" {
  template = "${file("${path.module}/templates/user_data_web_application.yml")}"

  vars =  {
    name                = "${local.profile}-${var.instance_name}"
    database_endpoint   = module.rds.db_instance_endpoint
    database_username   = module.rds.db_instance_username
    database_password   = var.rds_mysql_password
  }
}

##
## VPC
##
module "vpc" {
  source = "./modules/aws/vpc"

  name = "${local.profile}"
  cidr = var.vpc_cidr
  azs                 = var.azs
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    NetworkZone = "public"
  }

  private_subnet_tags = {
    NetworkZone = "private"
  }

  tags = {
    Owner       = "infra"
    Environment = local.profile
  }
}

##
## EC2, Launch Configuration and Autoscaling Group
##
module "ec2" {
  source = "./modules/aws/ec2"

  name = "${local.profile}-${var.instance_name}" 

  ##
  ## Launch configuration
  ##

  ## [UNCOMMENT] To use the existing launch configuration
  # launch_configuration = "my-existing-launch-configuration"

  ## [UNCOMMENT] To disables creation of launch configuration
  # create_lc = false 

  lc_name                      = "${local.profile}-${var.instance_name}-lc"
  image_id                     = "${data.aws_ami.ubuntu.id}" 
  instance_type                = var.instance_type
  key_name                     = var.key_name
  security_groups              = [aws_security_group.ssh.id ,aws_security_group.http.id, aws_security_group.https.id]
  load_balancers               = [module.elb.elb_id]

  ## [UNCOMMENT] To associate the public ip (The Auto scaling group MUST be public subnet as well.)
  # associate_public_ip_address  = true
  recreate_asg_when_lc_changes = true
  user_data = data.template_file.user_data_web_application.rendered

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_size           = var.ebs_volume_size
      volume_type           = var.ebs_volume_type
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      delete_on_termination = true
    },
  ]

  ##
  ## Auto scaling group
  ##
  asg_name                  = "${local.profile}-${var.instance_name}-asg"
  vpc_zone_identifier       = module.vpc.public_subnets ## module.vpc.private_subnets
  health_check_type         = var.health_check_type
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  wait_for_capacity_timeout = var.asg_wait_for_capacity_timeout 
  service_linked_role_arn   = aws_iam_service_linked_role.autoscaling.arn

  tags = [
    {
      key                 = "Owner"
      value               = "infra"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = local.profile
      propagate_at_launch = true
    },
  ]
}

##
## ELB
##
module "elb" {
  source = "./modules/aws/elb"

  name = "${local.profile}-elb"

  subnets         = module.vpc.public_subnets 
  security_groups = [aws_security_group.ssh.id ,aws_security_group.http.id, aws_security_group.https.id]
  internal        = false

  listener = [
    {
      instance_port     = "22"
      instance_protocol = "TCP"
      lb_port           = "22"
      lb_protocol       = "TCP"
    },
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = {
    Owner       = "infra"
    Environment = local.profile
  }
}

module "rds" {
  source = "./modules/aws/rds"

  identifier = "${local.profile}-db-mysql"

  ## All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_encrypted = false

  ## [UNCOMMENT] To use KMS key.
  # kms_key_id        = "arm:aws:kms:<region>:<accound id>:key/<kms key id>"

  ## Used identifier name instead.
  name     = ""

  username = var.rds_mysql_username
  password = var.rds_mysql_password
  port     = "3306"

  vpc_security_group_ids = [aws_security_group.mysql.id]

  maintenance_window = var.maintenance_window
  backup_window      = var.backup_window

  multi_az = var.multi_az

  ## Disable backups to create DB faster
  backup_retention_period = var.backup_retention_period

  ## DB subnet group
  subnet_ids = module.vpc.private_subnets 

  ## DB parameter group
  family = var.family

  ## DB option group
  major_engine_version = var.major_engine_version

  ## Snapshot name upon DB deletion
  final_snapshot_identifier = "${local.profile}-db-mysql-snapshot"

  ## Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8"
    },
    {
      name  = "character_set_server"
      value = "utf8"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]

  tags = {
    Owner       = "infra"
    Environment = local.profile
  }
}
