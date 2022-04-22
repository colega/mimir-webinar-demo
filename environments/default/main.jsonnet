local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      pvc = k.core.v1.persistentVolumeClaim;

local prometheus_ksonnet = import 'prometheus-ksonnet/prometheus-ksonnet.libsonnet';

prometheus_ksonnet {
  _config+:: {
    cluster_name: 'demo',
    namespace: 'default',
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
}
