# For Oracle:
# 	Place your oci_api_key.pem in this directory and run like:
# 	env TENANCY_OCID=ocid1.tenancy.oc1... USER_OCID=ocid1.user.oc1... FINGERPRINT=... COMPARTMENT_OCID=ocid1.compartment.oc1... make oracle-test
# For Google:
#   Download your service account credentials JSON file and place it in this directory and run like:
#	env REGION=europe-west4 PROJECT=myproj-123456 ZONE=europe-west4-a CREDENTIALS=myproj....json make google-test
# Can also set ANSIBLE_BRANCH if wanted

TF_VERSION := 0.14.7
TF_VARS := terraform.*.tfvars
TF_STATE := terraform.*.tfstate

all: test

terraform_${TF_VERSION}_linux_amd64.zip:
	wget --no-verbose https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip

terraform: terraform_${TF_VERSION}_linux_amd64.zip
	unzip -u terraform_${TF_VERSION}_linux_amd64.zip

check-tf-version: terraform
	./terraform version

azure-test.pub:
	ssh-keygen -N "" -f azure-test

test: oracle-test google-test

validate-oracle: check-tf-version
	./terraform init -upgrade oracle
	./terraform validate oracle

oracle-config: validate-oracle


oracle-test: check-tf-version azure-test.pub oci_api_key.pem oracle-config


validate-google: check-tf-version
	./terraform init -upgrade  google
	./terraform validate google

google-config: validate-google


google-test: check-tf-version azure-test.pub $(CREDENTIALS) google-config


clean:
	rm -f $(TF_VARS) $(TF_STATE) $(TF_STATE).backup terraform terraform_${TF_VERSION}_linux_amd64.zip

.PHONY: test validate-oracle oracle-config oracle-test validate-google google-config google-test clean check-tf-version
