
provider "aws" {
  region = "eu-central-1"
}


resource "aws_appsync_graphql_api" "demoAPI" {
  name                = "demo-emptyquery-api"
  authentication_type = "API_KEY"

  schema = <<EOF
type Query {}

type Mutation {
  test: String @aws_auth
}

schema {
  query: Query
  mutation: Mutation
}
EOF
}

resource "aws_appsync_api_key" "demoAPI" {
  api_id  = aws_appsync_graphql_api.demoAPI.id
  expires = timeadd(timestamp(), "${24 * 354}h")
}

resource "aws_appsync_datasource" "demoNone" {
  name   = "SourceNone"
  type   = "NONE"
  api_id = aws_appsync_graphql_api.demoAPI.id
}

resource "aws_appsync_function" "demoTest" {
  api_id      = aws_appsync_graphql_api.demoAPI.id
  data_source = aws_appsync_datasource.demoNone.name
  name        = "test"
  code        = file("${path.module}/mutation/test.js")

  runtime {
    name            = "APPSYNC_JS"
    runtime_version = "1.0.0"
  }
}

resource "aws_appsync_resolver" "demoTest" {
  type              = "Mutation"
  field             = "test"
  kind              = "PIPELINE"
  api_id            = aws_appsync_graphql_api.demoAPI.id
  request_template  = "{}"
  response_template = "$util.toJson($ctx.result)"

  pipeline_config {
    functions = [aws_appsync_function.demoTest.function_id]
  }
}
