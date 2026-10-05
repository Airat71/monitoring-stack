#!/usr/bin/env python3
"""Write the eight dashboards shipped in grafana-dashboards/json/.

These files are original to this repository. Edit this script, then run it
from the repository root. Do not replace the output with downloads from
grafana.com.
"""

from __future__ import annotations

import json
from pathlib import Path

DS = {"type": "prometheus", "uid": "prometheus"}
OUT = Path(__file__).resolve().parent.parent / "grafana-dashboards" / "json"

ALLOWED_TYPES = {"gauge", "stat", "timeseries", "row"}


def target(expr: str, legend: str, ref: str = "A") -> dict:
    return {
        "datasource": DS,
        "editorMode": "code",
        "expr": expr,
        "legendFormat": legend,
        "refId": ref,
    }


def thresholds(steps: list[tuple[str, float | None]]) -> dict:
    return {
        "mode": "absolute",
        "steps": [{"color": color, "value": value} for color, value in steps],
    }


def variable(name: str, label: str, query: str) -> dict:
    return {
        "allValue": ".*",
        "current": {"selected": True, "text": "All", "value": "$__all"},
        "datasource": DS,
        "definition": query,
        "hide": 0,
        "includeAll": True,
        "label": label,
        "multi": True,
        "name": name,
        "options": [],
        "query": {"query": query, "refId": "StandardVariableQuery"},
        "refresh": 2,
        "regex": "",
        "sort": 1,
        "type": "query",
    }


def gauge(panel_id: int, title: str, expr: str, grid: dict, unit: str, steps: list, description: str) -> dict:
    return {
        "datasource": DS,
        "description": description,
        "fieldConfig": {
            "defaults": {
                "color": {"mode": "thresholds"},
                "max": 100 if unit == "percent" else 2 if unit == "none" else None,
                "min": 0,
                "thresholds": thresholds(steps),
                "unit": unit,
            },
            "overrides": [],
        },
        "gridPos": grid,
        "id": panel_id,
        "options": {
            "orientation": "auto",
            "reduceOptions": {"calcs": ["lastNotNull"], "fields": "", "values": False},
            "showThresholdLabels": False,
            "showThresholdMarkers": True,
        },
        "targets": [target(expr, "{{instance}}")],
        "title": title,
        "type": "gauge",
    }


def stat(panel_id: int, title: str, expr: str, grid: dict, unit: str, steps: list, description: str) -> dict:
    return {
        "datasource": DS,
        "description": description,
        "fieldConfig": {
            "defaults": {
                "color": {"mode": "thresholds"},
                "thresholds": thresholds(steps),
                "unit": unit,
            },
            "overrides": [],
        },
        "gridPos": grid,
        "id": panel_id,
        "options": {
            "colorMode": "value",
            "graphMode": "none",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {"calcs": ["lastNotNull"], "fields": "", "values": False},
            "textMode": "auto",
        },
        "targets": [target(expr, "{{instance}}")],
        "title": title,
        "type": "stat",
    }


def timeseries(
    panel_id: int,
    title: str,
    queries: list[tuple[str, str]],
    grid: dict,
    unit: str,
    description: str,
) -> dict:
    return {
        "datasource": DS,
        "description": description,
        "fieldConfig": {
            "defaults": {
                "color": {"mode": "palette-classic"},
                "custom": {
                    "axisBorderShow": False,
                    "axisCenteredZero": False,
                    "drawStyle": "line",
                    "fillOpacity": 15,
                    "lineInterpolation": "linear",
                    "lineWidth": 1,
                    "pointSize": 5,
                    "showPoints": "never",
                    "spanNulls": False,
                    "stacking": {"group": "A", "mode": "none"},
                },
                "thresholds": thresholds([("green", None)]),
                "unit": unit,
            },
            "overrides": [],
        },
        "gridPos": grid,
        "id": panel_id,
        "options": {
            "legend": {"calcs": ["mean", "max"], "displayMode": "list", "placement": "bottom"},
            "tooltip": {"mode": "multi", "sort": "desc"},
        },
        "targets": [target(expr, legend, ref=chr(ord("A") + i)) for i, (expr, legend) in enumerate(queries)],
        "title": title,
        "type": "timeseries",
    }


