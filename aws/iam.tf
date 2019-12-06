resource "aws_iam_instance_profile" "describe_tags" {
  name = "describe_tags-${local.cluster_id}"
  role = aws_iam_role.describe_tags.name
}

resource "aws_iam_role" "describe_tags" {
  name = "describe_tags-${local.cluster_id}"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "citc-describe_tags-${local.cluster_id}"
    cluster = local.cluster_id
  }
}

resource "aws_iam_role_policy" "describe_tags" {
  name = "describe_tags-${local.cluster_id}"
  role = aws_iam_role.describe_tags.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeTags"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
