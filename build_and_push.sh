#!/bin/bash

UPSTREAM_ORG=$1
REPO=$2
UPSTREAM_REPO=$UPSTREAM_ORG'/'$REPO
REGISTRY='https://registry-1.docker.io'

echo "\n **********Building images**********************"
sudo docker build manifest_a/ --tag=manifest_a
sudo docker build manifest_b/ --tag=manifest_b
sudo docker build manifest_c/ --tag=manifest_c
sudo docker build manifest_d/ --tag=manifest_d
sudo docker build manifest_e/ --tag=manifest_e

echo "\n **********Tagging Manifests********************"
sudo docker tag manifest_a $UPSTREAM_REPO:manifest_a
sudo docker tag manifest_b $UPSTREAM_REPO:manifest_b
sudo docker tag manifest_c $UPSTREAM_REPO:manifest_c
sudo docker tag manifest_d $UPSTREAM_REPO:manifest_d
sudo docker tag manifest_e $UPSTREAM_REPO:manifest_e

echo "\n **********Pushing to Registry******************"
sudo docker push $UPSTREAM_REPO

echo "\n **********Create and Push Manifest Lists*******"
sudo docker manifest create $UPSTREAM_REPO:ml_i $UPSTREAM_REPO:manifest_a $UPSTREAM_REPO:manifest_b
sudo docker manifest push $UPSTREAM_REPO:ml_i
sudo docker manifest create $UPSTREAM_REPO:ml_ii $UPSTREAM_REPO:manifest_c $UPSTREAM_REPO:manifest_d
sudo docker manifest push $UPSTREAM_REPO:ml_ii
sudo docker manifest create $UPSTREAM_REPO:ml_iii $UPSTREAM_REPO:manifest_a $UPSTREAM_REPO:manifest_c
sudo docker manifest push $UPSTREAM_REPO:ml_iii
sudo docker manifest create $UPSTREAM_REPO:ml_iv $UPSTREAM_REPO:manifest_c $UPSTREAM_REPO:manifest_e
sudo docker manifest push $UPSTREAM_REPO:ml_iv

echo "\n **********Sync Fixture to Pulp******************"
pulp-admin docker repo create --repo-id $REPO --upstream-name $UPSTREAM_REPO --feed $REGISTRY
pulp-admin docker repo sync run --repo-id $REPO

echo "\n **********Inspect Pulp Repo*********************"
python matchmaker.py $REPO --list
