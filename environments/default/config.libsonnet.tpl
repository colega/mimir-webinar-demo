{
  _config+:: {
    domain: '${DEMO_DOMAIN}',
    grafana_cloud+: {
        enabled: false,
        metrics_push_url: error 'please provide metrics push url for Grafana Cloud (Stacks -> Prometheus -> Details -> URL)',
        metrics_tenant_id: error 'please provide metrics tenant id for Grafana Cloud (Stacks -> Prometheus -> Details -> User)',
        logs_push_url: error 'please provide logs push url for Grafana Cloud (Stacks -> Loki -> Details -> URL)',
        logs_tenant_id: error 'please provide logs tenant id for Grafana Cloud (Stacks -> Loki -> Details -> User)',
        api_key: importstr 'grafana_cloud_api_key.txt',
    },
  },
}