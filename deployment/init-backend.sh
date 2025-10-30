#!/bin/bash
# Terraform Backend Initialization Helper
# This script loads credentials and initializes Terraform backend

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Terraform Backend Initialization${NC}"
echo "=================================="
echo ""

# Check for credentials file
CREDS_FILE="$HOME/.oci/terraform-backend-credentials"
if [ ! -f "$CREDS_FILE" ]; then
    echo -e "${RED}ERROR: Credentials file not found: $CREDS_FILE${NC}"
    echo "Please create this file with your OCI Customer Secret Keys"
    exit 1
fi

# Load credentials
echo -e "${YELLOW}Loading backend credentials...${NC}"
source "$CREDS_FILE"

# Verify credentials are loaded
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo -e "${RED}ERROR: Credentials not properly loaded${NC}"
    echo "Check your credentials file: $CREDS_FILE"
    exit 1
fi

echo -e "${GREEN}✓${NC} Credentials loaded"

# Get namespace
echo -e "${YELLOW}Getting Object Storage namespace...${NC}"
NAMESPACE=$(oci os ns get --query "data" --raw-output)
echo -e "${GREEN}✓${NC} Namespace: $NAMESPACE"

# Verify bucket exists
echo -e "${YELLOW}Verifying state bucket exists...${NC}"
if oci os bucket get --bucket-name terraform-state --namespace-name "$NAMESPACE" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} State bucket exists"
else
    echo -e "${RED}ERROR: State bucket 'terraform-state' not found${NC}"
    echo "Please create the bucket following TERRAFORM_REMOTE_STATE_SETUP.md"
    exit 1
fi

# Update backend.tf with namespace
echo -e "${YELLOW}Updating backend.tf with namespace...${NC}"
REGION=$(oci iam region-subscription list \
  --query 'data[?"is-home-region"==`true`]."region-name" | [0]' \
  --raw-output)
ENDPOINT="https://${NAMESPACE}.compat.objectstorage.${REGION}.oraclecloud.com"

# Note: This would need actual file editing - showing concept
echo -e "${YELLOW}Please ensure backend.tf endpoint is set to:${NC}"
echo "  endpoint = \"$ENDPOINT\""
echo ""

# Export credentials for terraform
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

# Now safe to run terraform init
echo -e "${GREEN}Ready to initialize Terraform backend${NC}"
echo ""
echo "Run one of:"
echo "  terraform init                    # If first-time setup"
echo "  terraform init -migrate-state     # If migrating from local state"
echo "  terraform init -reconfigure       # If reconfiguring backend"
