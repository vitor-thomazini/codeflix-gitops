resource "aws_security_group" "my_sg" {
  vpc_id = var.my_vpc_id

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

resource "aws_iam_role" "my_cluster_role" {
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

resource "aws_iam_role_policy_attachment" "my_cluster_role_AmazonEKSVPCResourceController" {
  role = aws_iam_role.my_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "my_cluster_role_AmazonEKSClusterPolicy" {
  role = aws_iam_role.my_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_cloudwatch_log_group" "my_log" {
  name = "/aws/eks/${var.prefix}-${var.prefix}-${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_days
}

resource "aws_eks_cluster" "my_eks_cluster" {
  name = "${var.prefix}-${var.cluster_name}"
  role_arn = aws_iam_role.my_cluster_role.arn
  enabled_cluster_log_types = ["api","audit"]

  vpc_config {
    subnet_ids = var.my_subnet_ids
    security_group_ids = [aws_security_group.my_sg.id]
  }
  depends_on = [
    aws_cloudwatch_log_group.my_log,
    aws_iam_role_policy_attachment.my_cluster_role_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.my_cluster-role_AmazonEKSVPCResourceController
  ]
}

resource "aws_iam_role" "my_node_role" {
  name = "${var.prefix}-${var.cluster_name}-role-name"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "my_node_role_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.my_node.name
}

resource "aws_iam_role_policy_attachment" "my_node_role_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.my_node_role.name
}

resource "aws_iam_role_policy_attachment" "my_node_role_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.my_node_role.name
}

resource "aws_eks_node_group" "my_node_1" {
  cluster_name = aws_eks_cluster.my_eks_cluster
  node_group_name = "${var.prefix}-${var.cluster_name}-node-group-1"
  node_role_arn = aws_iam_role.my_node_role.arn
  subnet_ids = var.my_subnet_ids
  instance_types = ["t3.micro"]

  scaling_config {
    desired_size = var.desired_size
    max_size = var.max_size
    min_size = var.min_size
  }

  depends_on = [
    aws_cloudwatch_log_group.my_log,
    aws_iam_role_policy_attachment.my_node_role_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.my_node_role_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.my_node_role_AmazonEC2ContainerRegistryReadOnly
  ]
}

