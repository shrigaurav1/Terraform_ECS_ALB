terraform {
 backend "s3" {
 bucket = "ecsmodule"
 key = "terraform_ecs_alb.tfstate"
 region = "us-west-2"
 dynamodb_table = "moduleog"
 }
}