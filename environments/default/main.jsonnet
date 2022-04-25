local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      secret = k.core.v1.secret,
      deployment = k.apps.v1.deployment,
      statefulSet = k.apps.v1.statefulSet,
      pvc = k.core.v1.persistentVolumeClaim;

local prometheus_ksonnet = import 'prometheus-ksonnet/prometheus-ksonnet.libsonnet';
local cert_manager = import 'cert-manager/cert-manager.libsonnet';
local cluster_issuers = import 'cert-manager/cluster-issuers.libsonnet';
local config = import 'config.libsonnet';
local ingress = import 'traefik/ingress.libsonnet';
local middleware = import 'traefik/middleware.libsonnet';
local minio = import 'minio.libsonnet';
local mimir = import 'mimir/mimir.libsonnet';
local mimir_mixin = import 'mimir-mixin/mixin.libsonnet';
local grafana_cloud = import 'grafana_cloud.libsonnet';

prometheus_ksonnet + cert_manager + cluster_issuers + minio + mimir + grafana_cloud + config {
  _config+:: {
    cluster_name: 'demo',
    namespace: 'default',
    grafana_root_url: 'https://grafana.%(domain)s' % $._config,

    memberlist_ring_enabled: true,

    blocks_storage_backend: 's3',
    blocks_storage_bucket_name: 'mimir',
    blocks_storage_s3_endpoint: 'minio:9000',
    s3BlocksStorageConfig+:: {
      'blocks-storage.s3.access-key-id': 'mimir-demo',
      'blocks-storage.s3.secret-access-key': 'mimir-demo',
      'blocks-storage.s3.insecure': 'true',
    },

    compactor_data_disk_class: 'local-path',
    compactor_data_disk_size: '1Gi',
    ingester_data_disk_class: 'local-path',
    ingester_data_disk_size: '1Gi',
    store_gateway_data_disk_class: 'local-path',
    store_gateway_data_disk_size: '1Gi',

    distributor_allow_multiple_replicas_on_same_node: true,
    ingester_allow_multiple_replicas_on_same_node: true,
    querier_allow_multiple_replicas_on_same_node: true,
    query_frontend_allow_multiple_replicas_on_same_node: true,
    ruler_allow_multiple_replicas_on_same_node: true,
    store_gateway_allow_multiple_replicas_on_same_node: true,
  },

  _images+:: {
    mimir: 'grafana/mimir:r183-5299284',
  },

  prometheus+: {
    _config+: {
      prometheus_requests_cpu: '100m',
      prometheus_requests_memory: '512Mi',
      prometheus_limits_cpu: null,
      prometheus_limits_memory: '1Gi',
    },
    prometheus_pvc+:: pvc.mixin.spec.resources.withRequests({ storage: '256Mi' }),
  },

  prometheus_config+:: {
    scrape_configs: [
      config { relabel_configs+: [{ target_label: 'cluster', replacement: $._config.cluster_name }] }
      for config in super.scrape_configs
    ],
    remote_write+: [
      {
        url: 'https://mimir-writes.%(domain)s/api/v1/push' % $._config,
        basic_auth: { username: 'mimir', password: 'mimir' },
        tls_config: { insecure_skip_verify: true },
      },
    ],
  },

  grafanaDatasources+:: {
    'mimir.yml': $.grafana_datasource_with_basicauth('Mimir', 'https://mimir-reads.%(domain)s/prometheus' % $._config, 'mimir', 'mimir', method='POST')
                 + { jsonData+: { tlsSkipVerify: true } },
  },

  mixins+:: {
    mimir: mimir_mixin,
  },

  ingress: {
    basic_auth_secret: secret.new('basic-auth', { users: std.base64(importstr 'htpasswd') }),
    basic_auth_middleware: middleware.newBasicAuth('basic-auth'),

    grafana: ingress.new(['grafana.%(domain)s' % $._config], clusterIssuer='selfsigned')
             + ingress.withMiddleware('basic-auth')
             + ingress.withService('grafana'),
    prometheus: ingress.new(['prometheus.%(domain)s' % $._config], clusterIssuer='selfsigned')
                + ingress.withMiddleware('basic-auth')
                + ingress.withService('prometheus', 9090),

    mimir_basic_auth_middleware: middleware.newBasicAuth('mimir-basic-auth', secretName='basic-auth', headerField='X-Scope-OrgID'),

    mimir_reads: ingress.new(['mimir-reads.%(domain)s' % $._config])
                 + ingress.withMiddleware('mimir-basic-auth')
                 + ingress.withService('query-frontend', 8080),

    mimir_writes: ingress.new(['mimir-writes.%(domain)s' % $._config])
                  + ingress.withMiddleware('mimir=basic-auth')
                  + ingress.withService('distributor', 8080),
  },

  consul: null,  // We don't use consul in the demo.
  etcd: null,  // We don't use etcd in the demo.
  distributor_args+:: {
    'distributor.ha-tracker.enable': false,  // We don't have HA Prometheus in the demo.
  },

  compactor_container+:: k.util.resourcesRequests('100m', '128Mi'),
  compactor_statefulset+: statefulSet.mixin.spec.withReplicas(1),

  distributor_container+:: k.util.resourcesRequests('100m', '128Mi'),
  distributor_deployment+: deployment.mixin.spec.withReplicas(2),

  ingester_container+:: k.util.resourcesRequests('100m', '128Mi'),
  ingester_statefulset+: statefulSet.mixin.spec.withReplicas(3),

  querier_container+:: k.util.resourcesRequests('100m', '128Mi'),
  querier_deployment+: deployment.mixin.spec.withReplicas(2),

  query_frontend_container+:: k.util.resourcesRequests('100m', '128Mi'),
  query_frontend_deployment+: deployment.mixin.spec.withReplicas(2),

  store_gateway_container+:: k.util.resourcesRequests('100m', '128Mi'),
  store_gateway_statefulset+: statefulSet.mixin.spec.withReplicas(3),

  local smallMemcached = {
    cpu_requests:: '100m',
    memory_limit_mb:: 64,
    memory_request_overhead_mb:: 8,
    statefulSet+: statefulSet.mixin.spec.withReplicas(1),
  },

  memcached_chunks+: smallMemcached,
  memcached_frontend+: smallMemcached,
  memcached_index_queries+: smallMemcached,
  memcached_metadata+: smallMemcached,
}
