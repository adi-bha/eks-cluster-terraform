# backend.tf — remote state configuration

This file tells Terraform where to store its **state file** — its internal record of what infrastructure it created and what it currently looks like — instead of keeping that file only on your laptop.

## What this configures

- **S3 bucket** — stores the actual state file remotely, so it survives even if your laptop is wiped, and so it can eventually be shared if you ever work with others.
- **Locking** — prevents two `terraform apply` commands from running at the same time and corrupting the state file. Historically this required a separate DynamoDB table just for this purpose. As of Terraform 1.10, the S3 backend can lock natively using `use_lockfile = true`, writing a small lock file directly into the same S3 bucket — no second AWS service required.

## Fields
| Name | What it means in plain terms |
|---|---|
| `bucket` | The S3 bucket where the state file is stored (you create this once, manually, before running Terraform) |
| `key` | The "file path" inside that bucket for this specific environment's state |
| `region` | Which AWS region the bucket lives in |
| `encrypt` | Encrypts the state file at rest — worth always having on, since state files can contain sensitive values |
| `use_lockfile` | Enables native S3 locking, replacing the older DynamoDB-table-based approach |

## Notes
- This bucket must exist **before** this backend config will work — Terraform can't create the very bucket it needs in order to start tracking state. This is a one-time manual step (`aws s3 mb`) or a tiny separate bootstrap Terraform config with its own local state, run once.
- Using `use_lockfile = true` means you no longer need to provision or pay for a DynamoDB table just for locking — one less moving part to maintain, and one less thing that can silently drift out of sync with your state bucket.
- If you're switching from an older DynamoDB-based setup, note that the two mechanisms aren't automatically compatible — you can't have some `apply` runs locking via DynamoDB and others via the S3 lockfile. Pick one and stay consistent for a given bucket.

## How this compares to `eksctl create cluster`

No equivalent — `eksctl` doesn't use Terraform state at all. It tracks what it created via CloudFormation stacks (which AWS manages and stores for you automatically). This file exists purely because Terraform, being a general-purpose tool rather than an EKS-specific one, needs you to explicitly decide where its bookkeeping lives.