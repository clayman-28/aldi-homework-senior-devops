variable "namespace" {
  description = "declare the target namespace"
  type        = string
  default     = "homework"
}

variable "environment" {
  description = "declare the target environment"
  type        = string
  default     = dev

  validation {
    condition     = contains(["dev", "test", "stage", "prod"], var.environment)
    error_message = "environment must be dev,test,stage or prod!"
  }
}
variable "image_tag" {
  description = "declare image tag and version"
  type        = string
}

variable "kubeconfig_path" {
  description = "for k8s access, need to declare a valid kubeconfig"
  type        = string
  default     = "~/.kube/config"
}