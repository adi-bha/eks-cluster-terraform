# eks-cluster module

This module builds the "brain" of Kubernetes — the control plane that decides where applications run — and the trust bridge that later lets individual applications get their own AWS permissions.

## What this module creates

- **An IAM identity for the control plane** — before AWS will let the control plane exist, it needs its own "ID card" describing what it's allowed to do.
- **The EKS control plane itself** — the managed brain of the cluster. AWS runs and maintains this for you; you just tell it which network to live in.
- **An OIDC provider** — this is a slightly technical but important piece. Kubernetes has its own internal system for identifying applications, separate from AWS's identity system. This resource is the formal "introduction" between the two systems, so that later, individual applications running inside Kubernetes can be trusted by AWS.

## Inputs
| Name | What it means in plain terms | Default |
|---|---|---|
| `cluster_name` | The name of your cluster | required |
| `kubernetes_version` | Which version of Kubernetes to run | `1.30` |
| `subnet_ids` | Which network sections (from the vpc module) the control plane lives in | required |
| `endpoint_public_access` | Whether you can reach the cluster's control panel from the public internet (e.g. from your laptop) | `true` |

## Outputs
- `cluster_name`, `cluster_endpoint`, `cluster_ca_data` — together, these are what let your laptop's `kubectl` command talk to the cluster
- `cluster_security_group_id` — a reference used by the node group module
- `oidc_provider_arn`, `oidc_provider_url` — handed directly to the `irsa` module later; this is the "trust bridge" reference

## Notes
- Creating the control plane takes roughly 10-15 minutes. This is completely normal — it's not stuck.
- `endpoint_public_access = true` is the easy option for learning (you can reach it from anywhere). A real company setup usually locks this down so only internal company networks can reach it.
- There is no cheaper tier for the control plane — AWS charges a flat rate for it existing at all, regardless of how small or idle it is. The only way to avoid the charge is to delete the cluster when you're not using it.

## How this compares to `eksctl create cluster`

`eksctl` bundles this entire module's job, plus the node group's job, into one command. Broken down:

| eksctl's internal step | This module's equivalent |
|---|---|
| Creates the cluster service role | `aws_iam_role.cluster` + policy attachment |
| Creates the EKS control plane itself | `aws_eks_cluster` |
| Automatically registers an OIDC provider (if you passed `--with-oidc`) | `data "tls_certificate"` + `aws_iam_openid_connect_provider` |

One notable difference: with `eksctl`, OIDC provider setup is **optional** and easy to forget (you must remember to pass `--with-oidc`, or run a separate `eksctl utils associate-iam-oidc-provider` command afterward). Here, it's a permanent, explicit part of the module — you can't create the cluster without also getting the trust bridge, which avoids a very common real-world mistake where people set up EKS and only realize months later that IRSA was never actually wired up.