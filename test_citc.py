import io
import os
import re
import stat
import subprocess
import textwrap
from contextlib import contextmanager
from datetime import timedelta
from io import BytesIO
from pathlib import Path
from urllib.request import urlopen
from zipfile import ZipFile

import paramiko
import pytest
from fabric import Connection


@pytest.fixture(scope="module")
def ssh_key() -> str:
    key_filename = "test_ssh_key"
    if not Path(key_filename).exists():
        subprocess.run(["ssh-keygen", "-N", "", "-b", "4096", "-t", "rsa", "-f", key_filename], check=True)
    return key_filename


@pytest.fixture(scope="module")
def terraform() -> str:
    terraform_version = "0.12.28"
    if not Path("terraform").exists():
        resp = urlopen(f"https://releases.hashicorp.com/terraform/{terraform_version}/terraform_{terraform_version}_linux_amd64.zip")
        ZipFile(BytesIO(resp.read())).extract("terraform")
        os.chmod("terraform", stat.S_IRUSR | stat.S_IWUSR | stat.S_IXUSR)
    return "./terraform"


def config_file(provider, ssh_key) -> str:
    config_filename = f"terraform.{provider}.tfvars"
    with open(f"{provider}/terraform.tfvars.example") as f:
        config = f.read()

    config = {
        "oracle": oracle_config_file,
        "google": google_config_file,
        "aws": aws_config_file,
    }[provider](config, ssh_key)

    if "ANSIBLE_REPO" in os.environ:
        config = config + f'\nansible_repo = "{os.environ["ANSIBLE_REPO"]}"'
    if "ANSIBLE_BRANCH" in os.environ:
        config = config + f'\nansible_branch = "{os.environ["ANSIBLE_BRANCH"]}"'

    with open(config_filename, "w") as f:
        f.write(config)

    return config_filename


def oracle_config_file(config, ssh_key) -> str:
    config = config.replace("/home/user/.oci", ".")
    config = config.replace("ocid1.tenancy.oc1...", os.environ["TENANCY_OCID"])
    config = config.replace("ocid1.user.oc1...", os.environ["USER_OCID"])
    config = config.replace("11:22:33:44:55:66:77:88:99:00:aa:bb:cc:dd:ee:ff", os.environ["FINGERPRINT"])
    config = config.replace("ocid1.compartment.oc1...", os.environ["COMPARTMENT_OCID"])
    with open(f"{ssh_key}.pub") as pub_key:
        pub_key_text = pub_key.read().strip()
    config = config.replace("ssh_public_key = <<EOF", "ssh_public_key = <<EOF\n" + pub_key_text)
    config = config.replace('FilesystemAD = "1"', 'FilesystemAD = "2"')

    return config


def google_config_file(config, ssh_key) -> str:
    config = config.replace("europe-west4", os.environ["REGION"])
    config = config.replace("myproj-123456", os.environ["PROJECT"])
    config = config.replace("europe-west4-a", os.environ["ZONE"])
    config = config.replace("myproj-123456-01234567890a.json", os.environ["CREDENTIALS"])
    config = config.replace("~/.ssh/citc-google", ssh_key)
    config = config.replace("n1-standard-1", "n1-standard-1")
    with open(f"{ssh_key}.pub") as pub_key:
        pub_key_text = pub_key.read().strip()
    config = config.replace("admin_public_keys = <<EOF", "admin_public_keys = <<EOF\n" + pub_key_text)

    return config


def aws_config_file(config, ssh_key) -> str:
    config = config.replace("~/.ssh/aws-key", ssh_key)
    with open(f"{ssh_key}.pub") as pub_key:
        pub_key_text = pub_key.read().strip()
    config = config.replace("admin_public_keys = <<EOF", "admin_public_keys = <<EOF\n" + pub_key_text)
    return config


def create_cluster(terraform: str, provider: str, tf_vars: str, ssh_username: str, limits: str, ssh_key: str):
    tf_state = f"terraform.{provider}.tfstate"
    subprocess.run([terraform, "init", provider], check=True)
    subprocess.run([terraform, "plan", f"-var-file={tf_vars}", f"-state={tf_state}", provider], check=True)

    with terraform_apply(tf_vars, tf_state, provider, terraform):
        terraform_output = subprocess.run([terraform, "output", "-no-color", f"-state={tf_state}", "ManagementPublicIP"], capture_output=True)
        try:
            mgmt_ip = terraform_output.stdout.decode().strip()
        except subprocess.CalledProcessError as e:
            print("Failed to get mgmt IP:", e)
            print(terraform_output.stdout.decode())
            print(terraform_output.stderr.decode())
            raise
        pkey = paramiko.RSAKey.from_private_key_file(ssh_key)
        print(f"Connecting to {mgmt_ip} as {ssh_username}")
        c = Connection(mgmt_ip, user=ssh_username, connect_kwargs={"pkey": pkey})
        print(f" Waiting for Ansible to finalise")
        c.run("until ls /mnt/shared/finalised/mgmt* ; do sleep 2; done", timeout=timedelta(minutes=30).seconds, in_stream=False, hide=True)
        print(f" Waiting for DNS to propagate")
        c.run("until host $(basename /mnt/shared/finalised/mgmt*) &> /dev/null ; do sleep 2; done", timeout=timedelta(minutes=10).seconds, in_stream=False)
        print(f"Connecting to {mgmt_ip} as citc")
        c = Connection(mgmt_ip, user="citc", connect_kwargs={"pkey": pkey})
        print(f" Writing limits file")
        c.run(f"echo -ne '{limits}' > limits.yaml", in_stream=False)
        print(f" Finishing Slurm config")
        c.run("finish", timeout=timedelta(seconds=10).seconds, in_stream=False)
        print(f" Handing over to tests...")
        yield c


