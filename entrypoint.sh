#!/bin/sh
set -o errexit
set -o nounset

export PLANTON_CLOUD_SERVICE_CLI_ENV=${1}
export PLANTON_CLOUD_SERVICE_CLIENT_ID=${2}
export PLANTON_CLOUD_SERVICE_CLIENT_SECRET=${3}
export PLANTON_CLOUD_ARTIFACT_STORE_ID=${4}
export PLANTON_CLOUD_PRODUCT_ID=${5}
export PLANTON_CLOUD_ARTIFACT_STORE_MAVEN_REPO_URL=${6}
export MAVEN_PACKAGE_VERSION=${7}

if ! [ -n "${PLANTON_CLOUD_SERVICE_CLIENT_ID}" ]; then
  echo "PLANTON_CLOUD_SERVICE_CLIENT_ID is not set. Configure Machine Account Credentials for Repository or Organization."
  exit 1
fi
if ! [ -n "${PLANTON_CLOUD_SERVICE_CLIENT_SECRET}" ]; then
  echo "PLANTON_CLOUD_SERVICE_CLIENT_SECRET is not set. Configure Machine Account Credentials for Repository or Organization."
  exit 1
fi
if ! [ -n "${PLANTON_CLOUD_ARTIFACT_STORE_ID}" ]; then
  echo "PLANTON_CLOUD_ARTIFACT_STORE_ID is required. It should be set to the id of the artifact-store on planton cloud"
  exit 1
fi
if ! [ -n "${PLANTON_CLOUD_PRODUCT_ID}" ]; then
  echo "PLANTON_CLOUD_PRODUCT_ID is required. It should be set to the id of the product to which the code-project belongs to on planton cloud"
  exit 1
fi

if ! [ -n "${PLANTON_CLOUD_ARTIFACT_STORE_MAVEN_REPO_URL}" ]; then
  echo "PLANTON_CLOUD_ARTIFACT_STORE_MAVEN_REPO_URL is required. It should be set to the maven repository of the artifact-store on planton cloud"
  exit 1
fi

if ! [ -n "${MAVEN_PACKAGE_VERSION}" ]; then
  echo "MAVEN_PACKAGE_VERSION is required. It should be set to the semantic version of the maven package to be used for the release"
  exit 1
fi


#!/bin/bash
set -o errexit
set -o nounset

echo "exchanging planton-cloud machine-account credentials to get an access token"
planton auth machine login \
  --client-id $PLANTON_CLOUD_SERVICE_CLIENT_ID \
  --client-secret $PLANTON_CLOUD_SERVICE_CLIENT_SECRET
echo "successfully exchanged planton-cloud machine-account credentials and received an access token"
echo "fetching artifact writer key planton cloud service"
artifact_writer_key_json_file="$(pwd)/artifact-writer-key.json"
planton product artifact-store secrets get-writer-key \
  --output-file $artifact_writer_key_json_file \
  --artifact-store-id $PLANTON_CLOUD_ARTIFACT_STORE_ID
echo "fetched artifact writer key planton cloud service"
export GOOGLE_APPLICATION_CREDENTIALS=$artifact_writer_key_json_file
#https://stackoverflow.com/a/18124325
#converts product id to upper case and replaces hyphens with underscores
#planton-pcs -> PLANTON_PCS
transformed_product_id=$(echo ${PLANTON_CLOUD_PRODUCT_ID} | tr '[:lower:]' '[:upper:]' | tr - _)
export MAVEN_REPO_URL_$transformed_product_id=$PLANTON_CLOUD_ARTIFACT_STORE_MAVEN_REPO_URL
#consumer projects of this action are expected to have a Makefile in the root of the repository and also
# a target with name 'publish
echo "releasing version: $MAVEN_PACKAGE_VERSION"
make publish
