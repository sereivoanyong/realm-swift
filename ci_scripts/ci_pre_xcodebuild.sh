#!/bin/bash

set -eo pipefail

env

if [[ "$CI_WORKFLOW" == "sync"* ]]; then
    ruby scripts/setup_baas.rb
fi
