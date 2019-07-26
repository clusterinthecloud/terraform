# Place your oci_api_key.pem in this directory and run like:
# env TENANCY_OCID=ocid1.tenancy.oc1... USER_OCID=ocid1.user.oc1... FINGERPRINT=... COMPARTMENT_OCID=ocid1.compartment.oc1... make
# Can also set ANSIBLE_BRANCH if wanted

TF_VERSION := 0.11.13
TF_VARS := terraform.test.tfvars
TF_STATE := terraform.test.tfstate

all: check-tf-version test

terraform_${TF_VERSION}_linux_amd64.zip:
	wget --no-verbose https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip

terraform: terraform_${TF_VERSION}_linux_amd64.zip
	unzip -u terraform_${TF_VERSION}_linux_amd64.zip

check-tf-version: terraform
	./terraform version

azure-test.pub:
	ssh-keygen -N "" -f azure-test

test: azure-test.pub
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
	-echo -ne "Host mgmt\n\tIdentityFile azure-test\n\tStrictHostKeyChecking no\n\tHostname " > ssh-config
	-terraform show -no-color $(TF_STATE) | grep 'PublicIP' | awk '{print $$3}' >> ssh-config
	-cat ssh-config
	-mkdir --mode=700 ~/.ssh
	-ssh -F ssh-config opc@mgmt "while [ ! -f /mnt/shared/finalised/mgmt ] ; do sleep 2; done" ## wait for ansible
	-ssh -F ssh-config opc@mgmt "echo -ne 'VM.Standard2.1:\n  1: 1\n  2: 1\n  3: 1\n' > limits.yaml && finish"
	-ssh -F ssh-config opc@mgmt "sudo mkdir -p /mnt/shared/test && sudo chown opc /mnt/shared/test"
	-ssh -F ssh-config opc@mgmt 'echo -ne "#!/bin/bash\n\nsrun hostname\n" > test.slm'
	-ssh -F ssh-config opc@mgmt "sbatch --chdir=/mnt/shared/test --wait test.slm"
	-ssh -F ssh-config opc@mgmt "sacct -j 2 --format=NodeList%-100 -X --noheader | tr -d ' ' > expected"  # Get the node the job ran on
	-sleep 5  # Make sure that the filesystem has synchronised
	-scp -F ssh-config opc@mgmt:expected .
	-scp -F ssh-config opc@mgmt:/mnt/shared/test/slurm-2.out .
	./terraform destroy -var-file=$(TF_VARS) -state=$(TF_STATE) -auto-approve oracle-cloud-infrastructure
	diff -u slurm-2.out expected

clean:
	rm -f $(TF_VARS) $(TF_STATE) $(TF_STATE).backup ssh-config slurm-2.out expected terraform terraform_${TF_VERSION}_linux_amd64.zip azure-test azure-test.pub

.PHONY: test clean
