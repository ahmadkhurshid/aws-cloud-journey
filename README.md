# AWS Cloud Journey

Infrastructure projects built while learning AWS, Terraform and containers. Each
folder is a self-contained project with its own README explaining what it does and
why it was built that way.

Everything is defined as code. Nothing here was clicked together in the console.

## Projects

| | Project | What it covers |
|---|---|---|
| 01 | [VPC from scratch](01-vpc-from-scratch) | VPC, subnets, internet gateway, route tables — built in the console to learn the model |
| 02 | [VPC as Terraform](02-vpc-terraform) | The same network rebuilt as code |
| 03 | [Three-tier app](03-three-tier-alb) | ALB, EC2 instances in private subnets, Terraform modules, remote state in S3 |
| 04 | [Containerised app](04-containerised-app) | A Python web app, a Dockerfile, and an image pushed to ECR |
| 05 | [ECS Fargate](05-ecs-fargate) | The full stack: VPC, ALB, health checks, IAM, and containers running on Fargate |

**Project 05 is the one to look at.** It is a complete containerised application —
network, load balancer, security groups, IAM role, task definition and service —
written from scratch rather than reusing the earlier modules.

## CI

[`.github/workflows/terraform.yml`](.github/workflows/terraform.yml) runs on every
push: `terraform fmt -check`, `terraform validate` and `terraform plan`.

It authenticates to AWS with **OpenID Connect** rather than stored access keys, so
there are no long-lived credentials in GitHub. The IAM role it assumes has
`ReadOnlyAccess`, since the pipeline only needs to plan.

## What is covered

**Networking** — VPC design and CIDR planning, public and private subnets across
Availability Zones, internet and NAT gateways, route tables, security groups, NACLs,
VPC endpoints.

**Terraform** — variables, outputs, modules, `count`, remote state in S3 with
locking, and the `fmt` / `validate` / `plan` / `apply` cycle.

**Containers** — Dockerfiles, images and containers, ECR, and ECS on Fargate with
task definitions, execution roles and services.

**Load balancing** — Application Load Balancers, target groups, health checks and
listeners, with security groups referencing each other rather than IP ranges.

**IAM** — roles, trust policies and least-privilege permissions.

## Cost

Every project is applied, verified and destroyed in the same session. Total spend
across all five is under one pound.

Load balancers and NAT gateways are the expensive parts of a small AWS setup, and
each project README notes where a cost trade-off was made.
