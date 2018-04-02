variable "dev_vpc_id" {
    default = "vpc-f1b4dc96"
    description = "ID of the VPC to use"
}

variable "test_vpc_id" {
    default = "vpc-edb3db8a"
    description = "ID of the VPC to use"
}

variable "prod_vpc_id" {
    default = "vpc-f7b3db90"
    description = "ID of the VPC to use"
}
variable "dev_subnets" {
    default = "subnet-7ed9b037,subnet-eae548b1"
}

variable "test_subnets" {
    default = "subnet-e8d9b0a1,subnet-68e94433"
}

variable "prod_subnets" {
    default = "subnet-e1c4ada8"
}
