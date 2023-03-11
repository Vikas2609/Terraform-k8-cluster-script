provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "k8s_cluster_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name              = "K8s-cluster-vpc"
    KubernetesCluster = "owned"
  }
}
resource "aws_subnet" "k8s_cluster_subnet" {
  vpc_id                  = aws_vpc.k8s_cluster_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name              = "K8s-cluster-net"
    KubernetesCluster = "owned"
  }
}
resource "aws_internet_gateway" "k8s_cluster_igw" {
  vpc_id = aws_vpc.k8s_cluster_vpc.id
  tags = {
    Name              = "K8s-cluster-igw"
    KubernetesCluster = "owned"
  }
}
resource "aws_route_table" "k8s_cluster_rtb" {
  vpc_id = aws_vpc.k8s_cluster_vpc.id
  tags = {
    Name              = "K8s-cluster-rtb"
    KubernetesCluster = "owned"
  }
}

resource "aws_route" "k8s_cluster_rtb_internet_gateway_route" {
  route_table_id         = aws_route_table.k8s_cluster_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.k8s_cluster_igw.id
}

resource "aws_route_table_association" "k8s_cluster_rtb_subnet_association" {
  subnet_id      = aws_subnet.k8s_cluster_subnet.id
  route_table_id = aws_route_table.k8s_cluster_rtb.id
}
module "iam_module_master" {
  source    = "./module/iam_module_master"
  vpc_id    = aws_vpc.k8s_cluster_vpc
  subnet_id = aws_subnet.k8s_cluster_subnet
}

module "iam_module_worker" {
  source    = "./module/iam_module_worker"
  vpc_id    = aws_vpc.k8s_cluster_vpc
  subnet_id = aws_subnet.k8s_cluster_subnet
}




