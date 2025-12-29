#!/bin/bash

# --- Input variables (similar to core.getInput) ---
ACTION=$1          # 'add' or 'remove'
SG_ID=$2           # Your AWS Security Group ID (replaces Firewall ID)
IP_ADDRESS=$3      # The IP address (e.g., 1.2.3.4)

# Validate inputs
if [[ -z "$ACTION" || -z "$SG_ID" || -z "$IP_ADDRESS" ]]; then
    echo "Current inputs: $0 $1 $2 $3"
    echo "Usage: $0 <add|remove> <security_group_id> <ip_address>"
    exit 1
fi

# Convert IP to CIDR format (single host /32)
CIDR="$IP_ADDRESS/32"

# --- Functions (similar to addRule / removeRule) ---

add_rule() {
    echo "Adding IP $CIDR to Security Group $SG_ID on port 22..."
    aws ec2 authorize-security-group-ingress \
        --group-id "$SG_ID" \
        --protocol tcp \
        --port 22 \
        --cidr "$CIDR" \
        --description "Github Action Temp Access"
}

remove_rule() {
    echo "Removing IP $CIDR from Security Group $SG_ID on port 22..."
    aws ec2 revoke-security-group-ingress \
        --group-id "$SG_ID" \
        --protocol tcp \
        --port 22 \
        --cidr "$CIDR"
}

# --- Execute logic ---

case "$ACTION" in
    add)
        add_rule
        ;;
    remove)
        remove_rule
        ;;
    *)
        echo "Error: Action must be 'add' or 'remove'"
        exit 1
        ;;
esac

# Status check (similar to core.setOutput)
if [ $? -eq 0 ]; then
    echo "Status: success"
else
    echo "Status: failed"
    exit 1
fi
