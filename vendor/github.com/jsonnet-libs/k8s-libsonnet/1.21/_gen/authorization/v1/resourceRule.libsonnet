{
  local d = (import 'doc-util/main.libsonnet'),
  '#':: d.pkg(name='resourceRule', url='', help="\"ResourceRule is the list of actions the subject is allowed to perform on resources. The list ordering isn't significant, may contain duplicates, and possibly be incomplete.\""),
  '#withApiGroups':: d.fn(help='"APIGroups is the name of the APIGroup that contains the resources.  If multiple API groups are specified, any action requested against one of the enumerated resources in any API group will be allowed.  \\"*\\" means all."', args=[d.arg(name='apiGroups', type=d.T.array)]),
  withApiGroups(apiGroups): { apiGroups: if std.isArray(v=apiGroups) then apiGroups else [apiGroups] },
  '#withApiGroupsMixin':: d.fn(help='"APIGroups is the name of the APIGroup that contains the resources.  If multiple API groups are specified, any action requested against one of the enumerated resources in any API group will be allowed.  \\"*\\" means all."\n\n**Note:** This function appends passed data to existing values', args=[d.arg(name='apiGroups', type=d.T.array)]),
  withApiGroupsMixin(apiGroups): { apiGroups+: if std.isArray(v=apiGroups) then apiGroups else [apiGroups] },
  '#withResourceNames':: d.fn(help='"ResourceNames is an optional white list of names that the rule applies to.  An empty set means that everything is allowed.  \\"*\\" means all."', args=[d.arg(name='resourceNames', type=d.T.array)]),
  withResourceNames(resourceNames): { resourceNames: if std.isArray(v=resourceNames) then resourceNames else [resourceNames] },
  '#withResourceNamesMixin':: d.fn(help='"ResourceNames is an optional white list of names that the rule applies to.  An empty set means that everything is allowed.  \\"*\\" means all."\n\n**Note:** This function appends passed data to existing values', args=[d.arg(name='resourceNames', type=d.T.array)]),
  withResourceNamesMixin(resourceNames): { resourceNames+: if std.isArray(v=resourceNames) then resourceNames else [resourceNames] },
  '#withResources':: d.fn(help="\"Resources is a list of resources this rule applies to.  \\\"*\\\" means all in the specified apiGroups.\\n \\\"*/foo\\\" represents the subresource 'foo' for all resources in the specified apiGroups.\"", args=[d.arg(name='resources', type=d.T.array)]),
  withResources(resources): { resources: if std.isArray(v=resources) then resources else [resources] },
  '#withResourcesMixin':: d.fn(help="\"Resources is a list of resources this rule applies to.  \\\"*\\\" means all in the specified apiGroups.\\n \\\"*/foo\\\" represents the subresource 'foo' for all resources in the specified apiGroups.\"\n\n**Note:** This function appends passed data to existing values", args=[d.arg(name='resources', type=d.T.array)]),
  withResourcesMixin(resources): { resources+: if std.isArray(v=resources) then resources else [resources] },
  '#withVerbs':: d.fn(help='"Verb is a list of kubernetes resource API verbs, like: get, list, watch, create, update, delete, proxy.  \\"*\\" means all."', args=[d.arg(name='verbs', type=d.T.array)]),
  withVerbs(verbs): { verbs: if std.isArray(v=verbs) then verbs else [verbs] },
  '#withVerbsMixin':: d.fn(help='"Verb is a list of kubernetes resource API verbs, like: get, list, watch, create, update, delete, proxy.  \\"*\\" means all."\n\n**Note:** This function appends passed data to existing values', args=[d.arg(name='verbs', type=d.T.array)]),
  withVerbsMixin(verbs): { verbs+: if std.isArray(v=verbs) then verbs else [verbs] },
  '#mixin': 'ignore',
  mixin: self,
}
