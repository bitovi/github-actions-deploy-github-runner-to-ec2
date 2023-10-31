# GitHub actions deploy GitHub runner to EC2
Deploys a GitHub runner to an EC2 instance. If the user-data.sh file doesn't suits your needs, you can import one.
We will install awscli and docker.

## Action Summary
This action deploys a GitHub runner to an AWS VM (EC2) using user-data file to execute the installation.

If you would like to deploy a backend app/service, check out our other actions:
| Action | Purpose |
| ------ | ------- |
| [Deploy Docker to EC2](https://github.com/marketplace/actions/deploy-docker-to-aws-ec2) | Deploys a repo with a Dockerized application to a virtual machine (EC2) on AWS |
| [Deploy React to GitHub Pages](https://github.com/marketplace/actions/deploy-react-to-github-pages) | Builds and deploys a React application to GitHub Pages. |
| [Deploy static site to AWS (S3/CDN/R53)](https://github.com/marketplace/actions/deploy-static-site-to-aws-s3-cdn-r53) | Hosts a static site in AWS S3 with CloudFront |
<br/>

**And more!**, check our [list of actions in the GitHub marketplace](https://github.com/marketplace?category=&type=actions&verification=&query=bitovi)

# Need help or have questions?
This project is supported by [Bitovi, A DevOps consultancy](https://www.bitovi.com/services/devops-consulting).
You can **get help or ask questions** on our:
- [Discord Community](https://discord.gg/J7ejFsZnJ4Z)

Or, you can hire us for training, consulting, or development. [Set up a free consultation](https://www.bitovi.com/services/devops-consulting).

## Prerequisites
- An [AWS account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/) and [Access Keys](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html)
- The following secrets should be added to your GitHub actions secrets:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`

## Example usage

Create a Github Action Workflow `.github/workflow/deploy-ghr.yaml` with the following to build on push to the `main` branch.

```yaml
name: Develop Github runner
on:
  push:
    branches: [ main ]

jobs:
  Deploy:
    runs-on: ubuntu-latest
    steps:
      - id: deploy
        uses: bitovi/github-actions-deploy-github-runner-to-ec2@v0.1.0
        with:
          aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID_DEVELOPMENT }}
          aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY_DEVELOPMENT }}
          aws_default_region: us-east-1
          additional_tags: '{\"key\":\"value\",\"key2\":\"value2\"}'

          aws_vpc_id: vpc-00000000000000000
          aws_vpc_subnet_id: subnet-00000000000000

          ec2_instance_type: t2.medium
          ec2_instance_public_ip: false
          ec2_additional_tags: '{\"key3\":\"value3\",\"key4\":\"value4\"}'
          
          repo_url: https://github.com/Your/Repo
          repo_access_token: ${{ secrets.RUNNER_TOKEN }}

          stack_destroy: false
          tf_state_bucket_destroy: true
```


## Customizing

### Inputs

The following inputs can be used as `steps.with` keys:

### Inputs
1. [GitHub Commons main inputs](#github-commons-main-inputs)
1. [GitHub Repo inputs](#github-repo-inputs)
1. [AWS Specific](#aws-specific)
1. [Stack Management](#stack-management)
1. [Secrets and Environment Variables](#secrets-and-environment-variables-inputs)
1. [EC2 inputs](#ec2-inputs)
1. [VPC inputs](#vpc-inputs)


#### **GitHub Commons main inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `checkout` | Boolean | Set to `false` if the code is already checked out. (Default is `true`). |
| `bitops_code_only` | Boolean | If `true`, will run only the generation phase of BitOps, where the Terraform and Ansible code is built. |
| `bitops_code_store` | Boolean | Store BitOps generated code as a GitHub artifact. |
<br/>

#### **GitHub Repo inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `repo_url` | String | URL of the repository the runner will connect to. |
| `repo_access_token` | String | Token to be used to connect to the repo. Go to Settings -> Actions -> Runner -> Add new self-hosted runner. |
<br/>

#### **AWS Specific**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_access_key_id` | String | AWS access key ID |
| `aws_secret_access_key` | String | AWS secret access key |
| `aws_session_token` | String | AWS session token |
| `aws_default_region` | String | AWS default region. Defaults to `us-east-1` |
| `aws_resource_identifier` | String | Set to override the AWS resource identifier for the deployment. Defaults to `${GITHUB_ORG_NAME}-${GITHUB_REPO_NAME}-${GITHUB_BRANCH_NAME}`. Use with destroy to destroy specific resources. |
| `additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to all provisioned resources.|
<br/>

#### **Stack management**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `tf_state_bucket` | String | AWS S3 bucket name to use for Terraform state. See [note](#s3-buckets-naming) | 
| `tf_state_file_name` | String | Change this to be anything you want to. Carefull to be consistent here. A missing file could trigger recreation, or stepping over destruction of non-defined objects. Defaults to `tf-state-aws`, `tf-state-ecr` or `tf-state-eks.` |
| `tf_state_file_name_append` | String | Appends a string to the tf-state-file. Setting this to `unique` will generate `tf-state-aws-unique`. (Can co-exist with `tf_state_file_name`) |
| `tf_state_bucket_destroy` | Boolean | Force purge and deletion of S3 bucket defined. Any file contained there will be destroyed. `tf_stack_destroy` must also be `true`. Default is `false`. |
| `stack_destroy` | Boolean | Set to `true` to destroy the stack. |
<br/>

#### **Secrets and Environment Variables Inputs**
| Name             | Type    | Description - Check note about [**environment variables**](#environment-variables). |
|------------------|---------|------------------------------------|
| `env_aws_secret` | String | Secret name to pull environment variables from AWS Secret Manager. |
| `env_repo` | String | `.env` file containing environment variables to be used with the app. Name defaults to `repo_env`. |
| `env_ghs` | String | `.env` file to be used with the app. This is the name of the [Github secret](https://docs.github.com/es/actions/security-guides/encrypted-secrets). |
| `env_ghv` | String | `.env` file to be used with the app. This is the name of the [Github variables](https://docs.github.com/en/actions/learn-github-actions/variables). |
<br/>

#### **EC2 Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `ec2_instance_profile` | String | The AWS IAM instance profile to use for the EC2 instance. Will create one if none provided with the name`${GITHUB_ORG_NAME}-${GITHUB_REPO_NAME}-${GITHUB_BRANCH_NAME}`. |
| `ec2_instance_type` | String | The AWS IAM instance type to use. Default is `t2.small`. See [this list](https://aws.amazon.com/ec2/instance-types/) for reference. |
| `ec2_ami_id` | String | AWS AMI ID. Will default to latest Ubuntu 22.04 server image (HVM). Accepts `ami-###` values. |
| `ec2_ami_update` | Boolean | Set this to `true` if you want to recreate the EC2 instance if there is a newer version of the AMI. Defaults to `false`.|
| `ec2_volume_size` | Integer | Define the volume size (in GiB) for the root volume on the AWS Instance. Defaults to `8`. | 
| `ec2_root_preserve` | Boolean | Set this to true to avoid deletion of root volume on termination. Defaults to `false`. | 
| `ec2_security_group_name` | String | The name of the EC2 security group. Defaults to `SG for ${aws_resource_identifier} - EC2`. |
| `ec2_create_keypair_sm` | Boolean | Generates and manage a secret manager entry that contains the public and private keys created for the ec2 instance. |
| `ec2_instance_public_ip` | Boolean | Add a public IP to the instance or not. (Not an Elastic IP). |
| `ec2_user_data_file` | String | Relative path in the repo for a user provided script to be executed with Terraform EC2 Instance creation. See [this note](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html#user-data-shell-scripts) |
| `ec2_user_data_replace_on_change`| Boolean | If `aws_ec2_user_data_file` file changes, instance will stop and start. Hence public IP will change. This will destroy and recreate the instance. Defaults to `true`. |
| `ec2_additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to ec2 provisioned resources.|
<br/>

#### **VPC Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_vpc_create` | Boolean | Define if a VPC should be created |
| `aws_vpc_name` | String | Define a name for the VPC. Defaults to `VPC for ${aws_resource_identifier}`. |
| `aws_vpc_cidr_block` | String | Define Base CIDR block which is divided into subnet CIDR blocks. Defaults to `10.0.0.0/16`. |
| `aws_vpc_public_subnets` | String | Comma separated list of public subnets. Defaults to `10.10.110.0/24`|
| `aws_vpc_private_subnets` | String | Comma separated list of private subnets. If no input, no private subnet will be created. Defaults to `<none>`. |
| `aws_vpc_availability_zones` | String | Comma separated list of availability zones. Defaults to `aws_default_region+<random>` value. If a list is defined, the first zone will be the one used for the EC2 instance. |
| `aws_vpc_id` | String | AWS VPC ID. Accepts `vpc-###` values. |
| `aws_vpc_subnet_id` | String | AWS VPC Subnet ID. If none provided, will pick one. (Ideal when there's only one) |
| `aws_vpc_additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to vpc provisioned resources.|
<br/>

### Note about AWS resource identifiers
Most resources will contain the tag `GITHUB_ORG-GITHUB_REPO-GITHUB_BRANCH` to make them unique. Because some AWS resources have a length limit, we shorten identifiers to a `60` characters max string.

We use the Kubernetes style for this. For example, `Kubernetes` -> `k(# of characters)s` -> `k8s`. And so you might see how compressions are made.

For some specific resources, we have a `32` characters limit. If the identifier length exceeds this number after compression, we remove the middle part and replace it with a hash made up of the string itself.

### S3 buckets naming
Bucket names can be made of up to 63 characters. If the length allows us to add `-tf-state`, we will do so. If not, a simple `-tf` will be added.


## Made with BitOps
[BitOps](https://bitops.sh) allows you to define Infrastructure-as-Code for multiple tools in a central place.  This action uses a BitOps [Operations Repository](https://bitops.sh/operations-repo-structure/) to set up the necessary Terraform and Ansible to create infrastructure and deploy to it.

## Contributing
We would love for you to contribute to [bitovi/github-actions-deploy-github-runner-to-ec2](https://github.com/bitovi/github-actions-deploy-github-runner-to-ec2).
Would you like to see additional features?  [Create an issue](https://github.com/bitovi/github-actions-deploy-github-runner-to-ec2/issues/new) or a [Pull Requests](https://github.com/bitovi/github-actions-deploy-github-runner-to-ec2/pulls). We love discussing solutions!

## License
The scripts and documentation in this project are released under the [MIT License](https://github.com/bitovi/github-actions-deploy-github-runner-to-ec2/blob/main/LICENSE).
