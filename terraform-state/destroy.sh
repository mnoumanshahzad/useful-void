#!/bin/bash

set -u

terraform init

cat >backend.tf <<EOL
    terraform {
      backend "local" {}
    }
EOL

terraform init -force-copy
