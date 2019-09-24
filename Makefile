# For Oracle:
# 	Place your oci_api_key.pem in this directory and run like:
# 	env TENANCY_OCID=ocid1.tenancy.oc1... USER_OCID=ocid1.user.oc1... FINGERPRINT=... COMPARTMENT_OCID=ocid1.compartment.oc1... make oracle-test
# For Google:
#   Download your service account credentials JSON file and place it in this directory and run like:
#	env REGION=europe-west4 PROJECT=myproj-123456 ZONE=europe-west4-a CREDENTIALS=myproj....json make google-test
# Can also set ANSIBLE_BRANCH if wantedf

TF_VERSION := 0.12.9
TF_VARS := terraform.test.tfvars
TF_STATE := terraform.test.tfstate

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

oracle-test: check-tf-version azure-test.pub oci_api_key.pem
	cp oracle-cloud-infrastructure/terraform.tfvars.example $(TF_VARS)
	sed -i -e '/private_key_path/ s/\/home\/user\/.oci/./' $(TF_VARS)
	sed -i -e "/tenancy_ocid/ s/ocid1.tenancy.oc1.../$(TENANCY_OCID)/" $(TF_VARS)
	sed -i -e "/user_ocid/ s/ocid1.user.oc1.../$(USER_OCID)/" $(TF_VARS)
	sed -i -e "/fingerprint/ s/11:22:33:44:55:66:77:88:99:00:aa:bb:cc:dd:ee:ff/$(FINGERPRINT)/" $(TF_VARS)
	sed -i -e "/compartment_ocid/ s/ocid1.compartment.oc1.../$(COMPARTMENT_OCID)/" $(TF_VARS)
	sed -i -e "/ssh_public_key/ r azure-test.pub" $(TF_VARS)
	sed -i -e "/FilesystemAD/ s/1/2/" $(TF_VARS)
	if [ "${ANSIBLE_BRANCH}" ]; then echo 'ansible_branch = "'$(ANSIBLE_BRANCH)'"' >> $(TF_VARS); fi
	cat $(TF_VARS)
	./terraform init oracle-cloud-infrastructure
	./terraform validate -var-file=$(TF_VARS) oracle-cloud-infrastructure
	./terraform plan -var-file=$(TF_VARS) -state=$(TF_STATE) oracle-cloud-infrastructure
	./terraform apply -var-file=$(TF_VARS) -state=$(TF_STATE) -auto-approve oracle-cloud-infrastructure
	# we need to ignore errors between here and the destroy, so make commands start with a minus
	-echo -ne "Host mgmt\n\tIdentityFile azure-test\n\tStrictHostKeyChecking no\n\tUser opc\n\tHostname " > ssh-config
	-./terraform output -no-color -state=$(TF_STATE) ManagementPublicIP >> ssh-config
	-cat ssh-config
	-mkdir --mode=700 ~/.ssh
	-ssh -F ssh-config mgmt "while [ ! -f /mnt/shared/finalised/mgmt ] ; do sleep 2; done" ## wait for ansible
	-ssh -F ssh-config mgmt "echo -ne 'VM.Standard2.1:\n  1: 1\n  2: 1\n  3: 1\n' > limits.yaml && finish"
	-ssh -F ssh-config mgmt "sudo mkdir -p --mode=777 /mnt/shared/test"
	-ssh -F ssh-config mgmt 'echo -ne "#!/bin/bash\n\nsrun hostname\n" > test.slm'
	-ssh -F ssh-config mgmt "sbatch --chdir=/mnt/shared/test --wait test.slm"
	-ssh -F ssh-config mgmt "sacct -j 2 --format=NodeList%-100 -X --noheader | tr -d ' ' > expected"  # Get the node the job ran on
	-sleep 5  # Make sure that the filesystem has synchronised
	-scp -F ssh-config mgmt:expected .
	-scp -F ssh-config mgmt:/mnt/shared/test/slurm-2.out .
	./terraform destroy -var-file=$(TF_VARS) -state=$(TF_STATE) -auto-approve oracle-cloud-infrastructure
	diff -u slurm-2.out expected

google-test: check-tf-version azure-test.pub $(CREDENTIALS)
	cp google-cloud-platform/terraform.tfvars.example $(TF_VARS)
	sed -i -e '/region/ s/europe-west4/$(REGION)/' $(TF_VARS)
	sed -i -e "/project/ s/myproj-123456/$(PROJECT)/" $(TF_VARS)
	sed -i -e "/zone/ s/europe-west4-a/$(ZONE)/" $(TF_VARS)
	sed -i -e "/credentials/ s/myproj-123456-01234567890a.json/$(CREDENTIALS)/" $(TF_VARS)
	sed -i -e "/private_key_path/ s/\/home\/user\/.ssh\/citc-google/azure-test/" $(TF_VARS)
	sed -i -e "/public_key_path/ s/\/home\/user\/.ssh\/citc-google/azure-test/" $(TF_VARS)
	sed -i -e "/management_shape/ s/n1-standard-1/n1-standard-1/" $(TF_VARS)
	if [ "${ANSIBLE_BRANCH}" ]; then echo 'ansible_branch = "'$(ANSIBLE_BRANCH)'"' >> $(TF_VARS); fi
	cat $(TF_VARS)
	./terraform init google-cloud-platform
	./terraform validate -var-file=$(TF_VARS) google-cloud-platform
	./terraform plan -var-file=$(TF_VARS) -state=$(TF_STATE) google-cloud-platform
	./terraform apply -var-file=$(TF_VARS) -state=$(TF_STATE) -auto-approve google-cloud-platform

	-echo -ne "Host mgmt\n\tIdentityFile azure-test\n\tStrictHostKeyChecking no\n\tUser provisioner\n\tHostname " > ssh-config
	-./terraform output -no-color -state=$(TF_STATE) ManagementPublicIP >> ssh-config
	-cat ssh-config
	-mkdir --mode=700 ~/.ssh
	-ssh -F ssh-config mgmt "while [ ! -f /mnt/shared/finalised/mgmt ] ; do sleep 2; done" ## wait for ansible
	-ssh -F ssh-config mgmt "echo -ne 'n1-standard-1: 1\n' > limits.yaml && finish"
	-ssh -F ssh-config mgmt "sudo mkdir -p --mode=777 /mnt/shared/test"
	-ssh -F ssh-config mgmt 'echo -ne "#!/bin/bash\n\nsrun hostname\n" > test.slm'
	-ssh -F ssh-config mgmt "sudo sbatch --chdir=/mnt/shared/test --wait test.slm"  # Run as root as it exists on all nodes
	-ssh -F ssh-config mgmt "sacct -j 2 --format=NodeList%-100 -X --noheader | tr -d ' ' > expected"  # Get the node the job ran on
	-sleep 5  # Make sure that the filesystem has synchronised
	-scp -F ssh-config mgmt:expected .
	-scp -F ssh-config mgmt:/mnt/shared/test/slurm-2.out .

	./terraform destroy -var-file=$(TF_VARS) -state=$(TF_STATE) -auto-approve google-cloud-platform
	diff -u slurm-2.out expected

clean:
	rm -f $(TF_VARS) $(TF_STATE) $(TF_STATE).backup ssh-config slurm-2.out expected terraform terraform_${TF_VERSION}_linux_amd64.zip azure-test azure-test.pub

.PHONY: test oracle-test google-test clean check-tf-version
