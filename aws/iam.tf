resource "aws_iam_instance_profile" "manage_ec2" {
  name = "manage_ec2_${local.cluster_id}"
  role = aws_iam_role.manage_ec2.name
}

resource "aws_iam_role" "manage_ec2" {
  name = "manage_ec2_${local.cluster_id}"
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
    Name    = "manage_ec2_${local.cluster_id}"
    cluster = local.cluster_id
  }
}

resource "aws_iam_role_policy" "manage_ec2" {
  name   = "manage_ec2_${local.cluster_id}"
  role   = aws_iam_role.manage_ec2.id
  policy = "${data.aws_iam_policy_document.manage_ec2.json}"
}

data "aws_iam_policy_document" "manage_ec2" {
  statement {
    sid = "1"

    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeImages",
      "ec2:RunInstances",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "2"

    actions = [
      "ec2:TerminateInstances",
      "route53:ChangeResourceRecordSets",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringLike"
      variable = "iam:ResourceTag/cluster"

      values = [
        local.cluster_id
      ]
    }
  }
}
