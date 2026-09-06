# Building a VPC from Scratch

The first project in this repository, and the only one built in the AWS console
rather than as code. The point was to understand the network model before
automating it — what each piece is, and which piece is actually responsible for
what.

Everything here was rebuilt as Terraform in [`02-vpc-terraform`](../02-vpc-terraform).

## What I built

A VPC with two subnets in one Availability Zone: one public, one private. An
internet gateway attached to the VPC, and two route tables — one sending
`0.0.0.0/0` to the internet gateway, one with only the local route.

No EC2 instances and no NAT gateway. The network itself was the exercise, and both
of those cost money without teaching anything the routing had not already shown.

**It was then deleted and rebuilt from scratch with a different CIDR range**
(`172.16.0.0/16` instead of `10.0.0.0/16`), unaided, to check that the first build
had produced understanding rather than a followed procedure.

## Architecture

```
                    Internet
                        |
                Internet Gateway
                        |
        ┌───────────────┴───────────────┐
        |                               |
  Public route table              Private route table
  0.0.0.0/0 -> IGW                local only
  local                                  |
        |                                |
  Public subnet                   Private subnet
  10.0.1.0/24                     10.0.2.0/24
  us-east-1a                      us-east-1a
```

The internet gateway is attached to the **VPC**, not to a subnet. Every subnet in
the VPC could use it — what decides whether a subnet actually can is its route
table.

## Design decisions

**Why /16 for the VPC:** 65,536 addresses. VPC CIDR can't be changed after
creation, so sizing generously up front avoids being boxed in later. Unused private
addresses cost nothing.

**Why /24 for the subnets:** 256 addresses each, of which AWS reserves five. Large
enough for any realistic workload at this size, small enough that a /16 leaves room
for hundreds of subnets. It also keeps the arithmetic readable — the third octet
becomes the subnet number, so `10.0.1.0/24` and `10.0.2.0/24` are obviously
different subnets at a glance.

**Why the public subnet is public:** its route table sends 0.0.0.0/0 to the internet
gateway. The IGW is attached at the VPC level, so it's the route — not the gateway —
that makes a subnet public. The private subnet uses a table with only the local
route, so traffic to the internet has nowhere to go.

**Why the private subnet has no NAT gateway:** the workload there has no outbound
internet needs, and a NAT gateway bills ~$32/month from the moment it exists. Its
privacy comes from the route table having no 0.0.0.0/0 route — not from the absence
of NAT.

**Why route tables are only consulted outbound:** a route table decides where a
packet goes when it *leaves* a subnet. Nothing is checked on arrival. This is why an
instance in a private subnet can receive a request from inside the VPC but cannot
reach the internet — traffic can always arrive, and the route table decides whether
you can answer.

## Components

| Resource | Value | Purpose |
|---|---|---|
| VPC | 10.0.0.0/16 | The private network everything else sits inside |
| Public subnet | 10.0.1.0/24, us-east-1a | Holds anything that must be reachable from the internet |
| Private subnet | 10.0.2.0/24, us-east-1a | Holds anything that must not be |
| Internet gateway | learning-igw | The door in the VPC wall; attached to the VPC, not a subnet |
| Public route table | 0.0.0.0/0 -> igw | The route that makes the public subnet public |
| Private route table | local only | No route out, so the subnet is private |

## What this project taught

The route table is the thing that matters. "Public" and "private" are not properties
of a subnet and not settings you tick — they are consequences of which route table a
subnet is associated with. The same subnet becomes private by changing one
association.

That distinction was worth the console time. Everything after this was built as
code.
