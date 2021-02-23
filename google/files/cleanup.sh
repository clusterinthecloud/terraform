#! /bin/bash

# This script is run on cluster destruction to shut down any remaining nodes
# and delete any lingering images

echo Terminating any remaining compute nodes
for instance in $(gcloud compute instances list --filter="labels.cluster=${CLUSTERID}" --format="table[no-heading](name)")
do
    gcloud compute instances delete "${instance}"
done
echo Node termination request completed

echo Deleting any remaining compute node images
for image in $(gcloud compute images list --filter="labels.cluster=${CLUSTERID}" --format="table[no-heading](name)")
do
    gcloud compute images delete "${image}"
done
echo Image deletion completed
