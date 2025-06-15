terraform {
  required_version = "=1.7.4"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    databricks = {
      source = "databricks/databricks"
      version = "1.40.0"
      configuration_aliases = [databricks.edp_workspace, databricks.azure_account]
    }
  }
}


###################Catalog creation#######################
resource "databricks_catalog" "edp_catalogs_v2" {
  provider        = databricks.edp_workspace
  metastore_id    = var.metastore_id
  name            = "${var.catalog_name}_${var.data_processing_stage}_${var.env}"
  comment         = var.description
  owner           = var.catalog_schema_owner
  storage_root    = var.storage_root
  isolation_mode  = "ISOLATED"  
  #force_destroy = "true"
  properties = {
    purpose = "${var.catalog_name}_${var.env}"
  }
}

resource "databricks_catalog_workspace_binding" "edp_catalog_binding" {
  provider          = databricks.edp_workspace
  securable_name    = databricks_catalog.edp_catalogs_v2.name
  for_each          = toset(var.dbricks_workspace_id)
  workspace_id      = each.value
}

resource "databricks_grants" "edp_catalogs_grants" {
  provider     = databricks.edp_workspace
  catalog      = databricks_catalog.edp_catalogs_v2.name
  dynamic "grant" {
    for_each = var.add_groups_to_catalogs
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}

#######################schema creation##############################
resource "databricks_schema" "edp_schema" {
  provider         = databricks.edp_workspace
  for_each         = toset(var.schema)
  catalog_name     = databricks_catalog.edp_catalogs_v2.name
  name             = each.value
  owner            = var.catalog_schema_owner
  comment          = ""  
  lifecycle {
    prevent_destroy = false
  }
}

resource "databricks_grants" "edp_schema" {
  provider         = databricks.edp_workspace
  #for_each = databricks_schema.edp_schema
  for_each = {
    for schema_key, schema_value in databricks_schema.edp_schema :
    schema_key => schema_value if length([for grant in var.add_groups_to_schemas : grant if grant.schema_name == schema_key]) > 0
  }  
  schema          = each.value.id
  dynamic "grant" {
    for_each = [for grant in var.add_groups_to_schemas : grant if grant.schema_name == each.key]  # Filter grants by schema_name
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}
