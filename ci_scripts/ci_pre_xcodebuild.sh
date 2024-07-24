#!/bin/bash

set -eo pipefail

env

if [[ "$CI_WORKFLOW" == "sync"* ]]; then
    pwd
    cd ..
    pwd
    sh build.sh setup-baas
    sh build.sh download-core
fi
