# Chicken and Egg problem of terraform state with S3 backend

A solution for managing the S3 backend bucket as Infrastructure as Code, using terraform

## Moving pieces

Note:- The transient `terraform` directories and lock files need to be cleaned up between
different steps

### init.sh

* Create an empty S3 bucket
* Introduce an explicit delay, as bucket creation takes a while to be read reliably
* Generate a `backend.tf` with the created S3 bucket as the backend bucket
* Initialize terraform
* Import the manually created S3 bucket to the initialized terraform module
  * An equivalent S3 resource in the terraform module should exist.
  This is what you will use to import the manually created S3 bucket in.

### destroy.sh

As the S3 backend bucket as managed by the terraform module, triggering a resource deletion
yields an error. This is because after deleting all resources, terraform wants to save the
state file, but the S3 bucket was deleted as part of the deletion process.

To overcome this issue, and have a reliable deletion, the terraform state backend can be modified
to `local` and the state can be managed locally to perform the deletion of resources.

* Initialize terraform
* Generate a `backend.tf` with local backend
* Run `terraform init -force-copy`
  * This tells terraform to migrate state from S3 to local
* A subsequent `terraform destroy` can then delete all AWS resources reliable and manage 
state locally for this deletion

## Alternatives

* [Cloud Posse's module to maintain terraform state S3 backend](https://github.com/cloudposse/terraform-aws-tfstate-backend)
