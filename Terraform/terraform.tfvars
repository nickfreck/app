aws_region  = "eu-west-1"
aws_profile = "terraform"
vpc_cidr    = "10.0.0.0/16"
cidrs = {
  public1  = "10.0.1.0/24"
  public2  = "10.0.2.0/24"
  private1 = "10.0.10.0/24"
  private2 = "10.0.20.0/24"
  rds1     = "10.0.11.0/24"
  rds2     = "10.0.22.0/24"
  rds3     = "10.0.33.0/24"
}
localip = "192.168.1.1/32"
