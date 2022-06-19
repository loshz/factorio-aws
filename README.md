# Factorio on AWS [![Build Status](https://github.com/loshz/factorio-aws/workflows/ci/badge.svg)](https://github.com/loshz/factorio-aws/actions)

Configure a [Headless Factorio Server](https://wiki.factorio.com/Multiplayer#Dedicated.2FHeadless_server) on AWS managed by Terraform.

## Usage

### AWS
Firstly, you'll need to [create an S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html) In order to store the Terraform state and optional configuration files.

You'll then need to create an IAM user with read/write access to the following services:
- EC2
- S3
- VPC

>**Note:** for better security, you should scope permissions to a single user with fixed resources. Follow the [IAM resource guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html) for best practices.

### Terraform
The following [input variables](https://www.terraform.io/language/values/variables) are configurable:

| Name | Type | Default | Description |
|---|---|---|---|
| s3_bucket | string || AWS S3 bucket name for storing state and other configs |
| region | string || AWS region in which all resources will be created |
| vpc_cidr | string | 172.16.0.0/16 | CIDR of the VPC |
| ec2_instance_type | string | t3.medium | AWS instance type of the EC2 VM |
| factorio_version | string | 1.1.59 | Factorio version |

Once all of the above has been configured, you can run the following commands:
```bash
$ cd ./factorio

# Initialize Terraform:
$ terraform init

# Generates an execution plan:
$ terraform plan

# Create the resources:
$ terraform apply
...
Apply complete! Resources: 12 added, 0 changed, 0 destroyed.
```

### Factorio
By default, the server will create a new save file and randomly generated map on startup. Optionally, you can configure these settings by uploading the following files to your S3 bucket and they'll be used by the server automatically.

To use a previous save, upload the zip file to:
```
s3://[bucket]/factorio/saves/factorio.zip
```

To configure server and map settings, upload the following files to:
```
s3://[bucket]/factorio/data/
```
- `map-gen-settings.json`: To set parameters used by the map generator such as width and height, ore patch frequency and size, etc.
- `map-settings.json`: To control pollution spread, biter expansion and evolution, and more.
- `server-settings.json`: To specify game visibility, timeouts, etc.

