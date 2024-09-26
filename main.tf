# ------------------------------------------ Resource Group

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location
}

# ------------------------------------------ Azure AI Search

module "aisearch" {
  source   = "./modules/aisearch"
  name = var.aisearch_name
  location = var.rg_location
  rg_name  = azurerm_resource_group.rg.name
}

# ------------------------------------------ Azure CosmosDB

module "cosmos" {
  source  = "./modules/cosmos"
  name = var.cosmos_name
  rg_name = azurerm_resource_group.rg.name
}

# ------------------------------------------ Blob Storage

module "blobstorage" {
  source       = "./modules/blobstorage"
  rg_name      = azurerm_resource_group.rg.name
  location     = var.rg_location
  account_name = var.blobstorage_account_name
  sas_start    = "2024-09-25"
  sas_end      = "2024-12-31"
}

# ------------------------------------------ Document Intelligence

module "docintel" {
  source   = "./modules/documentintelligence"
  name     = var.docintel_name
  location = var.rg_location
  rg_name  = azurerm_resource_group.rg.name
}

# ------------------------------------------ AZURE OPENAI

module "openai" {
  source                        = "Azure/openai/azurerm"
  version                       = "0.1.4"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = "northcentralus"
  public_network_access_enabled = true
  deployment = {
    "chat_model" = {
      name          = "gpt-4o"
      model_format  = "OpenAI"
      model_name    = "gpt-4o"
      model_version = "2024-08-06"
      scale_type    = "GlobalStandard"
      capacity      = 450
    },
    "embedding_model" = {
      name          = "text-embedding-ada-002"
      model_format  = "OpenAI"
      model_name    = "text-embedding-ada-002"
      model_version = "2"
      scale_type    = "Standard"
      capacity      = 120
    },
  }
  depends_on = [
    azurerm_resource_group.rg,
  ]
}

# ------------------------------------------ App Service Plan

module "appserviceplan" {
  source   = "./modules/appserviceplan"
  name     = var.appserviceplan_name
  location = var.rg_location
  rg_name  = azurerm_resource_group.rg.name
}

module "docu_processing" {
  source                     = "./modules/appservicefunction"
  service_name               = var.functionapp_name
  rg_name                    = azurerm_resource_group.rg.name
  location                   = var.rg_location
  storage_account_access_key = module.blobstorage.BLOB_ADMIN_TOKEN
  storage_account_name       = module.blobstorage.BLOB_ACCOUNT_NAME
  appservice_plan_id         = module.appserviceplan.APPSERVICE_PLAN_ID
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    AzureWebJobsStorage                 = module.blobstorage.BLOB_CONNECTION_STRING
    storagenoventiq_STORAGE             = module.blobstorage.BLOB_CONNECTION_STRING
    BLOB_CONTAINER_SAS                  = module.blobstorage.BLOB_SAS_TOKEN
    FORM_RECOGNIZER_KEY                 = module.docintel.FORM_RECOGNIZER_KEY
    FORM_RECOGNIZER_ENDPOINT            = module.docintel.FORM_RECOGNIZER_ENDPOINT
    AZURE_OPENAI_API_VERSION            = "2024-05-01-preview"
    AZURE_OPENAI_API_KEY                = module.openai.openai_primary_key
    AZURE_OPENAI_ENDPOINT               = module.openai.openai_endpoint
    EMBEDDING_DEPLOYMENT_NAME           = "text-embedding-ada-002"
    AZURE_SEARCH_ENDPOINT               = module.aisearch.AZURE_SEARCH_ENDPOINT
    AZURE_SEARCH_KEY                    = module.aisearch.AZURE_SEARCH_KEY
    AZURE_SEARCH_API_VERSION            = "2024-05-01-preview"
    AZURE_SEARCH_INDEX                  = var.AZURE_SEARCH_INDEX
    COSMOS_CONNECTION_STRING            = module.cosmos.AZURE_COMOSDB_CONNECTION_STRING
    COSMOS_DATABASE_NAME                = "chatbot-system-log"
    COSMOS_CONTAINER_NAME               = "document-log"
  }
  image_name = var.functionapp_image
}

# ------------------------------------------ App Backend

