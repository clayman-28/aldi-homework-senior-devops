## Repository layout

- `app/` holds the application code and its tests.
- `Dockerfile` builds the container image in two stages.
- `helm/` holds the chart that deploys the application.
- `terraform/` creates the namespace and installs the chart.
- `.gitlab-ci.yml` defines the validate, test, build and deploy stages.
- `OVERVIEW.md` lists every change made to the original skeleton.

## Requirements

- Docker 24 or later
- Python 3.13
- Helm 3.16 or later
- Terraform 1.9 or later
- kind or another local Kubernetes cluster, only for the deployment steps

## API

The service listens on port 8080 and answers these requests.

- `GET /health` returns `{"status": "ok"}`.
- `GET /version` returns the value of the `APP_VERSION` variable, `1.0.0` by default.
- `GET /env` returns the value of the `ENVIRONMENT` variable, `dev` by default.
- `POST /config` stores a name and a value, and returns them with status 201.
- `GET /config/{name}` returns the stored entry, or status 404.
- `DELETE /config/{name}` removes the entry and returns `{"deleted": true}`, or status 404.

## Build and run the container

Run the build from the repository root, because the Dockerfile copies files from `app/`.

```bash
docker build -t myapp:0.1.0 .
docker run --rm -p 8080:8080 -e ENVIRONMENT=docker myapp:0.1.0
```

The image runs gunicorn as user 10001 and starts one worker process.

## Validate the Helm chart

```bash
helm lint helm/
helm template myapp helm/ | kubeconform -strict -summary
```

## Deploy to a local cluster

I tested the deployment on my own Kubernetes cluster in my homelab.
For this reason the repository contains no cluster definition, such as a kind
configuration file. The chart and the Terraform code work with any cluster that
your current kubectl context points at.

Install the chart.

```bash
helm upgrade --install myapp helm/ \
  --namespace homework --create-namespace \
  --set image.tag=0.1.0 \
  --set environment=dev
```

## Deploy with Terraform

Terraform creates the namespace and installs the same chart as a Helm release.
Terraform reads the cluster address from the kubeconfig file in `kubeconfig_path`.

```bash
cd terraform
terraform init
terraform plan -var="image_tag=0.1.0"
terraform apply -var="image_tag=0.1.0"
terraform output
```

## Pipeline

The pipeline runs four stages.

1. `validate` runs `ruff`, `helm lint`, `helm template`, `terraform fmt` and `terraform validate`.
2. `test` runs pytest.
3. `build` builds the image with kaniko, pushes it under the commit hash, and scans it with Trivy.
4. `deploy` runs `terraform apply` against the cluster.

## What I changed

See [OVERVIEW.md](OVERVIEW.md) for the list of fixes and improvements, with the reason for each one.

## Assumptions

- The service is a demonstration, so the configuration store does not need to survive a restart.
- It's configured to run on a local cluster such as minikube or local kubernetes cluster, no cloud provided.
- The GitLab instance provides its own container registry and a runner, even though I have one at home I did not wanted to include it.
- The hosting only works locally without TLS, but I'll get back to it later.

## Known limitations

- No configmap, no stateful data, if the container dies everything is lost.
- Two replicas answer with different data, because each pod holds its own store.
- The chart and the Terraform code were tested on a single node cluster in a homelab,
  and validated with `helm lint`, `helm template`, kubeconform and `terraform validate`.
- No cloud provider and no managed ingress controller were part of that test. (no MS Graph calls and resource creations)
- The pipeline was never executed, because it needs a GitLab runner, a registry and a cluster. (I just assume it works :))
- There is no ServiceAccount, no NetworkPolicy, no PodDisruptionBudget and no autoscaler. (usually it is decided with the deployment to communicate with other services and scaling under load)
- Security checks do not fail the pipeline

## Production improvements

- Store the configuration entries in a database, for example Postgres, and remove the single
  worker restriction. Replicas then serve the same data and the service scales horizontally.
- Move tf state file to a protected cloud storage, such as a blob.
- Split Terraform per environment with workspaces or separate directories and variable files.
- Add TLS and automate it with certgen service.
- Read secrets from a secret manager, for example Vault or the External Secrets Operator,
  instead of CI variables. I use vault at home and Azure Key Vault at enterprise.
- I would not use terraform to deploy apps in Kubernetes, ArgoCD or Helm would be better for this task. Terraform is good for deploying resources in cloud and VMs with configurations. For better management it highly recommended.
- No logging, no log collectors for the app. I would deploy a Grafana Alloy to  collect pod logs, and user prometheus and annotate the exporters in the deployment.
- Fail the pipeline on high and critical vulnerabilities once the base image is clean. Also not just Trivy, I would use Dependency Track as well to check the external libraries for zero day vulnurabilities.
