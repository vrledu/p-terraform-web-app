output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

output "azs" {
  description = "A list of availability zones specified as argument to vpc module"
  value       = module.vpc.azs
}

output "name" {
  description = "The name of the VPC specified as argument to vpc module"
  value       = module.vpc.name
}

output "launch_configuration_id" {
  description = "The ID of the launch configuration"
  value       = module.ec2.this_launch_configuration_id
}

output "autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = module.ec2.this_autoscaling_group_id
}

output "autoscaling_group_availability_zones" {
  description = "The availability zones of the autoscale group"
  value       = module.ec2.this_autoscaling_group_availability_zones
}

output "autoscaling_group_vpc_zone_identifier" {
  description = "The VPC zone identifier"
  value       = module.ec2.this_autoscaling_group_vpc_zone_identifier
}

output "autoscaling_group_load_balancers" {
  description = "The load balancer names associated with the autoscaling group"
  value       = module.ec2.this_autoscaling_group_load_balancers
}

output "autoscaling_group_target_group_arns" {
  description = "List of Target Group ARNs that apply to this AutoScaling Group"
  value       = module.ec2.this_autoscaling_group_target_group_arns
}

output "elb_dns_name" {
  description = "DNS Name of the ALB"
  value       = module.elb.elb_dns_name
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.rds.db_instance_endpoint
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = module.rds.db_instance_username
}

output "db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = var.rds_mysql_password
  sensitive   = true
}
