# aws-cloud-journey
# Building a VPC from Scratch

## What I built

TODO

## Architecture

TODO

## Design decisions

**Why /16 for the VPC:** TODO

**Why /24 for the subnets:** TODO

**Why the public subnet is public:** TODO

**Why the private subnet has no NAT gateway:** TODO

## Components

| Resource | Value | Purpose |
|---|---|---|
| VPC | 10.0.0.0/16 | TODO |
| Public subnet | 10.0.1.0/24, us-east-1a | TODO |
| Private subnet | 10.0.2.0/24, us-east-1a | TODO |
| Internet gateway | learning-igw | TODO |
| Public route table | 0.0.0.0/0 -> igw | TODO |
| Private route table | local only | TODO |

## Verification

TODO

## What I learned

TODO

## Cost

TODO