def dashboard(
    uid: str,
    title: str,
    description: str,
    tags: list[str],
    panels: list[dict],
    job_metric: str,
    var_label: str = "Instance",
) -> dict:
    job_query = f"label_values({job_metric}, job)"
    inst_query = f'label_values({job_metric}{{job=~"$job"}}, instance)'
    return {
        "annotations": {"list": []},
        "description": description,
        "editable": False,
        "fiscalYearStartMonth": 0,
        "graphTooltip": 1,
        "id": None,
        "links": [],
        "panels": panels,
        "refresh": "30s",
        "schemaVersion": 39,
        "tags": tags,
        "templating": {"list": [
            variable("job", "Job", job_query),
            variable("instance", var_label, inst_query),
        ]},
        "time": {"from": "now-6h", "to": "now"},
        "timepicker": {},
        "timezone": "browser",
        "title": title,
        "uid": uid,
        "version": 1,
    }


CPU_STEPS = [("green", None), ("yellow", 80), ("red", 95)]
MEM_STEPS = [("green", None), ("yellow", 85), ("red", 95)]
DISK_STEPS = [("green", None), ("yellow", 80), ("red", 90)]
LOAD_STEPS = [("green", None), ("red", 1.5)]
UP = [("red", None), ("green", 1)]
JOB = 'job=~"$job"'
INST = 'instance=~"$instance"'


def host_panels() -> list[dict]:
    sel = f"{JOB},{INST}"
    cpu = f'100 - (avg by(instance) (rate(node_cpu_seconds_total{{mode="idle",{sel}}}[5m])) * 100)'
    mem = f"(1 - (node_memory_MemAvailable_bytes{{{sel}}} / node_memory_MemTotal_bytes{{{sel}}})) * 100"
    disk = (
        "(1 - (node_filesystem_avail_bytes"
        f'{{mountpoint="/",fstype!~"tmpfs|devtmpfs|overlay",{sel}}} / '
        "node_filesystem_size_bytes"
        f'{{mountpoint="/",fstype!~"tmpfs|devtmpfs|overlay",{sel}}})) * 100'
    )
    load = (
        f"node_load1{{{sel}}} / on(instance) group_left() "
        f"count by(instance) (node_cpu_seconds_total{{mode=\"idle\",{sel}}})"
    )
    return [
        gauge(1, "CPU", cpu, {"h": 6, "w": 6, "x": 0, "y": 0}, "percent", CPU_STEPS, "Matches HighCPUUsage at 80% and HighCPUUsageCritical at 95%."),
        gauge(2, "Memory", mem, {"h": 6, "w": 6, "x": 6, "y": 0}, "percent", MEM_STEPS, "Matches alert HighMemoryUsage at 85%."),
        gauge(3, "Root filesystem", disk, {"h": 6, "w": 6, "x": 12, "y": 0}, "percent", DISK_STEPS, "Matches DiskSpaceLow at 80% and DiskSpaceCritical at 90%. Mountpoint is /."),
        gauge(4, "Load per CPU", load, {"h": 6, "w": 6, "x": 18, "y": 0}, "none", LOAD_STEPS, "Matches alert HighLoadAverage at 1.5. Extra target labels are ignored so the series still match."),
        timeseries(
            5,
            "CPU by mode",
            [(
                f'avg by(instance, mode) (rate(node_cpu_seconds_total{{mode!="idle",{sel}}}[5m])) * 100',
                "{{instance}} {{mode}}",
            )],
            {"h": 8, "w": 12, "x": 0, "y": 6},
            "percent",
            "Non-idle CPU modes.",
        ),
        timeseries(
            6,
            "Memory",
            [
                (f"node_memory_MemTotal_bytes{{{sel}}}", "{{instance}} total"),
                (f"node_memory_MemAvailable_bytes{{{sel}}}", "{{instance}} available"),
            ],
            {"h": 8, "w": 12, "x": 12, "y": 6},
            "bytes",
            "Node Exporter memory gauges.",
        ),
        timeseries(
            7,
            "Network",
            [(
                "rate(node_network_receive_bytes_total"
                f'{{device!~"lo|veth.*|docker.*|br-.*|virbr.*|cali.*|flannel.*|cni.*|lxc.*|kube.*|erspan.*|gre.*|gretap.*|ip6.*|ip_vti.*|sit.*|tunl.*|dummy.*|ifb.*",{sel}}}[5m])',
                "{{instance}} rx {{device}}",
            ), (
                "-rate(node_network_transmit_bytes_total"
                f'{{device!~"lo|veth.*|docker.*|br-.*|virbr.*|cali.*|flannel.*|cni.*|lxc.*|kube.*|erspan.*|gre.*|gretap.*|ip6.*|ip_vti.*|sit.*|tunl.*|dummy.*|ifb.*",{sel}}}[5m])',
                "{{instance}} tx {{device}}",
            )],
            {"h": 8, "w": 12, "x": 0, "y": 14},
            "Bps",
            "Receive is positive. Transmit is drawn negative.",
        ),
        timeseries(
            8,
            "Filesystem use",
            [(
                "(1 - (node_filesystem_avail_bytes"
                f'{{fstype!~"tmpfs|devtmpfs|overlay|squashfs|autofs",mountpoint!~"/(run|proc|sys|dev|host_mnt|boot|var/lib/docker|var/lib/kubelet)(/|$).*",{sel}}} / '
                "node_filesystem_size_bytes"
                f'{{fstype!~"tmpfs|devtmpfs|overlay|squashfs|autofs",mountpoint!~"/(run|proc|sys|dev|host_mnt|boot|var/lib/docker|var/lib/kubelet)(/|$).*",{sel}}})) * 100',
                "{{instance}} {{mountpoint}}",
            )],
            {"h": 8, "w": 12, "x": 12, "y": 14},
            "percent",
            "Excludes tmpfs, devtmpfs, and overlay.",
        ),
    ]


