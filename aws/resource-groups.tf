resource "aws_resourcegroups_group" "all" {
  name = "group-${local.cluster_id}"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "cluster",
      "Values": ["${local.cluster_id}"]
    }
  ]
}
JSON
  }
}
