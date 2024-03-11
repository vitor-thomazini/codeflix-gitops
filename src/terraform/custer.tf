resource "aws_security_group" "codeflix_sg" {
  vpc_id = aws_vpc.codeflix_vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.prefix}-sg"
  }
}

resource "aws_iam_role" "codeflix_cluster" {
  name = "${var.prefix}-${var.cluster_name}-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "codeflix_cluster-AmazonEKSVPCResourceController" {
  role = aws_iam_role.codeflix_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "codeflix_cluster-AmazonEKSClusterPolicy" {
  role = aws_iam_role.codeflix_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_cloudwatch_log_group" "codeflix_log" {
  name = "/aws/eks/${var.prefix}-${var.prefix}-${var.cluster_name}/cluster"
  retention_in_days = var.log-retention-days
}

resource "aws_eks_cluster" "codeflix_cluster" {
  name = "${var.prefix}-${var.cluster_name}"
  role_arn = aws_iam_role.codeflix_cluster.arn
  enabled_cluster_log_types = ["api","audit"]

  vpc_config {
    subnet_ids = aws_subnet.codeflix_vpc_subnets[*].id
    # subnet_ids = [aws_subnet.codeflix_vpc_subnet_1.id, aws_subnet.codeflix_vpc_subnet_2.id]
    security_group_ids = [aws_security_group.codeflix_sg.id]
  }
  depends_on = [
    aws_cloudwatch_log_group.codeflix_log,
    aws_iam_role_policy_attachment.codeflix_cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.codeflix_cluster-AmazonEKSVPCResourceController
  ]
}
