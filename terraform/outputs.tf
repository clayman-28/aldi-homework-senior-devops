output "namespace" {
    description = "namespace the application was deployed into."
    value       = kubernetes_namespace_v1.homework.metadata[0].name
}

output "release_name" {
description = "name of the installed helm release."
value       = helm_release.homework.name
}

output "release_status" {
description = "status of the Helm release after apply, for example deployed."
value       = helm_release.homework.status
}
