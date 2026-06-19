terraform {
  required_version = "~> 1.15.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

resource "null_resource" "example" {
  triggers = {
    message = "managed by tfaction"
  }
}

output "example_id" {
  description = "ID of the example null_resource."
  value       = null_resource.example.id
}
