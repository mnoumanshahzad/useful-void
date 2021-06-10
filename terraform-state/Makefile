.ONESHELL:
.EXPORT_ALL_VARIABLES:

BUCKET_NAME ?= 482672549281-tf-state
BUCKET_KEY ?= my_state.tfstate
AWS_REGION ?= eu-central-1

tf-apply: 
	@./init.sh
	@terraform apply -var bucket_name=${BUCKET_NAME}

tf-destroy: clean
	@./destroy.sh
	@terraform destroy -var bucket_name=${BUCKET_NAME}

clean:
	@rm -rf .terraform*
	@rm -rf errored.tfstate

clean_all: clean
	@rm backend.tf
