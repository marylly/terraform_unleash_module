terraform {
  required_providers {
    unleash = {
      source = "philips-labs/unleash"
      version = ">= 0.3.6"
    }
  }
}

provider "unleash" { }