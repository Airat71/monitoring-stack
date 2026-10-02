# Contributing

Contributions are welcome.

## Bug reports and feature requests

Open a [GitHub Issue](https://github.com/Airat71/monitoring-stack/issues).

## Pull requests

- For small fixes (docs, typos, config corrections) — open a PR directly.
- For larger changes (new dashboards, new Ansible roles, new alert rules) — open an Issue first to discuss.

## What's in scope

- Grafana dashboards
- Prometheus alert rules
- Ansible roles and playbooks
- Documentation improvements
- Bug fixes

## Code style

- YAML: 2-space indentation
- Shell scripts: pass ShellCheck (CI enforces this)
- Ansible: idempotent tasks, no hardcoded IPs or passwords

## CI pipeline

Every pull request runs two independent workflows:

| Workflow | File | Triggers | Purpose |
|----------|------|----------|---------|
| **Security** | `security.yml` | all pushes + PRs | TruffleHog full-history secrets scan |
| **CI** | `ci.yml` | pushes/PRs (skips docs-only) | Docker Compose validation, Prometheus config, YAML lint, ShellCheck |

The security scan has no `paths-ignore` — it runs on every change without exception.

**To pass CI locally before pushing:**

```bash
# Validate Docker Compose config
docker compose -f prometheus-grafana/docker-compose.yml config -q

# Validate Prometheus config and alert rules
docker run --rm -v "$(pwd)/prometheus-grafana/prometheus:/prometheus" \
  --entrypoint promtool prom/prometheus:latest \
  check config /prometheus/prometheus.yml

# YAML lint (Ansible)
cd ansible && yamllint .

# ShellCheck
shellcheck scripts/*.sh
```

All contributions are licensed under [MIT](LICENSE.md).
