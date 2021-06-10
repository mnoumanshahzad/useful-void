#!/bin/bash

set -ux

function main() {
  BUCKET_HEAD_STATUS=$(aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>&1) || true

  if grep 'Not Found' <<< ${BUCKET_HEAD_STATUS}; then
      aws s3api create-bucket --bucket ${BUCKET_NAME} --region ${AWS_REGION} --create-bucket-configuration LocationConstraint=${AWS_REGION}
      sleep 5
      create_tf_backend
      terraform init
      terraform import -var bucket_name=${BUCKET_NAME} aws_s3_bucket.tf_state ${BUCKET_NAME}
      if [ $? -ne 0 ]; then
        aws s3 rb "s3://${BUCKET_NAME}" --force
      fi

  elif grep 'Forbidden' <<< ${BUCKET_HEAD_STATUS}; then
      echo "Bucket exists but not owned by you"
      exit 1
  
  elif grep 'Bad Request' <<< ${BUCKET_HEAD_STATUS}; then
      echo "Bucket name specified is less than 3 or greater than 63 characters"
      exit 1
  
  else
      create_tf_backend
      terraform init
  fi

  echo "Terraform backend s3 bucket name: ${BUCKET_NAME}"
}

function create_tf_backend() {
  cat >backend.tf <<EOL
    terraform {
      backend "s3" {
        bucket = "${BUCKET_NAME}"
        key    = "${BUCKET_KEY}"
        region = "${AWS_REGION}"
      }
    }
EOL
}

main "$@"; exit