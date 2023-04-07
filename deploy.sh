#!/bin/bash

set -e

export RED='\033[1;31m'
export CYAN='\033[1;36m'
export GREEN='\033[1;32m'
export NC='\033[0m' # No Color
function log_red() { echo -e "${RED}$@${NC}"; }
function log_cyan() { echo -e "${CYAN}$@${NC}"; }
function log_green() { echo -e "${GREEN}$@${NC}"; }

SCRIPT_DIR=$(dirname $(readlink -f $0 2>/dev/null) 2>/dev/null || echo "${PWD}/$(dirname $0)")

cd "${SCRIPT_DIR}"

# Fetch any Secret Manager secrets named ${PKR_VAR_name?}-pkrvars* and same them to .auto.pkrvars.hcl files.
for secret in $(gcloud -q secrets list --filter=name~${PKR_VAR_name?}-pkrvars- --format="value(name)"); do
    latest=$(gcloud secrets versions list ${secret} --sort-by=created --format='value(name)' --limit=1)
    dest="${PACKER_IMAGE}/${secret/${PKR_VAR_name?}-pkrvars-/}.auto.pkrvars.hcl"
    log_cyan "Creating ${dest} from secret: ${secret}"
    gcloud -q secrets versions access ${latest} --secret ${secret} > ${dest}
done

# Print packer version
packer --version

# Fetch HCP_CLIENT_ID and HCP_CLIENT_SECRET from Secret Manager
export HCP_CLIENT_ID=$(gcloud -q secrets versions access latest --secret HCP_CLIENT_ID)
export HCP_CLIENT_SECRET=$(gcloud -q secrets versions access latest --secret HCP_CLIENT_SECRET)

export HCP_ORGANIZATION_ID=$(gcloud -q secrets versions access latest --secret HCP_ORGANIZATION_ID)
export HCP_PROJECT_ID=$(gcloud -q secrets versions access latest --secret HCP_PROJECT_ID)

if [[ -z "${HCP_CLIENT_ID}" || -z "${HCP_CLIENT_SECRET}" || -z "${HCP_ORGANIZATION_ID}" || -z "${HCP_PROJECT_ID}" ]]; then
    log_red "HCP_CLIENT_ID, HCP_CLIENT_SECRET, HCP_ORGANIZATION_ID and HCP_PROJECT_ID must be set to publish to HCP. Disabling HCP publishing."
    export HCP_PACKER_REGISTRY="OFF"
fi

if [[ "${PKR_VAR_promote_image}" == "false" ]]; then
    log_cyan "PKR_VAR_promote_image is false. Disabling publishing to HCP."
    export HCP_PACKER_REGISTRY="OFF"
fi

if [[ "${PKR_VAR_custom_source_image}" != "" ]]; then
    log_cyan "PKR_VAR_custom_source_image was defined. Using ${PKR_VAR_custom_source_image} as source image"
fi

# Set default project for google provider.
export GOOGLE_PROJECT=${PKR_VAR_project_id?}

packer init ${PACKER_IMAGE?}

if [[ "${ACTION?}" == "validate" ]]; then
    log_cyan "Running packer validate..."
    packer validate ${PACKER_IMAGE?}
elif [[ "${ACTION?}" == "build" ]]; then
    log_cyan "Running packer build..."
    packer build -force ${PACKER_IMAGE?}
fi

log_green "Done"