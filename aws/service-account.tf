resource "aws_iam_user" "mgmt_sa" {
  name = "mgmt-sa-${local.cluster_id}"

  tags = {
    cluster = local.cluster_id
  }
}

resource "aws_iam_user_policy" "start_stop_nodes" {
  name = "start_stop_nodes_${local.cluster_id}"
  user = aws_iam_user.mgmt_sa.name
  policy = data.aws_iam_policy_document.start_stop_nodes.json
}

resource "aws_iam_access_key" "mgmt_sa" {
  user = aws_iam_user.mgmt_sa.name
}
