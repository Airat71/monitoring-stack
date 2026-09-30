# Production checklist (PRO)

Перед выводом стека в production и для аудита по лучшим практикам.

## Безопасность

- [ ] **Секреты:** все пароли и токены — в `.env` на сервере или в Ansible Vault; `.env` и `inventory.yml` с реальными IP не коммитить.
- [ ] **Binding:** Prometheus, Grafana, Alertmanager, Blackbox привязаны к `127.0.0.1`; доступ снаружи только через SSH-туннель или reverse proxy с HTTPS и аутентификацией.
- [ ] **Grafana:** дефолтный пароль сменён (`GRAFANA_PASSWORD`), sign-up отключён.
- [ ] **SSH:** на целевых хостах вход под непривилегированным пользователем (не root); ключи, не пароли.

## Надёжность и ресурсы

- [ ] **Healthchecks:** у всех сервисов в docker-compose заданы `healthcheck`; Grafana зависит от Prometheus по `condition: service_healthy`.
- [ ] **Ограничение памяти:** у контейнеров заданы `deploy.resources.limits.memory` (Prometheus, Grafana, Alertmanager, Node Exporter, Blackbox), чтобы один сервис не исчерпал память хоста.
- [ ] **Логи:** включён драйвер `json-file` с `max-size` и `max-file`, чтобы логи не заполняли диск.
- [ ] **Рестарт:** у всех сервисов `restart: unless-stopped`.

## Воспроизводимость и обновления

- [ ] **Образы:** в шаблоне используются зафиксированные теги (prometheus:v2.47.2, grafana:10.2.2, alertmanager:v0.26.0, node-exporter:v1.7.0, blackbox-exporter:v0.24.0). Обновления — явно, с тестированием.
- [ ] **Конфиги:** перед применением проверяются через `promtool check config` и `promtool check rules` в Ansible.

## Операции

- [ ] **Бэкапы:** настроены по BACKUP.md (Prometheus TSDB и/или конфиги, Grafana); ротация и тест восстановления.
- [ ] **Алерты:** Alertmanager настроен (Telegram и/или email); тестовое срабатывание проверено.
- [ ] **Мониторинг самого стека:** алерты InstanceDown, ServiceDown, PrometheusConfigReloadFailure включены; при необходимости — отдельный дашборд по здоровью Prometheus/Grafana.

## Документация и runbook

- [ ] **Операции:** OPERATIONS.md и RUNBOOK.md доступны команде; при срабатывании алерта есть шаги проверки и исправления (TROUBLESHOOTING.md).
- [ ] **Контакты:** в Alertmanager указаны корректные получатели; при смене владельца — обновить контакты и секреты.

---

После прохождения чеклиста стек считается готовым к production-нагрузке. Периодически повторять при изменении конфигурации или инфраструктуры.
