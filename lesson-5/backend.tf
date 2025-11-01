terraform {
  backend "s3" {
    bucket         = "ваше ім'я"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}


