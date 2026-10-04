# Импорт дашбордов с Grafana.com

Чтобы в папке `grafana/provisioning/dashboards/json` появились готовые дашборды без ручного экспорта, можно скачать JSON по ID с Grafana.com.

## Рекомендованные ID (публичные)

| Dashboard | Grafana.com ID | Назначение |
|-----------|----------------|------------|
| Node Exporter Full | 1860 | Системные метрики (CPU, RAM, disk, network) |
| Prometheus 2.0 Overview | 3662 | Состояние Prometheus |
| Blackbox Exporter | 7587 | Результаты HTTP/ICMP проб |
| PostgreSQL Database | 9628 | Метрики PostgreSQL |
| Redis Dashboard | 11835 | Метрики Redis |
| RabbitMQ Overview | 10991 | Очереди RabbitMQ |
| Nginx | 12708 | Nginx stub_status / метрики |

fail2ban — искать по "fail2ban" на Grafana.com или использовать кастомный JSON из сообщества.

## Как скачать один дашборд

```bash
# Пример: Node Exporter Full (ID 1860), ревизия 33
curl -sL "https://grafana.com/api/dashboards/1860/revisions/33/download" -o node-exporter-full.json
# Положить в grafana/provisioning/dashboards/json/ и перезапустить Grafana (или подождать provisioning 30s)
```

Либо в Grafana UI: Dashboards → Import → ввести ID (1860) → Load → при необходимости поправить datasource → Import.

## Provisioning

После того как JSON лежит в `json/`, Grafana подхватывает его по конфигу provider (path: `/etc/grafana/provisioning/dashboards/json`). Перезапуск: `docker compose restart grafana`.