def overview_panels() -> list[dict]:
    return host_panels()[:4] + [
        stat(
            9,
            "Uptime",
            f'time() - node_boot_time_seconds{{{JOB},{INST}}}',
            {"h": 4, "w": 6, "x": 0, "y": 6},
            "s",
            [("green", None)],
            "Time since the host booted.",
        ),
    ]


def prometheus_panels() -> list[dict]:
    sel = f"{JOB},{INST}"
    return [
        stat(1, "Config reload", f"prometheus_config_last_reload_successful{{{sel}}}", {"h": 4, "w": 6, "x": 0, "y": 0}, "none", UP, "1 means the last reload succeeded."),
        stat(2, "Alertmanagers", f"prometheus_notifications_alertmanagers_discovered{{{sel}}}", {"h": 4, "w": 6, "x": 6, "y": 0}, "none", [("red", None), ("green", 1)], "Matches PrometheusNotConnectedToAlertmanager when this is below 1."),
        stat(3, "Targets up", "count(up == 1)", {"h": 4, "w": 6, "x": 12, "y": 0}, "short", [("green", None)], "Healthy scrape targets across every job. Not filtered by the Prometheus instance variable."),
        stat(4, "Rule eval failures", f"sum(increase(prometheus_rule_evaluation_failures_total{{{sel}}}[15m]))", {"h": 4, "w": 6, "x": 18, "y": 0}, "none", [("green", None), ("red", 1)], "Failures while evaluating recording and alerting rules."),
        timeseries(5, "Scrape duration", [(f"scrape_duration_seconds{{{sel}}}", "{{instance}}")], {"h": 8, "w": 12, "x": 0, "y": 4}, "s", "How long the last scrape of Prometheus itself took."),
        timeseries(6, "TSDB head series", [(f"prometheus_tsdb_head_series{{{sel}}}", "{{instance}}")], {"h": 8, "w": 12, "x": 12, "y": 4}, "short", "Active series in the TSDB head block."),
    ]


def blackbox_panels() -> list[dict]:
    sel = f"{JOB},{INST}"
    return [
        stat(1, "Probe success", f"probe_success{{{sel}}}", {"h": 4, "w": 6, "x": 0, "y": 0}, "none", UP, "1 is up. Matches alert BlackboxProbeFailed."),
        stat(2, "HTTP status", f"probe_http_status_code{{{sel}}}", {"h": 4, "w": 6, "x": 6, "y": 0}, "none", [("green", None)], "HTTP status from the http_2xx module."),
        timeseries(3, "Probe duration", [(f"probe_duration_seconds{{{sel}}}", "{{instance}}")], {"h": 8, "w": 12, "x": 0, "y": 4}, "s", "End-to-end probe duration."),
        timeseries(
            4,
            "Certificate expiry",
            [(f"(probe_ssl_earliest_cert_expiry{{{sel}}} - time()) / 86400", "{{instance}}")],
            {"h": 8, "w": 12, "x": 12, "y": 4},
            "d",
            "Days until the earliest certificate expires. Empty when the probe is not HTTPS.",
        ),
    ]


def nginx_panels() -> list[dict]:
    sel = f"{JOB},{INST}"
    return [
        stat(1, "Exporter up", f"nginx_up{{{sel}}}", {"h": 4, "w": 6, "x": 0, "y": 0}, "none", UP, "Empty until a scrape job named nginx is added."),
        stat(2, "Active connections", f"nginx_connections_active{{{sel}}}", {"h": 4, "w": 6, "x": 6, "y": 0}, "short", [("green", None)], "nginx_connections_active from nginx-prometheus-exporter."),
        timeseries(3, "Requests", [(f"rate(nginx_http_requests_total{{{sel}}}[5m])", "{{instance}}")], {"h": 8, "w": 12, "x": 0, "y": 4}, "reqps", "Request rate."),
        timeseries(
            4,
            "Connection states",
            [
                (f"nginx_connections_reading{{{sel}}}", "{{instance}} reading"),
                (f"nginx_connections_writing{{{sel}}}", "{{instance}} writing"),
                (f"nginx_connections_waiting{{{sel}}}", "{{instance}} waiting"),
            ],
            {"h": 8, "w": 12, "x": 12, "y": 4},
            "short",
            "Reading, writing, and waiting connections.",
        ),
    ]


