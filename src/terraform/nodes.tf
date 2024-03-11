resource "aws_iam_role" "codeflix_node" {
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

resource "aws_iam_role_policy_attachment" "codeflix_node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.codeflix_node.name
}

resource "aws_iam_role_policy_attachment" "codeflix_node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.codeflix_node.name
}

resource "aws_iam_role_policy_attachment" "codeflix_node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.codeflix_node.name
}

resource "aws_eks_node_group" "node-1" {
  cluster_name = aws_eks_cluster.codeflix_cluster
  node_group_name = "node-1"
  node_role_arn = aws_iam_role.codeflix_node.arn
  subnet_ids = aws_subnet.codeflix_vpc_subnets[*].id
  instance_types = ["t3.micro"]

  scaling_config {
    desired_size = var.desired_size
    max_size = var.max_size
    min_size = var.min_size
  }

  depends_on = [
    aws_cloudwatch_log_group.codeflix_log,
    aws_iam_role_policy_attachment.codeflix_cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.codeflix_cluster-AmazonEKSVPCResourceController
  ]
}
