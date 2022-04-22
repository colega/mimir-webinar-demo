local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      secret = k.core.v1.secret,
      pvc = k.core.v1.persistentVolumeClaim;

local prometheus_ksonnet = import 'prometheus-ksonnet/prometheus-ksonnet.libsonnet';
local cert_manager = import 'cert-manager/cert-manager.libsonnet';
local cluster_issuers = import 'cert-manager/cluster-issuers.libsonnet';
local config = import 'config.libsonnet';
local ingress = import 'traefik/ingress.libsonnet';
local middleware = import 'traefik/middleware.libsonnet';
local minio = import 'minio.libsonnet';

prometheus_ksonnet + cert_manager + cluster_issuers + minio + config {
  _config+:: {
    cluster_name: 'demo',
    namespace: 'default',
    grafana_root_url: 'https://grafana.%(domain)s' % $._config,
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

  ingress: {
    basic_auth_secret: secret.new('basic-auth', { users: std.base64(importstr 'htpasswd') }),
    basic_auth_middleware: middleware.newBasicAuth('basic-auth'),

    grafana: ingress.new(['grafana.%(domain)s' % $._config], clusterIssuer='selfsigned')
             + ingress.withMiddleware('basic-auth')
             + ingress.withService('grafana'),
    prometheus: ingress.new(['prometheus.%(domain)s' % $._config], clusterIssuer='selfsigned')
                + ingress.withMiddleware('basic-auth')
                + ingress.withService('prometheus', 9090),
  },
}
