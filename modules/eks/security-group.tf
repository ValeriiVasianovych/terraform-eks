resource "aws_security_group" "sg" {
  name        = "eks-cluster-${var.env}"
  vpc_id      = var.vpc_id
  description = "EKS Cluster Security Group"

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "security-group-${var.env}"
  }
}