{
  local d = (import 'doc-util/main.libsonnet'),
  '#':: d.pkg(name='v1', url='', help=''),
  httpIngressPath: (import 'httpIngressPath.libsonnet'),
  httpIngressRuleValue: (import 'httpIngressRuleValue.libsonnet'),
  ingress: (import 'ingress.libsonnet'),
  ingressBackend: (import 'ingressBackend.libsonnet'),
  ingressClass: (import 'ingressClass.libsonnet'),
  ingressClassParametersReference: (import 'ingressClassParametersReference.libsonnet'),
  ingressClassSpec: (import 'ingressClassSpec.libsonnet'),
  ingressRule: (import 'ingressRule.libsonnet'),
  ingressServiceBackend: (import 'ingressServiceBackend.libsonnet'),
  ingressSpec: (import 'ingressSpec.libsonnet'),
  ingressStatus: (import 'ingressStatus.libsonnet'),
  ingressTLS: (import 'ingressTLS.libsonnet'),
  ipBlock: (import 'ipBlock.libsonnet'),
  networkPolicy: (import 'networkPolicy.libsonnet'),
  networkPolicyEgressRule: (import 'networkPolicyEgressRule.libsonnet'),
  networkPolicyIngressRule: (import 'networkPolicyIngressRule.libsonnet'),
  networkPolicyPeer: (import 'networkPolicyPeer.libsonnet'),
  networkPolicyPort: (import 'networkPolicyPort.libsonnet'),
  networkPolicySpec: (import 'networkPolicySpec.libsonnet'),
  serviceBackendPort: (import 'serviceBackendPort.libsonnet'),
}
