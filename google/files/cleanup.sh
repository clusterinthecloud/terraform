#! /bin/bash
set -euo pipefail

# This script is run on cluster destruction to shut down any remaining nodes
# and delete any lingering images

echo "Grabbing service account credentials for mgmt-sa-${CLUSTERID}@${PROJECT}.iam.gserviceaccount.com"
gcloud iam service-accounts keys create temp-citc-terraform-credentials.json --iam-account "mgmt-sa-${CLUSTERID}@${PROJECT}.iam.gserviceaccount.com"
mkdir temp_gcloud_dir
CLOUDSDK_CONFIG=temp_gcloud_dir gcloud auth activate-service-account --key-file=temp-citc-terraform-credentials.json
CLOUDSDK_CONFIG=temp_gcloud_dir gcloud config set project "${PROJECT}"
echo Terminating any remaining compute nodes
for name_zone in $(CLOUDSDK_CONFIG=temp_gcloud_dir gcloud compute instances list --filter="labels.cluster=${CLUSTERID} labels.type=compute" --format="csv[no-heading](name,zone)")
do
    name=$(echo "${name_zone}" | cut -d"," -f1)
    zone=$(echo "${name_zone}" | cut -d"," -f2)
    CLOUDSDK_CONFIG=temp_gcloud_dir gcloud compute instances delete --zone="${zone}" --quiet "${name}"
done
echo Node termination request completed

echo Deleting any remaining compute node images
for image in $(CLOUDSDK_CONFIG=temp_gcloud_dir gcloud compute images list --filter="labels.cluster=${CLUSTERID}" --format="table[no-heading](name)")
do
    CLOUDSDK_CONFIG=temp_gcloud_dir gcloud compute images delete --quiet "${image}"
done
echo Image deletion completed

rm -f temp-citc-terraform-credentials.json
rm -rf temp_gcloud_dir
