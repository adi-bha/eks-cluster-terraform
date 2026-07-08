# eks-node-group module

This module creates the actual "workforce" — the computers that will run your applications. The control plane (from the eks-cluster module) is just the brain; it needs real servers to assign work to.

## What this module creates

- **An IAM identity for the worker nodes** — an ID card for the EC2 instances themselves, giving them exactly the permissions needed to join the cluster, handle networking, and pull container images.
- **A managed node group** — a group of EC2 servers, automatically created, scaled, and registered with the cluster.

## Inputs
| Name | What it means in plain terms | Default |
|---|---|---|
| `cluster_name` | Which cluster these servers join | required |
| `subnet_ids` | Where the servers physically live (should be private subnets) | required |
| `instance_types` | The size/type of server to use | `t3.small` |
| `capacity_type` | Whether to use cheaper "leftover capacity" servers or guaranteed full-price ones | `SPOT` (cheap) |
| `desired_size` / `min_size` / `max_size` | How many servers to run, and the min/max it can scale to | 1 / 1 / 2 |

## Outputs
- `node_group_arn` — reference ID for this group of servers
- `node_role_arn` — the ID card these servers use
- `node_group_status` — tells you if the servers successfully joined and are healthy

## Notes
- **SPOT vs ON_DEMAND**: `SPOT` capacity is AWS's spare, unused server capacity, sold at a steep discount (often ~70% cheaper). The catch is AWS can reclaim it with only 2 minutes' notice if it needs that capacity back. For a learning cluster, this is a great trade-off. For anything running real, important workloads, you'd use `ON_DEMAND` instead, which guarantees the server stays yours.
- `t3.small` is a genuinely small server — enough to prove the cluster works, but tight on memory once Kubernetes' own background processes are running. If pods start getting evicted or failing to schedule, that's your sign to bump up to `t3.medium`.
- Once these servers register, the module automatically updates the cluster's internal "permission list" so Kubernetes recognizes them — this used to be a manual, easy-to-forget step in older tooling.

## How this compares to `eksctl create cluster`

| eksctl's internal step | This module's equivalent |
|---|---|
| Creates the node instance IAM role | `aws_iam_role.node` + 3 policy attachments |
| Creates an Auto Scaling Group + launch template for worker servers | `aws_eks_node_group` (handles this internally) |
| Registers the node role in the cluster's internal `aws-auth` permission map | Handled automatically by `aws_eks_node_group` |

The one thing worth knowing: in older Terraform/AWS provider versions, that last step (`aws-auth` registration) had to be done manually via a separate Kubernetes resource — a common gotcha where nodes would launch successfully in EC2 but never actually appear when you ran `kubectl get nodes`. Recent versions of the `aws_eks_node_group` resource handle this for you, closing that gap.