def postgres_panels() -> list[dict]:
    sel = f"{JOB},{INST}"
    return [
        stat(1, "Exporter up", f"pg_up{{{sel}}}", {"h": 4, "w": 6, "x": 0, "y": 0}, "none", UP, "Matches alert PostgreSQLDown. Empty until job postgresql is scraped."),
        stat(2, "Sessions", f"sum by(instance) (pg_stat_activity_count{{{sel}}})", {"h": 4, "w": 6, "x": 6, "y": 0}, "short", [("green", None)], "Sessions reported by postgres_exporter."),
        timeseries(3, "Transactions", [(f"sum by(instance) (rate(pg_stat_database_xact_commit{{{sel}}}[5m]))", "{{instance}} commit"), (f"sum by(instance) (rate(pg_stat_database_xact_rollback{{{sel}}}[5m]))", "{{instance}} rollback")], {"h": 8, "w": 12, "x": 0, "y": 4}, "ops", "Commits and rollbacks per second."),
        timeseries(4, "Database size", [(f"pg_database_size_bytes{{{sel}}}", "{{instance}} {{datname}}")], {"h": 8, "w": 12, "x": 12, "y": 4}, "bytes", "Size of each database."),
    ]


def redis_panels() -> list[dict]:
    sel = f"{JOB},{INST}"
    hit = f"sum by(instance) (rate(redis_keyspace_hits_total{{{sel}}}[5m]))"
    miss = f"sum by(instance) (rate(redis_keyspace_misses_total{{{sel}}}[5m]))"
    return [
        stat(1, "Exporter up", f"redis_up{{{sel}}}", {"h": 4, "w": 6, "x": 0, "y": 0}, "none", UP, "Matches alert RedisDown. Empty until job redis is scraped."),
        stat(2, "Clients", f"redis_connected_clients{{{sel}}}", {"h": 4, "w": 6, "x": 6, "y": 0}, "short", [("green", None)], "Connected clients."),
        timeseries(3, "Memory", [(f"redis_memory_used_bytes{{{sel}}}", "{{instance}} used")], {"h": 8, "w": 12, "x": 0, "y": 4}, "bytes", "Used memory."),
        timeseries(4, "Hit ratio", [(f"{hit} / ({hit} + {miss})", "{{instance}}")], {"h": 8, "w": 12, "x": 12, "y": 4}, "percentunit", "Hits divided by hits plus misses. Empty when there is no keyspace traffic."),
        timeseries(5, "Commands", [(f"rate(redis_commands_processed_total{{{sel}}}[5m])", "{{instance}}")], {"h": 8, "w": 24, "x": 0, "y": 12}, "ops", "Commands processed per second."),
    ]


def rabbitmq_panels() -> list[dict]:
    sel = f"{JOB},{INST}"
    return [
        stat(1, "Exporter up", f"rabbitmq_up{{{sel}}}", {"h": 4, "w": 6, "x": 0, "y": 0}, "none", UP, "Matches alert RabbitMQDown. Empty until job rabbitmq is scraped."),
        stat(2, "Connections", f"sum by(instance) (rabbitmq_connections{{{sel}}})", {"h": 4, "w": 6, "x": 6, "y": 0}, "short", [("green", None)], "Broker connections from rabbitmq_exporter."),
        timeseries(3, "Queue messages", [(f"sum by(instance) (rabbitmq_queue_messages{{{sel}}})", "{{instance}}")], {"h": 8, "w": 12, "x": 0, "y": 4}, "short", "Messages in queues."),
        timeseries(4, "Ready vs unacked", [(f"sum by(instance) (rabbitmq_queue_messages_ready{{{sel}}})", "{{instance}} ready"), (f"sum by(instance) (rabbitmq_queue_messages_unacknowledged{{{sel}}})", "{{instance}} unacked")], {"h": 8, "w": 12, "x": 12, "y": 4}, "short", "Ready messages and messages waiting for acknowledgement."),
    ]


