#! /bin/bash
set -euo pipefail

# This script is run on cluster destruction to shut down any remaining nodes
# and delete any lingering images

echo Terminating any remaining compute nodes
for instance_id in $(aws ec2 describe-instances --query='Reservations[].Instances[?State.Name!=`terminated`].[InstanceId]' --filters "Name=tag:cluster,Values=${CLUSTERID}" "Name=tag:type,Values=compute" --output=text)
do
    aws ec2 terminate-instances --instance-ids="${instance_id}"
done
echo Node termination request completed

echo Wiping DNS entries for hanging nodes
hosted_zone_id=$(aws route53 list-hosted-zones --output text --query 'HostedZones[?Name==`'"${CLUSTERID}"'.citc.local.`].Id')
# Due to the clunkiness of the route53 api, we have to reconstruct the record manually.
# This requires the records to only have one IP in them for now.
aws route53 list-resource-record-sets --hosted-zone-id "${hosted_zone_id}" --query 'ResourceRecordSets[?Type==`A`].[Name,TTL,ResourceRecords[0].Value]' --output=text | while read -r name_ttl_ip
do
  name=$(echo "${name_ttl_ip}" | cut -f1)
  ttl=$(echo "${name_ttl_ip}" | cut -f2)
  ip=$(echo "${name_ttl_ip}" | cut -f3)
  if [[ "${name}" == "mgmt.${CLUSTERID}.citc.local." ]]; then
    continue
  fi
  aws route53 change-resource-record-sets \
    --hosted-zone-id $hosted_zone_id \
    --change-batch '{"Changes":[{"Action":"DELETE","ResourceRecordSet": {"Name":"'"${name}"'", "Type":"A", "TTL":'"${ttl}"', "ResourceRecords": [{"Value":"'"${ip}"'"}]}   }]}'
done
echo DNS entries deleted

echo Deleting any remaining compute node images
for image_id in $(aws ec2 describe-images --filters "Name=tag:cluster,Values=${CLUSTERID}" --query 'Images[].[ImageId]' --output=text)
do
  aws ec2 deregister-image --image-id "${image_id}"
done
echo Image deletion completed
