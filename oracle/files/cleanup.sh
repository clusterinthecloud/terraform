#! /bin/bash
set -euo pipefail

# This script is run on cluster destruction to shut down any remaining nodes
# and delete any lingering images

# The commands here return something like:
#   [
#     "ocid1....",
#     "ocid1...."
#   ]
# which we transform with head/tail/sed into:
#   ocid1....
#   ocid1....

echo Terminating any remaining compute nodes
for instance_id in $(oci compute instance list --compartment-id="${COMPARTMENT}" --query="data[?\"freeform-tags\".cluster==\`${CLUSTERID}\` && \"freeform-tags\".type==\`compute\`].id" | head -n-1 | tail -n+2 | sed 's/[ ",]//g')
do
  echo "Terminating instance ${instance_id}"
  oci compute instance terminate --instance-id ${instance_id} --force
done
echo Node termination request completed

echo Deleting any remaining compute node images
for image_id in $(oci compute image list --compartment-id="${COMPARTMENT}" --query="data[?\"freeform-tags\".cluster==\`${CLUSTERID}\`].id" | head -n-1 | tail -n+2 | sed 's/[ ",]//g')
do
  echo "Deleting image ${image_id}"
  oci compute image delete --image-id "${image_id}" --force
done
echo Image deletion completed
