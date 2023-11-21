# Factorio on AWS
[![Build Status](https://github.com/loshz/factorio-aws/workflows/ci/badge.svg)](https://github.com/loshz/factorio-aws/actions)

Configure a [Headless Factorio Server](https://wiki.factorio.com/Multiplayer#Dedicated.2FHeadless_server) on AWS managed by Terraform.

## Usage

### AWS
Firstly, you'll need to [create an S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html) In order to store the Terraform state and optional configuration files.

You'll then need to create an IAM user with read/write access to the following services:
- EC2
- IAM
- S3
- VPC

> **Note**: for better security, you should scope permissions to a single user with fixed resources. Follow the [IAM resource guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html) for best practices.

### Terraform

#### Config
The following [input variables](https://www.terraform.io/language/values/variables) are configurable:

| Name | Type | Default | Description |
|---|---|---|---|
| s3_bucket | string || AWS S3 bucket name for storing state and other configs |
| region | string || AWS region in which all resources will be created |
| vpc_cidr | string | 172.25.16.0/24 | CIDR of the VPC |
| ec2_instance_type | string | t3a.medium | AWS instance type of the EC2 VM |
| ec2_volume_size | number | 20 | Size (GiB) of the root EC2 volume |
| ingress_cidrs | list(string) | ["0.0.0.0/0"] | List of IPv4 CIDRs of the allowed ingress traffic |
| ingress_cidrs_ipv6 | list(string) | ["::/0"] | List of IPv6 CIDRs of the allowed ingress traffic |
| factorio_version | string | 1.1.94 | Factorio version |

#### Apply
Navigate to the `./terraform` directory and write your desired config values to a `terraform.tfvars` file. Proceed to run the following commands:
```bash
# Initialize backend variables
$ echo 'bucket = "[bucket]"
region = "[region]"' > backend.tfvars

# Initialize Terraform
$ terraform init -backend-config=backend.tfvars

# Create the resources
$ terraform apply
...
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.
```

### Factorio
By default, the server will create a new save file and randomly generated map on startup. Optionally, you can configure these settings by uploading the following files to your S3 bucket and they'll be used by the server automatically.

To use a previous save, upload the zip file to:
```
s3://[bucket]/factorio/saves/factorio.zip
```
> **Note**: the server will automatically backup save files to the above S3 bucket every 15mins. 

To configure server and map settings, upload the following files to:
```
s3://[bucket]/factorio/data/
```
- `map-gen-settings.json`: To set parameters used by the map generator such as width and height, ore patch frequency and size, etc.
- `map-settings.json`: To control pollution spread, biter expansion and evolution, and more.
- `server-settings.json`: To specify game visibility, timeouts, etc.

You can find examples of each file under the same directories in your local installation.

### Debugging
If you need access to the server, you can use the instance's [SSM agent](https://docs.aws.amazon.com/systems-manager/latest/userguide/prereqs-ssm-agent.html) to connect via the AWS CLI:
```bash
$ aws ssm start-session --target [instance_id]
```
