# resource "kubernetes_config_map" "coredns_1a" {
#   provider = kubernetes.cluster_1a
#   metadata {
#     name      = "coredns"
#     namespace = "kube-system"
#     labels = {
#       "eks.amazonaws.com/component" = "coredns"
#       "k8s-app"                     = "kube-dns"
#     }
#   }

#   data = {
#     Corefile = <<-EOT
#       ${aws_route53_zone.devops.name}:53 {
#         log
#         errors
#         health
#         forward . 10.0.0.2
#         cache 30
#         reload
#         loadbalance
#       }
#       # General server block for other domains (external queries)
#       .:53 {
#         errors
#         health
#         kubernetes cluster.local in-addr.arpa ip6.arpa {
#           pods insecure
#           fallthrough in-addr.arpa ip6.arpa
#         }
#         multicluster clusterset.local
#         forward . /etc/resolv.conf  # Default system resolver
#         prometheus :9153
#         cache 30
#         loop
#         reload
#         loadbalance
#       }
#     EOT
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "kubernetes_config_map" "coredns_1b" {
#   provider = kubernetes.cluster_1b
#   metadata {
#     name      = "coredns"
#     namespace = "kube-system"
#     labels = {
#       "eks.amazonaws.com/component" = "coredns"
#       "k8s-app"                     = "kube-dns"
#     }
#   }

#   data = {
#     Corefile = <<-EOT
#       ${aws_route53_zone.devops.name}:53 {
#         log
#         errors
#         health
#         forward . 10.0.0.2
#         cache 30
#         reload
#         loadbalance
#       }
#       # General server block for other domains (external queries)
#       .:53 {
#         errors
#         health
#         kubernetes cluster.local in-addr.arpa ip6.arpa {
#           pods insecure
#           fallthrough in-addr.arpa ip6.arpa
#         }
#         multicluster clusterset.local
#         forward . /etc/resolv.conf  # Default system resolver
#         prometheus :9153
#         cache 30
#         loop
#         reload
#         loadbalance
#       }
#     EOT
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }
