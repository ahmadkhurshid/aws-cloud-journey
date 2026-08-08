# VPC as Code (Terraform)

A multi-AZ VPC on AWS, built entirely with Terraform. No console clicks.

## What this builds

| Resource | Value |
|---|---|
| VPC | `172.16.0.0/16` |
| Public subnet (1a) | `172.16.1.0/24` |
| Public subnet (1b) | `172.16.3.0/24` |
| Private subnet (1a) | `172.16.2.0/24` |
| Private subnet (1b) | `172.16.4.0/24` |
| Internet gateway | attached to the VPC |
| Public route table | `0.0.0.0/0` → internet gateway, associated with both public subnets |
| Private subnets | no route table — fall back to the VPC main table (`local` only) |

## Architecture

```
┌──────────── VPC  172.16.0.0/16 ─────────────┐
│                                             │
│  us-east-1a              us-east-1b         │
│  ┌──────────────┐        ┌──────────────┐   │
│  │ public       │        │ public       │   │
│  │ 172.16.1.0/24│        │ 172.16.3.0/24│   │
│  └──────┬───────┘        └──────┬───────┘   │
│         └────────┬───────────────┘          │
│           public route table                │
│           0.0.0.0/0 -> igw                  │
│                                             │
│  ┌──────────────┐        ┌──────────────┐   │
│  │ private      │        │ private      │   │
│  │ 172.16.2.0/24│        │ 172.16.4.0/24│   │
│  └──────────────┘        └──────────────┘   │
│           main route table (local only)     │
└─────────────────────┬───────────────────────┘
                      │
              internet gateway
                      │
                     🌍
```

## Design decisions

**Why /16 for the VPC:** TODO

**Why /24 for each subnet:** TODO

**Why two Availability Zones:** TODO

**Why both public subnets share one route table:** TODO

**Why the private subnets have no route table of their own:** TODO

## Usage

```bash
terraform init      # download the AWS provider
terraform plan      # preview changes, builds nothing
terraform apply     # create the infrastructure
terraform destroy   # remove everything
```

Requires AWS credentials configured via `aws configure`.

## Notes

- Everything here is free — VPCs, subnets, route tables and internet gateways
  carry no charge.
- State files are gitignored. Terraform state can contain secrets in plain text
  and must never be committed.
