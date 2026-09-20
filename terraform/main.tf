resource "kubernetes_namespace_v1" "homework" {
  metadata {
    name = var.namespace
    labels = {
      environment = var.environment
    }
  }
}

resource "helm_release" "homework" {
  name      = "myapp"
  chart     = "${path.module}/../helm"
  namespace = kubernetes_namespace_v1.homework.metadata[0].name

  set = [
    {
      name  = "image.tag"
      value = var.image_tag
    },
    {
      name  = "environment"
      value = var.environment
    },
  ]

  atomic          = true
  wait            = true
  timeout         = 300
  cleanup_on_fail = true
}