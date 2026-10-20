## What changed and why

<!-- One or two sentences. Link the issue if there is one: Fixes #123 -->

## How I checked it

<!-- Tick what applies. If you could not run something, say so. -->

- [ ] `docker compose -f prometheus-grafana/docker-compose.yml config -q` passes
- [ ] `promtool check config` passes (if I touched Prometheus config or alert rules)
- [ ] Ran the Ansible playbook twice on a test host, second run shows `changed=0` (if I touched Ansible)
- [ ] Followed the changed doc steps on a clean machine (if I touched docs)

Tested on: <!-- OS and version, Docker/Compose version, ansible-core version -->

## Before merging

- [ ] No secrets, IP addresses or passwords in the diff
- [ ] `CHANGELOG.md` updated under `[Unreleased]` (for anything a user would notice)
- [ ] README or docs updated if behaviour or requirements changed
