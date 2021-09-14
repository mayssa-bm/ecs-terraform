variable "aws_region" {
  default     = "eu-west-1"
  description = "aws region where our resources going to be created "
  
}

variable "az_count" {
  default     = "2"
  description = "number of availability zones in above region"
}

variable "ecs_task_execution_role" {
  default     = "myECcsTaskExecutionRole"
  description = "ECS task execution role name"
}

variable "app_image" {
  default     = "nginx:latest"
  description = "docker image to run in this ECS cluster"
}

variable "app_port" {
  default     = "80"
  description = "port exposed on the docker image"
}

variable "app_count" {
  default     = "2" #2 AZ
  description = "numer of docker containers to run"
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  default     = "1024"
  description = "fargate instacne CPU units to provision, requirent is 1 vcpu so gave 1024"
}

variable "fargate_memory" {
  default     = "2048"
  description = "Fargate instance memory to provision (in MiB) not MB"
}