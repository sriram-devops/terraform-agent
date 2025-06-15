variable "env" {
  type = string
}

variable "metastore_id" {
  type = string
}

variable "catalog_name" {
  type = string
}

variable "catalog_schema_owner" {
  type = string
}

variable "schema" {
  type = list(string)
}

variable "storage_root" {
  type = string
}

variable "data_processing_stage" {
  type = string
}

variable "description" {
  type = string
}

variable "add_groups_to_catalogs" {
  type = set(object({
    principal  = string
    privileges = list(string)
  }))
  default = []
}

variable "add_groups_to_schemas" {
  type = set(object({
    schema_name = string
    principal  = string
    privileges = list(string)
  }))
  default = []
}

variable "dbricks_workspace_id" {
  type = list(string)
}