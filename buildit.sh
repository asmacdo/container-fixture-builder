
UPSTREAM_ORG=$1
REPO=$2
UPSTREAM_REPO=$UPSTREAM_ORG'/'$REPO

echo "Building images**********************************************************"
sudo docker build manifest_a/ --tag=manifest_a
sudo docker build manifest_b/ --tag=manifest_b
sudo docker build manifest_c/ --tag=manifest_c
sudo docker build manifest_d/ --tag=manifest_d
sudo docker build manifest_e/ --tag=manifest_e

echo "Tagging manifests**********************************************************"
sudo docker tag manifest_a $UPSTREAM_REPO:manifest_a
sudo docker tag manifest_b $UPSTREAM_REPO:manifest_b
sudo docker tag manifest_c $UPSTREAM_REPO:manifest_c
sudo docker tag manifest_d $UPSTREAM_REPO:manifest_d
sudo docker tag manifest_e $UPSTREAM_REPO:manifest_e

echo "push to dockerhub**********************************************************"
sudo docker push $UPSTREAM_REPO

echo "create manifest lists"
sudo docker manifest create $UPSTREAM_REPO:ml_i $UPSTREAM_REPO:manifest_a $UPSTREAM_REPO:manifest_b
sudo docker manifest push $UPSTREAM_REPO:ml_i
sudo docker manifest create $UPSTREAM_REPO:ml_ii $UPSTREAM_REPO:manifest_c $UPSTREAM_REPO:manifest_d
sudo docker manifest push $UPSTREAM_REPO:ml_ii
sudo docker manifest create $UPSTREAM_REPO:ml_iii $UPSTREAM_REPO:manifest_a $UPSTREAM_REPO:manifest_c
sudo docker manifest push $UPSTREAM_REPO:ml_iii
sudo docker manifest create $UPSTREAM_REPO:ml_iv $UPSTREAM_REPO:manifest_c $UPSTREAM_REPO:manifest_e
sudo docker manifest push $UPSTREAM_REPO:ml_iv

echo "sync new repo to pulp"
pulp-admin docker repo create --repo-id $REPO --upstream-name $UPSTREAM_REPO --feed https://registry-1.docker.io
pulp-admin docker repo sync run --repo-id $REPO

echo "Inspect repo"
python matchmaker.py $REPO --list

#
# echo
# echo "==============================NOTES==========================================="
# echo
# echo "Resultant repo has 4 tags, 4 manifests, 5 blobs"
# echo
# echo "Manifests/Tags:"
# echo "----There are 2 tags/manifests for Schema 2"
# echo "----There are 2 tags/manifests for Schema 1"
# echo "Blobs:"
# echo "----In schema 2, each manifest has 1 config layer (blob)"
# echo "----In schema 2, each manifest has 1 fs_layer (blob)"
# echo "----Total of 4 blobs"
# echo "----In schema 1, each manifest has 2 fs_layers"
# echo "----The first layer of each schema 1 manifest is the base layer (scratch in this case)"
# echo "----Scratch digest: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4"
# echo
# echo "For bherring:"
# echo "----Schema 2 manifest_a and manifest_b are *independent*, they do not share blobs"
# echo "----Schema 1 manifest_a and manifest_b are *NOT independant*, they share 1 blob with each other"
# echo "----The blobs NOT shared by schema1 manifests ARE SHARED with schema 2 manifests"
