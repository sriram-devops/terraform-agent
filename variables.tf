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
  default = [
    {
      sources                        = ["edp_ingestion_source_catalogs"]
      schema_name                    = ["edp_ingestion_source_schema"]
      data_processing_stages         = ["edp_ingestion_source_stage"]
      add_groups_to_catalogs         = [
        {
          principal  = "edp_ingestion_source_catalogs_group"
          privileges = ["USAGE", "CREATE"]
        },
        {
          principal  = "edp_ingestion_source_catalogs_group2"
          privileges = ["USAGE", "CREATE"]
        }
      ]
      add_groups_to_schemas          = [
        {
          schema_name= "edp_ingestion_source_schema"
          principal  = "edp_ingestion_source_schema_group"
          privileges = ["USAGE", "CREATE"]
        },
        {
          schema_name= "edp_ingestion_source_schema2"
          principal  = "edp_ingestion_source_schema_group2"
          privileges = ["USAGE", "CREATE"]
        }
      ]
      storage_root                   = "dbfs:/edp-ingestion-source/"
      description                    = ""
      dbricks_workspace_id           = ["1123"]
    }
  ]
}