@pytest.fixture(scope="module", params=["oracle", "google", "aws"])
def cluster(request, ssh_key, terraform):
    tfvars = config_file(request.param, ssh_key)
    if request.param == "oracle":
        yield from create_cluster(
            terraform,
            provider="oracle",
            tf_vars=tfvars,
            ssh_username="opc",
            limits="VM.Standard2.1:\n  1: 1\n  2: 1\n  3: 1\n",
            ssh_key=ssh_key,
        )
    elif request.param == "google":
        yield from create_cluster(
            terraform,
            provider="google",
            tf_vars=tfvars,
            ssh_username="provisioner",
            limits="n1-standard-1: 1\n",
            ssh_key=ssh_key,
        )
    elif request.param == "aws":
        yield from create_cluster(
            terraform,
            provider="aws",
            tf_vars=tfvars,
            ssh_username="centos",
            limits="t3.micro: 1\n",
            ssh_key=ssh_key,
        )


@contextmanager
def terraform_apply(tf_vars, tf_state, provider, terraform):
    try:
        subprocess.run([terraform, "apply", f"-var-file={tf_vars}", f"-state={tf_state}", "-auto-approve", provider], check=True)
        yield
    finally:
        subprocess.run([terraform, "destroy", f"-var-file={tf_vars}", f"-state={tf_state}", "-auto-approve", provider], check=True)


def submit_job(connection: Connection, job_script: str) -> str:
    job_script = textwrap.dedent(job_script.lstrip())
    connection.put(io.StringIO(job_script), "test.slm")
    connection.sudo("mkdir -p --mode=777 /mnt/shared/test", in_stream=False)
    res = connection.run("sbatch --chdir=/mnt/shared/test --wait test.slm", timeout=timedelta(minutes=10).seconds, in_stream=False)
    job_id = res.stdout.split()[-1]
    return job_id


def get_nodelist(connection: Connection, job_id: str) -> str:
    return connection.run(f"sacct -j {job_id} --format=NodeList%-100 -X --noheader", in_stream=False).stdout.strip()


def read_file(connection: Connection, file: str) -> str:
    return connection.sudo(f"cat {file}", hide=True, in_stream=False).stdout


@pytest.mark.parametrize("provider", [
    "oracle",
    "google",
    "aws",
])
def test_validate(terraform, provider):
    subprocess.run([terraform, "init", provider], check=True)
    subprocess.run([terraform, "validate", provider], check=True)
    pass


def test_login(cluster):
    cluster.run("sleep 1", timeout=timedelta(seconds=5).seconds, in_stream=False)


def test_job(cluster):
    job_id = submit_job(cluster, """
    #!/bin/bash

    srun hostname
    """)
    expected = get_nodelist(cluster, job_id)
    cluster.run("sleep 5", in_stream=False)  # Make sure that the filesystem has synchronised
    output = read_file(cluster, f"/mnt/shared/test/slurm-{job_id}.out")
    assert expected == output.strip()


def test_create_user(cluster):
    cluster.sudo("/usr/local/sbin/add_user_ldap matt Matt Williams https://github.com/milliams.keys", timeout=timedelta(minutes=1).seconds, in_stream=False)
    cluster.run("getent passwd matt", in_stream=False)


@pytest.mark.skip
def test_mpi_job(cluster):
    code = r"""
    #include <mpi.h>
    #include <iostream>

    int main()
    {
            // Initialize the MPI environment
            MPI_Init(NULL, NULL);

            // Get the number of processes
            int world_size;
            MPI_Comm_size(MPI_COMM_WORLD, &world_size);

            // Get the rank of the process
            int world_rank;
            MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

            // Get the name of the processor
            char processor_name[MPI_MAX_PROCESSOR_NAME];
            int name_len;
            MPI_Get_processor_name(processor_name, &name_len);

            // Print off a hello world message
            std::cout << "Hello world from processor " << processor_name << ", rank " << world_rank << " out of " << world_size << " processors\n";

            // Finalize the MPI environment.
            MPI_Finalize();
    }
    """
    cluster.run(f"echo -ne '{code}' > hello-mpi.cpp", in_stream=False)
    cluster.run("CXX=/usr/lib64/openmpi3/bin/mpic++ make hello-mpi", in_stream=False)
    job_id = submit_job(cluster, """
    #! /bin/bash
    #SBATCH --job-name="mpi_test"
    #SBATCH --ntasks 2
    #SBATCH --cpus-per-task 1

    srun hello-mpi
    """)
    cluster.run("sleep 5", in_stream=False)  # Make sure that the filesystem has synchronised
    job_state = cluster.run(f"sacct -j {job_id} -X --format=State --noheader", in_stream=False).stdout.strip()
    assert "COMPLETED" == job_state


def test_ansible_finished(cluster):
    cluster.run("until sudo grep 'PLAY RECAP' /root/ansible-pull.log ; do sleep 2; done", timeout=timedelta(minutes=10).seconds, in_stream=False)
    output = read_file(cluster, "/root/ansible-pull.log")
    results = re.search(r"PLAY RECAP \**\n.*:\s*(.*)\n", output).groups()[0].split()
    results = {k: int(v) for k, v in (e.split("=") for e in results)}
    assert results["failed"] == 0, f"{results['failed']} Ansible tasks failed"
    assert results["unreachable"] == 0


def test_sosreport(cluster):
    ret = cluster.sudo("sosreport --only-plugins citc --batch", in_stream=False, hide=True)
    sosresport_file = re.search(r"/.*sosreport-.*\.tar\.gz", ret.stdout).group()
    assert sosresport_file
