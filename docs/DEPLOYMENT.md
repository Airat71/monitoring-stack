# DEPLOYMENT — Full deployment process

1. **Prerequisites:** Ansible 2.9+, Docker and Docker Compose on the monitoring server; SSH access to all hosts.
2. **Inventory:** Copy `inventory.example.yml` to `inventory.yml` and set `ansible_host` for `monitoring_server` and `monitored_nodes`.
3. **Variables:** Copy `group_vars/all.yml.example` to `group_vars/all.yml`; set `include_*` flags and, in vault, secrets (Grafana password, Telegram token, SMTP).
4. **Run:** `ansible-playbook -i inventory.yml playbook.yml`.
5. **Verify:** Grafana http://&lt;server&gt;:3001 (via tunnel), Prometheus targets UP, Alertmanager receiving test alert.

See **../INSTALLATION_GUIDE.md** for step-by-step and **SECURITY.md** for binding and SSH tunnel.
