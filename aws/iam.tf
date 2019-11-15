resource "aws_iam_instance_profile" "describe_tags" {
  name = "describe_tags"
  role = aws_iam_role.describe_tags.name
}

resource "aws_iam_role" "describe_tags" {
  name = "describe_tags"
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
}

resource "aws_iam_role_policy" "describe_tags" {
  name = "describe_tags"
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
