# Semaphore

- Semaphore is an interface that allows repetitive tasks to be automated across multiple VMs/hypervisors.

- Integrated tool to automate the infrastructure creation workflow more effectively.

## Decisions

- Specific use of Ansible instead of using bash scripts included with Semaphore tools, due to lack of full automation.

- Migration of Semaphore to K3s to keep infrastructure services on the same instance.

## Runbook

- The environment configuration is in [K3s](../../k3s/manifests/deployment/automation/semaphore.yaml).

## Useful commands

- Access to the execution environment:
```bash
  kubectl exec -it <pod-name> -n <namespace> -- bash
```

## Issues encountered

- A typo in SEMAPHORE_ACCESS_KEY_ENCRYPTION (or the variable being completely absent) does not crash the container — it silently generates a new key on each startup, making previously encrypted secrets unreadable (SSH keys, Variable Groups). Task Templates/Inventories are not encrypted, so they remain visible even though the secrets can no longer be decrypted.

- Because several parts have to work together, the configuration was a bit difficult.

  - There must be SSH connectivity to all machines that need to be automated.

  - Semaphore cannot create a connection to external nodes if the SSH key has a passphrase, apparently a limitation of the environment.

    - Found solution: removing the passphrase from the SSH key.

  - Migrating YAML environments can cause difficulties due to the encryption Semaphore applies to the data.

    - Found solution: re-enter the SSH keys in the Semaphore GUI so it would encrypt them again.

## Ansible

- I chose Ansible as the solution to automate repetitive tasks inside containers, VMs, and Proxmox nodes.

- I currently use Ansible to automatically update *apt* on containers, VMs, and nodes, and to install Docker Compose automatically.

- The Ansible playbooks are in [ansible](../../semaphore/ansible/playbooks/).

## Terraform

- I chose Terraform to automatically create VMs and containers with certain specifications such as CPU, RAM, and storage.

- The Terraform manifests are in [terraform](../../semaphore/terraform/).

### Useful commands

- Once inside the Terraform container, each new playbook generates a new template; neither the project nor the repository changes while the project remains the same, but the template always changes:
```bash
  cd /tmp/semaphore/project_3/repository_1_template_6/terraform/landingpage
```

- To get the Terraform output from that state: `terraform output -json` (or any variable inside Terraform).

### Issues encountered

- It cannot read files configured inside the server where Docker is running.

  - Found solution: creating secrets inside the Semaphore environment and referencing the variable inside main.tf.

- It needs privilege separation to be removed inside Proxmox; otherwise, it does not have permission to create a container.

- By default it saves its state in the /tmp/ directory of the container, so it does not persist across sessions.

  - Found solution: reference an explicit directory in main.tf to save the state persistently.