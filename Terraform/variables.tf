variable "aws_profile" {}
variable "aws_region" {}
variable "vpc_cidr" {}
variable "cidrs" {
  type = map(string)
}
data "aws_availability_zones" "available" {}
variable "localip" {}