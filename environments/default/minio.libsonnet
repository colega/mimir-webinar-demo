local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      container = k.core.v1.container,
      containerPort = k.core.v1.containerPort,
      envVar = k.core.v1.envVar,
      persistentVolumeClaim = k.core.v1.persistentVolumeClaim,
      service = k.core.v1.service,
      statefulSet = k.apps.v1.statefulSet;

{
  container::
    container.new('minio', 'minio/minio')
    + container.withCommand(['/bin/sh', '-euc', 'mkdir -p /data/mimir && minio server /data'])
    + container.withImagePullPolicy('Always')
    + container.withPorts(containerPort.new('http-metrics', 9000))
    + container.withVolumeMounts([{ name: 'minio-data', mountPath: '/data' }])
    + k.util.resourcesRequests('100m', '100Mi')
    + k.util.resourcesLimits(null, '512Mi')
    + container.withEnvMixin([
      envVar.new('MINIO_ACCESS_KEY', 'mimir-demo'),
      envVar.new('MINIO_SECRET_KEY', 'mimir-demo'),
    ]),

  persistentVolumeClaim::
    persistentVolumeClaim.new('minio-data')
    + persistentVolumeClaim.spec.resources.withRequests({ storage: '1Gi' })
    + persistentVolumeClaim.spec.withAccessModes(['ReadWriteOnce'])
    + persistentVolumeClaim.spec.withStorageClassName('local-path'),  // local-path is provisioned by k3s

  statefulSet:
    statefulSet.new('minio', 1, [$.container], $.persistentVolumeClaim)
    + statefulSet.spec.withServiceName($.service.metadata.name)
    + statefulSet.spec.template.metadata.withAnnotationsMixin({ 'prometheus.io/path': '/minio/v2/metrics/cluster' }),

  service:
    k.util.serviceFor($.statefulSet)
    + service.spec.withPublishNotReadyAddresses(true)
    + service.spec.withClusterIp('None'),
}