module "app_backend" {
  source             = "./modules/appserviceapp"
  rg_name            = azurerm_resource_group.rg.name
  service_name       = var.app_backend_name
  location           = var.rg_location
  app_command_line   = ""
  appservice_plan_id = module.appserviceplan.APPSERVICE_PLAN_ID
  app_settings = {
    AZURE_SEARCH_API_VERSION    = "2024-05-01-preview"
    AZURE_OPENAI_API_VERSION    = "2024-05-01-preview"
    BING_SEARCH_URL             = "https://api.bing.microsoft.com/v7.0/search"
    BOT_DIRECT_CHANNEL_ENDPOINT = "https://directline.botframework.com/v3/directline"
    WEBSITES_PORT               = 3978
    PORT                        = 3978

    ## Azure AI Search
    AZURE_SEARCH_ENDPOINT = module.aisearch.AZURE_SEARCH_ENDPOINT
    AZURE_SEARCH_KEY      = module.aisearch.AZURE_SEARCH_KEY
    AZURE_SEARCH_INDEX    = var.AZURE_SEARCH_INDEX

    ## Blob Storage
    BLOB_SAS_TOKEN         = module.blobstorage.BLOB_SAS_TOKEN
    BLOB_CONNECTION_STRING = module.blobstorage.BLOB_CONNECTION_STRING

    ## Azure OpenAI
    AZURE_OPENAI_ENDPOINT   = module.openai.openai_endpoint
    AZURE_OPENAI_API_KEY    = module.openai.openai_primary_key
    AZURE_OPENAI_MODEL_NAME = "gpt-4o"

    ## Azure CosmosDB
    AZURE_COSMOSDB_ENDPOINT         = module.cosmos.AZURE_COSMOSDB_ENDPOINT
    AZURE_COSMOS_DATABASE_NAME      = "chatbot-system-log"
    AZURE_COSMOSDB_CONTAINER_NAME   = "conversation-history-log"
    AZURE_COMOSDB_CONNECTION_STRING = module.cosmos.AZURE_COMOSDB_CONNECTION_STRING

    ## Azure Bot
    BOT_SERVICE_DIRECT_LINE_SECRET = var.BOT_SERVICE_DIRECT_LINE_SECRET
    MICROSOFT_APP_ID               = var.MICROSOFT_APP_ID
    MICROSOFT_APP_PASSWORD         = var.MICROSOFT_APP_PASSWORD

    # No need to define variables below. just keep them as they are 
    BING_SUBSCRIPTION_KEY    = "IGNORE"
    SQL_SERVER_NAME          = "IGNORE"
    SQL_SERVER_DATABASE      = "IGNORE"
    SQL_SERVER_USERNAME      = "IGNORE"
    SQL_SERVER_PASSWORD      = "IGNORE"
    FORM_RECOGNIZER_ENDPOINT = "IGNORE"
    FORM_RECOGNIZER_KEY      = "IGNORE"

    # Frontend Only
    BLOB_URL            = "IGNORE"
    BLOB_ADMIN_TOKEN    = "IGNORE"
    BLOB_CONTAINER_NAME = "IGNORE"
  }
  docker_image_name = var.app_backend_image
}

# ------------------------------------------ App Frontend

