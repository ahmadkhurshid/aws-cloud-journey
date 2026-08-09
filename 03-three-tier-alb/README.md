# Highly Available Web Application (Terraform)

A load-balanced web application on AWS across two Availability Zones. The web
servers have **no public IP address and no route to the internet** — they are
reachable only through the load balancer.

Built entirely with Terraform. 19 resources, one command, about 90 seconds.

## Architecture

```
                         Internet
                             │
                    ┌────────┴────────┐
                    │ Internet Gateway│
                    └────────┬────────┘
┌────────────────────────────┼────────────────────────────┐
│  VPC  172.16.0.0/16        │                            │
│                            ▼                            │
│   ┌─── PUBLIC SUBNETS ──────────────────────────────┐   │
│   │  172.16.1.0/24 (1a)      172.16.3.0/24 (1b)     │   │
│   │           Application Load Balancer             │   │
│   │        listener :80 → target group              │   │
│   └────────────────────┬────────────────────────────┘   │
│                        │  local route, stays in the VPC │
│   ┌─── PRIVATE SUBNETS ▼────────────────────────────┐   │
│   │  172.16.2.0/24 (1a)      172.16.4.0/24 (1b)     │   │
│   │   web server 1a           web server 1b         │   │
│   │   no public IP            no public IP          │   │
│   └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Design decisions

**Why the web servers are in private subnets.** They have no public IP, so there is
no address on the internet that resolves to them, and their route table has no
`0.0.0.0/0` entry, so there is no path in. They are not merely firewalled — they are
unaddressable. The only exposed component is the load balancer.

**Why the security group references another security group.** `tf-web-sg` allows
port 80 from `tf-alb-sg`, not from an IP range. An ALB's node addresses change
whenever AWS scales or replaces capacity, so an IP-based rule would silently break
and produce intermittent failures. Group membership is stable; addresses are not.

**Why two Availability Zones.** An AZ is a physically separate datacenter. A public
and a private subnet in each means that if one AZ fails entirely, the remaining one
still has both a way in and somewhere to run. Subnets split across AZs without a
full pair in each would double the failure surface rather than halve it.

**Why there is no NAT gateway.** The instances need no outbound internet access, so
they get none — the private subnets have no `0.0.0.0/0` route at all. The startup
script uses Python's built-in HTTP server rather than installing anything. A NAT
gateway would cost roughly £25/month for capability this workload does not need.

**Why the health check matters.** The target group requests `/` from each instance
every 30 seconds. Two consecutive failures remove an instance from rotation; two
successes return it. This is the failover mechanism — defined in six lines.

## Resources created

| Resource | Count |
|---|---|
| VPC | 1 |
| Subnets (2 public, 3 private, across 2 AZs) | 5 |
| Internet gateway | 1 |
| Route table + associations | 3 |
| Security groups | 2 |
| EC2 instances (t3.micro, private subnets) | 2 |
| Application load balancer | 1 |
| Target group + attachments | 3 |
| HTTP listener | 1 |

`data.aws_ami.al2023` looks up the latest Amazon Linux image at plan time, so no
AMI ID is hard-coded.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

The `alb_url` output prints the public URL. Allow two to three minutes after apply
for the health checks to pass, then open it — the page names the server that
answered, and refreshing alternates between them.

```bash
terraform destroy
```

## Cost

The load balancer and instances bill hourly, roughly £0.04/hour for the whole
stack. The VPC, subnets, gateway and route tables are free. `terraform destroy`
removes everything billable.

## Notes

State files are gitignored — Terraform state can contain secrets in plain text and
must never be committed.
