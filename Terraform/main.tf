provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# ------- IAM

# S3 ACCESS

resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3_access"
  role = "aws_iam_role.s3_access_role.name"
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = "aws_iam_role.s3_access_role.id}"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
      }
   ]
}
EOF

}

resource "aws_iam_role" "s3_access_role" {
  name = "s3_access_role"

  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
   {
      "Action": "sts:AssumeRole",
      "Principle": {
         "Service": "ec2.amazonaws.com"
   },
        "Effect": "Allow",
        "Sid": ""
      }
   ]   
}
EOF

}

# ----- VPC

resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "app_vpc"
  }
}

# IGW

resource "aws_internet_gateway" "ap_internet_gateway" {
  vpc_id = "aws_vpc.app_vpc.id}"

  tags = {
    Name = "app_igw"
  }
}

# Route Tables

resource "aws_route_table" "app_public_rt" {
  vpc_id = "aws_vpc.app_vpc.id"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "aws_internet_gateway.ap_internet_gateway.id"
  }

  tags = {
    Name = "app_public"
  }
}

resource "aws_default_route_table" "app_private_rt" {
  default_route_table_id = "aws_vpc.app_vpc.default_route_table_id"

  tags = {
    Name = "app_public"
  }
}

# Subnets

resource "aws_subnet" "app_public1_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["public1"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "ap_public1"
  }
}

resource "aws_subnet" "app_public2_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["public2"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "ap_public2"
  }
}

resource "aws_subnet" "app_private1_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["private1"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "ap_private1"
  }
}

resource "aws_subnet" "app_private2_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["private2"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "ap_private2"
  }
}

resource "aws_subnet" "app_rds1_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["rds1"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "app_rds1"
  }
}

resource "aws_subnet" "app_rds2_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["rds2"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "app_rds2"
  }
}

# RDS subnet group

resource "aws_db_subnet_group" "app_rds_subnetgroup" {
   name = "app_rds_subnetgroup"

   subnet_ids = ["${aws_subnet.app_rds1_subnet.id}",
     "${aws_subnet.app_rds2_subnet.id}",
   ]

   tags = {
      Name = "app_rds_sng"
  }
}

# Subnet Associations

resource "aws_route_table_association" "app_public1_assoc" {
   subnet_id = "aws_subnet.app_public1_subnet.id"
   route_table_id = "{$aws_route_table.app_public.rt.id}"
}

resource "aws_route_table_association" "app_public2_assoc" {
   subnet_id = "aws_subnet.app_public2_subnet.id"
   route_table_id = "{$aws_route_table.app_public.rt.id}"
}

resource "aws_route_table_association" "app_private1_assoc" {
   subnet_id = "aws_subnet.app_private1_subnet.id"
   route_table_id = "{$aws_route_table.app_private.rt.id}"
}

resource "aws_route_table_association" "app_private2_assoc" {
   subnet_id = "aws_subnet.app_private2_subnet.id"
   route_table_id = "{$aws_route_table.app_private.rt.id}"
}

# Security groups

resource "aws_security_group" "app_dev_sg" {
   name = "app_dev_sg"
   description = "Used for access to the dev instance"
   vpc_id = "aws_vpc.app_vpc.id"

   #SSH

   ingress {
      from_port = 22
      to_port =22
      protocol = "ssh"
      cidr_blocks = ["${var.localip}"]
   }
   
   #HTTP

   ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["${var.localip}"]
   }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}
