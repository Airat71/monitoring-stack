# Alertmanager — Telegram and Email

- **Docker Compose:** `prometheus-grafana/alertmanager.yml` starts with a single receiver and does not send messages. Replace it with `alerts/alertmanager.example.yml` after you set `bot_token` and a numeric `chat_id`.
- **Ansible:** set `telegram_bot_token` and numeric `telegram_chat_id` in Vault. If either is unset, the generated config does not include Telegram.
- **Email:** add `email_configs` under a receiver (`to`, `smarthost`, `auth_username`, `auth_password`).
- Create a bot via @BotFather. `chat_id` is a number and must not be 0. A quoted string fails config validation.

Example: `alerts/alertmanager.example.yml`.
