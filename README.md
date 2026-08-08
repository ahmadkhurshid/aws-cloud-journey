# aws-cloud-journey
# Building a VPC from Scratch

## What I built

TODO

## Architecture

TODO

## Design decisions

**Why /16 for the VPC:** :  65,536 addresses. VPC CIDR can't be changed after creation, so sizing generously up front avoids being boxed in later. Unused private addresses cost nothing.

**Why /24 for the subnets:** TODO

**Why the public subnet is public:**  its route table sends 0.0.0.0/0 to the internet gateway. The IGW is attached at the VPC level, so it's the route — not the gateway — that makes a subnet public. The private subnet uses a table with only the local route, so traffic to the internet has nowhere to go.



**Why the private subnet has no NAT gateway:** : the workload there has no outbound internet needs, and a NAT gateway bills ~$32/month from the moment it exists. Its privacy comes from the route table having no 0.0.0.0/0 route — not from the absence of NAT.



## Components

| Resource | Value | Purpose |
|---|---|---|
| VPC | 10.0.0.0/16 | TODO |
| Public subnet | 10.0.1.0/24, us-east-1a | TODO |
| Private subnet | 10.0.2.0/24, us-east-1a | TODO |
| Internet gateway | learning-igw | TODO |
| Public route table | 0.0.0.0/0 -> igw | TODO |
| Private route table | local only | TODO |

