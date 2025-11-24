variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "namespace" {
  description = "Top-level namespace, usually a team or org"
  type        = string
  default     = "platform"
}

variable "stage" {
  description = "Environment"
  type        = string
  default     = "prod"
}

variable "name" {
  description = "Cluster name"
  type        = string
  default     = "eks"
}

variable "project" {
  description = "Project or application name"
  type        = string
  default     = "color-page"
}

variable "availability_zones" {
  description = "Availability Zones to use"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "kubernetes_version" {
  description = "EKS control plane version"
  type        = string
  default     = "1.30"
}

variable "instance_type" {
  description = "Node group EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "desired_size" {
  description = "Desired node count"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Min node count"
  type        = number
  default     = 3
}

variable "max_size" {
  description = "Max node count"
  type        = number
  default     = 5
}

variable "autoscaling_policies_enabled" {
  description = "Enable autoscaling policies"
  type        = bool
  default     = true
}

variable "cluster_log_retention_period" {
  description = "EKS control plane log retention in days"
  type        = number
  default     = 7
}

variable "allowed_cidrs" {
  description = "CIDR blocks allowed to access the public EKS API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
