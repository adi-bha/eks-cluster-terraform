### `modules/vpc/README.md`

```markdown
# vpc module

This module builds the network that everything else in the cluster will live inside — think of it as laying down the land, roads, and gates before any buildings (servers, cluster, etc.) go up.

## What this module creates

- **A VPC** — a private, walled-off section of AWS just for this project. Nothing outside it can see in unless we explicitly allow it.
- **Public subnets** — sections of the network that are allowed to talk directly to the internet. Used for things like load balancers that the outside world needs to reach.
- **Private subnets** — sections that are hidden from the internet. This is where our actual worker computers (nodes) will live, since they don't need to be directly exposed.
- **An Internet Gateway (IGW)** — the "front door" that lets public subnets reach the internet.
- **A NAT Gateway** — a one-way door that lets private subnets *reach out* to the internet (e.g. to download software updates) without letting the internet reach *in*. We use a single shared NAT gateway instead of one per zone to keep costs down.
- **Route tables** — the "road signs" that tell traffic in each subnet where to go (out through the IGW, out through the NAT, or nowhere).

## Inputs
| Name | What it means in plain terms | Default |
|---|---|---|
| `name` | A label used to tag/name everything this module creates | required — you must provide it |
| `vpc_cidr` | The overall size/range of IP addresses this network owns | `10.0.0.0/16` |
| `azs` | Which physical AWS data center zones to spread across (for resilience) | Two zones in Mumbai |
| `public_subnet_cidrs` | Address ranges for the "internet-facing" sections | two small ranges |
| `private_subnet_cidrs` | Address ranges for the "hidden" sections | two small ranges |
| `single_nat_gateway` | Whether to use one shared exit-door (cheap) or one per zone (more resilient, costs more) | `true` (cheap) |

## Outputs
- `vpc_id` — the ID of the network itself
- `public_subnet_ids` — IDs of the internet-facing sections
- `private_subnet_ids` — IDs of the hidden sections, where our worker nodes will go
- `vpc_cidr` — the address range, for reference

## Notes
- The subnets are labeled with special tags (`kubernetes.io/...`) that don't do anything by themselves right now, but later let Kubernetes automatically figure out which subnets it's allowed to place load balancers into — without these tags, that auto-detection silently fails.
- Choosing `single_nat_gateway = true` means if that one zone has an outage, our private subnets briefly lose their "exit door" to the internet. For a learning project this is a fine trade-off to save money; a real production setup would usually pay double to have one exit-door per zone.

## How this compares to `eksctl create cluster`

When you previously ran `eksctl create cluster`, it silently did all of the above for you as part of its generated CloudFormation stack, before it ever touched Kubernetes itself. Specifically, this module is doing the exact same job as:

| eksctl's internal step | This module's equivalent |
|---|---|
| Creates the VPC stack (`eksctl-<cluster>-cluster/VPC`) | `aws_vpc` |
| Creates public + private subnets across AZs | `aws_subnet.public` / `aws_subnet.private` |
| Creates the Internet Gateway | `aws_internet_gateway` |
| Creates NAT Gateway(s) — by default **one per AZ** | `aws_nat_gateway` (we default to one shared, to save cost — eksctl's default is more expensive) |
| Creates route tables and associates them to subnets | `aws_route_table` + `aws_route_table_association` |
| Tags subnets for Kubernetes/ELB auto-discovery | Tags in `aws_subnet.public` / `aws_subnet.private` |

Nothing here touches Kubernetes or EKS yet — this module only builds the land, not the cluster. That comes next, in the `eks-cluster` module.
```