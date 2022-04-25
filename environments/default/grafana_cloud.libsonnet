local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      secret = k.core.v1.secret;
local k_util = import 'k-util/k-util.libsonnet';
local promtail = import 'github.com/grafana/loki/production/ksonnet/promtail/promtail.libsonnet';
local grafana_agent = import 'grafana-agent/grafana-agent.libsonnet';

{
  _config+:: {
    grafana_cloud+: {
      enabled: false,
    },
  },

  local enabled = $._config.grafana_cloud.enabled,

  grafana_cloud_api_key: if enabled then {
    filename:: 'api_key.txt',
    dir:: '/etc/grafana_cloud/',
    full_path:: self.dir + self.filename,

    secret: secret.new('grafana-cloud-writes-api-key', {
      'api_key.txt': std.base64($._config.grafana_cloud.api_key),
    }),

    secret_volume_mount_mixin:: k_util.secretVolumeMountWithHash(self.secret, self.dir),
  },

  grafana_agent: if enabled then grafana_agent {
    _config+:: {
      namespace: $._config.namespace,
      cluster: $._config.cluster_name,
      metrics_url: $._config.grafana_cloud.metrics_push_url,
      metrics_tenant_id: $._config.grafana_cloud.metrics_tenant_id,
      metrics_api_key_path: $.grafana_cloud_api_key.full_path,
    },
    deployment+: $.grafana_cloud_api_key.secret_volume_mount_mixin,
  },

  promtail: if enabled then promtail {
    _config+:: $._config,
    promtail_config+:: {
      clients: [{
        url: $._config.grafana_cloud.logs_push_url,
        basic_auth: {
          username: $._config.grafana_cloud.logs_tenant_id,
          password_file: $.grafana_cloud_api_key.full_path,
        },
      }],
    },
    _images+:: $._images,

    promtail_daemonset+: $.grafana_cloud_api_key.secret_volume_mount_mixin,
  },
}
