# Alertmanager — Telegram and Email (PRO)

- **Config:** `alertmanager.yml` in the monitoring directory (template in Ansible role).
- **Telegram:** Set `telegram_bot_token` and `telegram_chat_id` in group_vars (use Ansible Vault). Create a bot via @BotFather and get chat_id (e.g. from @userinfobot).
- **Email:** Add `email_configs` under a receiver with `to`, `smarthost`, `auth_username`, `auth_password` (from vault).
- **Routing:** By default, warning/critical go to Telegram; adjust `route.routes` and `receivers` as needed.

Example: `alerts/alertmanager.example.yml` in this repo.
