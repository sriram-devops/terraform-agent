variable "edp_ingestion_source_catalogs" {
    type = list(object({
      sources                        = list(string)
      schema_name                    = list(string)
      #processing_catalog_permissions = list(string)
      data_processing_stages         = list(string)
      add_groups_to_catalogs = optional(set(object({
        principal  = string
        privileges = list(string)
      })), [])
      add_groups_to_schemas = optional(set(object({
        schema_name= string
        principal  = string
        privileges = list(string)
      })), [])             
      storage_root                   = string
      description                    = string
      dbricks_workspace_id           = list(string)
    }))
}