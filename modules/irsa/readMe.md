# irsa module

This is the module that hands out individual "permission badges" to specific applications running inside Kubernetes — rather than giving every application in the cluster the same blanket AWS access.

## What this module creates

- **One IAM role, scoped to one specific application** — this role can only be used by the exact Kubernetes application (technically, "ServiceAccount") you specify. No other application in the cluster can use it, even if it's running in the same cluster.

You create one instance of this module *per application* that needs to talk to AWS — for example, one for a load balancer controller, one for a logging agent, one for your own app if it needs to read from an S3 bucket.

## Inputs
| Name | What it means in plain terms |
|---|---|
| `role_name` | A name for this specific permission badge |
| `oidc_provider_arn` | The "trust bridge" reference, from the eks-cluster module |
| `oidc_provider_url` | Also from the eks-cluster module — used to build the exact trust condition |
| `namespace` | Which "folder" inside Kubernetes the application lives in |
| `service_account_name` | The exact application identity inside Kubernetes this badge belongs to |
| `policy_arns` | Which specific AWS permissions to grant (e.g. "can read this S3 bucket") |

## Outputs
- `role_arn` — you take this value and attach it to the application's identity inside Kubernetes (as an annotation), which is the final step that actually lets the application use this permission
- `role_name` — for reference

## Notes
- This module costs nothing to run — IAM roles themselves are free. It's purely about *precisely controlling who can do what*, not about renting any AWS infrastructure.
- Getting the `namespace` and `service_account_name` values exactly right matters a lot — a typo here doesn't cause an error at creation time; it just silently means the intended application will never be able to use this permission badge.

## How this compares to `eksctl create cluster`

`eksctl` does **not** do this automatically at all — `eksctl create cluster` only sets up the trust bridge (OIDC), if you remember to ask for it. Assigning individual permissions to individual applications is a separate step even in the `eksctl` world, usually done with a follow-up command:

| eksctl's approach | This module's equivalent |
|---|---|
| `eksctl create iamserviceaccount --name ... --namespace ... --attach-policy-arn ...` (a separate, manual command per application) | One instance of this `irsa` module per application |

This is really the heart of the whole project: in the ECS world, permissions-per-application (task roles) are simple and automatic. In the Kubernetes/EKS world, achieving the same "one application, one set of permissions" outcome requires deliberately building this trust-and-condition mechanism yourself — `eksctl` doesn't hide this complexity the way it hides networking or the control plane; it just gives you a slightly more convenient command to do it with.