
locals {
  edp_catalogs = flatten([
    for catalog in var.edp_ingestion_source_catalogs : [
      for source in catalog.sources : [
        for stage in catalog.data_processing_stages : {
          catalog_name = source
          data_processing_stage = stage
          metastore_id = databricks_metastore.primary.id
          env          = var.metadata["environment"]
          catalog_schema_owner = "sriram"
          schema       = catalog.schema_name
          storage_root = catalog.storage_root
          description  = catalog.description
          add_groups_to_catalogs = catalog.add_groups_to_catalogs
          add_groups_to_schemas = catalog.add_groups_to_schemas
          dbricks_workspace_id = catalog.dbricks_workspace_id
        }
      ]
    ]
  ])
}

module "edp_catalogs" {
  source = "./modules/edp_catalogs_v2"
  for_each = { for catalog in local.edp_catalogs : "${catalog.catalog_name}_${catalog.data_processing_stage}" => catalog }

  env                  = each.value.env
  metastore_id         = each.value.metastore_id
  catalog_name         = each.value.catalog_name
  catalog_schema_owner = each.value.catalog_schema_owner
  schema               = each.value.schema
  storage_root         = each.value.storage_root
  data_processing_stage = each.value.data_processing_stage
  add_groups_to_catalogs = each.value.add_groups_to_catalogs
  add_groups_to_schemas  = each.value.add_groups_to_schemas
  dbricks_workspace_id   = each.value.dbricks_workspace_id
  description           = each.value.description
  providers = {
    databricks.azure_account = databricks.azure_account
    databricks.edp_workspace = databricks.edp_workspace
  }
  depends_on = [
    databricks_external_location.external_location
  ]
}
