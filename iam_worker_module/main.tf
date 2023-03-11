resource "aws_iam_role" "worker_role" {
  name = "k8s-worker-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "k8s-worker-iam-policy"
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
                "ec2:DescribeRegions",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:BatchGetImage"
        ]
        Resource = ["*"]
      }
    ]
  })
}
}
resource "aws_iam_instance_profile" "worker_profile" {
  name = "k8s-worker-instance-profile"
  role = aws_iam_role.worker_role.name
}
variable "subnet_id" {
  #type = string
  default = "null"
}
variable "vpc_id" {
  #type = string
  default = "null"
}

resource "aws_instance" "worker_instance" {
  ami           = "ami-0557a15b87f6559cf" 
  instance_type = "t2.medium"
  subnet_id = var.subnet_id.id
  iam_instance_profile = aws_iam_instance_profile.worker_profile.name

  tags = {
    Name              = "k8-worker"
    KubernetesCluster = "owned"
  }
}
resource "aws_security_group" "worker-sg" {
  name = "worker-sg"
  vpc_id      = var.vpc_id.id
        ingress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }

        
        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
}

