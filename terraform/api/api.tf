variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "directory" {
  type    = string
  default = "json"
}

variable "endpoint" {
  type    = string
  default = "REGIONAL"
}

variable "stage" {
  type    = string
  default = "prod" # if nps then stage should match env
}

terraform {

  required_version = "~> 1.10"

  backend "local" {
    path = "./terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.47.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.1"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  jsonfiles = [for f in fileset("${path.module}/${var.directory}/", "*.json") :
    {
      value          = f
      path = "${path.module}/${var.directory}/${f}"
      name = jsondecode(file("${path.module}/${var.directory}/${f}")).info.title
    }
  ]
}

resource "aws_api_gateway_rest_api" "import" {
  for_each = toset(local.jsonfiles[*].path)
  body = templatefile(each.value, {})
  name = jsondecode(file(each.value)).info.title
  endpoint_configuration {
    types = [var.endpoint]
  }
}

resource "aws_api_gateway_deployment" "import" {
  for_each = aws_api_gateway_rest_api.import
  rest_api_id = each.value.id
  triggers = {
    redeployment = sha1(jsonencode(each.value.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "import" {
  for_each = aws_api_gateway_deployment.import
  deployment_id = each.value.id
  rest_api_id   = each.value.rest_api_id
  stage_name    = var.stage
}