def fail2ban_panels() -> list[dict]:
    sel = f"{JOB},{INST}"
    return [
        stat(
            1, "Current bans",
            f"sum(fail2ban_current_bans{{{sel}}})",
            {"h": 4, "w": 6, "x": 0, "y": 0},
            "short",
            [("green", None), ("yellow", 1), ("red", 10)],
            "IPs currently banned across all jails.",
        ),
        stat(
            2, "Failed attempts",
            f"sum(fail2ban_failed_current{{{sel}}})",
            {"h": 4, "w": 6, "x": 6, "y": 0},
            "short",
            [("green", None), ("yellow", 5), ("red", 20)],
            "Failed login attempts currently tracked across all jails.",
        ),
        timeseries(
            3, "Active bans per jail",
            [(f"fail2ban_current_bans{{{sel}}}", "{{jail}}")],
            {"h": 8, "w": 12, "x": 0, "y": 4},
            "short",
            "Currently banned IPs broken down by jail.",
        ),
        timeseries(
            4, "New bans per hour",
            [(f"increase(fail2ban_banned_total{{{sel}}}[1h])", "{{jail}}")],
            {"h": 8, "w": 12, "x": 12, "y": 4},
            "short",
            "Ban rate per jail over the last hour. Matches alert Fail2banHighAttackRate (>10 in 5 min).",
        ),
        timeseries(
            5, "Failed attempts per jail",
            [(f"fail2ban_failed_current{{{sel}}}", "{{jail}}")],
            {"h": 8, "w": 24, "x": 0, "y": 12},
            "short",
            "Current failed attempts tracked by each jail.",
        ),
    ]


def build() -> dict[str, dict]:
    return {
        "host.json": dashboard(
            "ms-host",
            "Host",
            "CPU, memory, disk, and network from Node Exporter. Original dashboard for this repository.",
            ["monitoring", "host", "node-exporter"],
            host_panels(),
            "node_uname_info",
        ),
        "system-overview.json": dashboard(
            "system-overview",
            "System Overview",
            "Short host summary: CPU, memory, root disk, load, and uptime.",
            ["monitoring", "host", "overview"],
            overview_panels(),
            "node_uname_info",
        ),
        "prometheus.json": dashboard(
            "ms-prometheus",
            "Prometheus",
            "Prometheus process health: reload, Alertmanager link, scrape duration, and TSDB series.",
            ["monitoring", "prometheus"],
            prometheus_panels(),
            "prometheus_build_info",
        ),
        "blackbox.json": dashboard(
            "ms-blackbox",
            "Blackbox",
            "HTTP probe success, status, duration, and certificate expiry. Select the probe job in the $job dropdown.",
            ["monitoring", "blackbox"],
            blackbox_panels(),
            "probe_success",
            "Target",
        ),
        "nginx.json": dashboard(
            "ms-nginx",
            "Nginx",
            "nginx-prometheus-exporter metrics. Select the scrape job in the $job dropdown.",
            ["monitoring", "nginx"],
            nginx_panels(),
            "nginx_up",
        ),
        "postgresql.json": dashboard(
            "ms-postgresql",
            "PostgreSQL",
            "postgres_exporter metrics. Select the scrape job in the $job dropdown.",
            ["monitoring", "postgresql"],
            postgres_panels(),
            "pg_up",
        ),
        "redis.json": dashboard(
            "ms-redis",
            "Redis",
            "redis_exporter metrics. Select the scrape job in the $job dropdown.",
            ["monitoring", "redis"],
            redis_panels(),
            "redis_up",
        ),
        "rabbitmq.json": dashboard(
            "ms-rabbitmq",
            "RabbitMQ",
            "rabbitmq_exporter metrics. Select the scrape job in the $job dropdown.",
            ["monitoring", "rabbitmq"],
            rabbitmq_panels(),
            "rabbitmq_up",
        ),
        "fail2ban.json": dashboard(
            "ms-fail2ban",
            "Fail2ban",
            "fail2ban jail activity: current bans, failed attempts, ban rate. Select the scrape job in the $job dropdown.",
            ["monitoring", "security", "fail2ban"],
            fail2ban_panels(),
            "fail2ban_current_bans",
        ),
    }


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    written = set()
    for name, body in build().items():
        types = {panel["type"] for panel in body["panels"]}
        unknown = types - ALLOWED_TYPES
        if unknown:
            raise SystemExit(f"{name} has unsupported panel types: {unknown}")
        path = OUT / name
        path.write_text(json.dumps(body, indent=2) + "\n")
        written.add(name)
        print(f"wrote {path.relative_to(OUT.parent.parent)}")
    for stale in OUT.glob("*.json"):
        if stale.name not in written:
            stale.unlink()
            print(f"removed {stale.name}")


if __name__ == "__main__":
    main()