module "app_frontend" {
  source             = "./modules/appserviceapp"
  rg_name            = azurerm_resource_group.rg.name
  service_name       = var.app_frontend_name
  location           = var.rg_location
  app_command_line   = ""
  appservice_plan_id = module.appserviceplan.APPSERVICE_PLAN_ID
  app_settings = {
    AZURE_SEARCH_API_VERSION    = "2024-05-01-preview"
    AZURE_OPENAI_API_VERSION    = "2024-05-01-preview"
    BING_SEARCH_URL             = "https://api.bing.microsoft.com/v7.0/search"
    BOT_DIRECT_CHANNEL_ENDPOINT = "https://directline.botframework.com/v3/directline"
    WEBSITES_PORT               = 8080
    PORT                        = 8080

    ## Azure AI Search
    AZURE_SEARCH_ENDPOINT = module.aisearch.AZURE_SEARCH_ENDPOINT
    AZURE_SEARCH_KEY      = module.aisearch.AZURE_SEARCH_KEY
    AZURE_SEARCH_INDEX    = var.AZURE_SEARCH_INDEX

    ## Blob Storage
    BLOB_SAS_TOKEN         = module.blobstorage.BLOB_SAS_TOKEN
    BLOB_CONNECTION_STRING = module.blobstorage.BLOB_CONNECTION_STRING

    ## Azure OpenAI
    AZURE_OPENAI_ENDPOINT   = module.openai.openai_endpoint
    AZURE_OPENAI_API_KEY    = module.openai.openai_primary_key
    AZURE_OPENAI_MODEL_NAME = "gpt-4o"

    ## Azure CosmosDB
    AZURE_COSMOSDB_ENDPOINT         = module.cosmos.AZURE_COSMOSDB_ENDPOINT
    AZURE_COSMOS_DATABASE_NAME      = "chatbot-system-log"
    AZURE_COSMOSDB_CONTAINER_NAME   = "conversation-history-log"
    AZURE_COMOSDB_CONNECTION_STRING = module.cosmos.AZURE_COMOSDB_CONNECTION_STRING

    ## Azure Bot
    BOT_SERVICE_DIRECT_LINE_SECRET = var.BOT_SERVICE_DIRECT_LINE_SECRET
    MICROSOFT_APP_ID               = var.MICROSOFT_APP_ID
    MICROSOFT_APP_PASSWORD         = var.MICROSOFT_APP_PASSWORD

    # No need to define variables below. just keep them as they are 
    BING_SUBSCRIPTION_KEY    = "IGNORE"
    SQL_SERVER_NAME          = "IGNORE"
    SQL_SERVER_DATABASE      = "IGNORE"
    SQL_SERVER_USERNAME      = "IGNORE"
    SQL_SERVER_PASSWORD      = "IGNORE"
    FORM_RECOGNIZER_ENDPOINT = "IGNORE"
    FORM_RECOGNIZER_KEY      = "IGNORE"

    # Frontend Only
    BLOB_URL            = module.blobstorage.BLOB_URL
    BLOB_ADMIN_TOKEN    = module.blobstorage.BLOB_ADMIN_TOKEN
    BLOB_CONTAINER_NAME = module.blobstorage.BLOB_CONTAINER_NAME
  }
  docker_image_name = var.app_frontend_image
}

provider "restapi" {
  uri                  = module.aisearch.AZURE_SEARCH_ENDPOINT
  write_returns_object = true
  debug                = true

  headers = {
    "api-key"      = module.aisearch.AZURE_SEARCH_KEY
    "Content-Type" = "application/json"
  }
}

locals {
  index_json = {
    name = var.AZURE_SEARCH_INDEX
    vectorSearch = {
      algorithms = [
        {
          name = "eknn"
          kind = "exhaustiveKnn"
          exhaustiveKnnParameters = {
            metric = "euclidean"
          }
        }
      ]
      vectorizers = [
        {
          name = "openai"
          kind = "azureOpenAI"
          azureOpenAIParameters = {
            resourceUri  = module.openai.openai_endpoint
            apiKey       = module.openai.openai_primary_key
            deploymentId = "text-embedding-ada-002"
            modelName    = "text-embedding-ada-002"
          }
        }
      ]
      profiles = [
        {
          name       = "my-vector-profile"
          algorithm  = "eknn"
          vectorizer = "openai"
        }
      ]
    }
    semantic = {
      configurations = [
        {
          name = "my-semantic-config"
          prioritizedFields = {
            titleField = {
              fieldName = "title"
            }
            prioritizedContentFields = [
              {
                fieldName = "chunk"
              }
            ]
            prioritizedKeywordsFields = []
          }
        }
      ]
    }
    fields = [
      {
        name       = "id"
        type       = "Edm.String"
        key        = true
        filterable = true
      },
      {
        name        = "title"
        type        = "Edm.String"
        searchable  = true
        retrievable = true
      },
      {
        name        = "chunk"
        type        = "Edm.String"
        searchable  = true
        retrievable = true
      },
      {
        name        = "name"
        type        = "Edm.String"
        searchable  = true
        retrievable = true
        sortable    = false
        filterable  = false
        facetable   = false
      },
      {
        name        = "location"
        type        = "Edm.String"
        searchable  = false
        retrievable = true
        sortable    = false
        filterable  = false
        facetable   = false
      },
      {
        name        = "page_num"
        type        = "Edm.Int64"
        searchable  = false
        retrievable = true
      },
      {
        name                = "chunkVector"
        type                = "Collection(Edm.Single)"
        dimensions          = 1536
        vectorSearchProfile = "my-vector-profile"
        searchable          = true
        retrievable         = true
        filterable          = false
        sortable            = false
        facetable           = false
      }
    ],
  }
}

resource "restapi_object" "create_index" {
  path         = "/indexes"
  query_string = "api-version=2024-05-01-preview"
  data         = jsonencode(local.index_json)
  id_attribute = "name" # The ID field on the response
}
