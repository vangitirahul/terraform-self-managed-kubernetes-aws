#!/bin/bash
set -euo pipefail

# Wait for master bootstrap
ssh -i "$KEY_PATH" ec2-user@"$MASTER_IP" \
  "sudo cloud-init status --wait"

# Wait for worker bootstrap
ssh -i "$KEY_PATH" ec2-user@"$WORKER_IP" \
  "sudo cloud-init status --wait"

# Generate a short-lived join command
JOIN_COMMAND=$(ssh -i "$KEY_PATH" \
  ec2-user@"$MASTER_IP" \
  "sudo kubeadm token create --ttl 15m --print-join-command")

# Register worker
ssh -i "$KEY_PATH" ec2-user@"$WORKER_IP" \
  "sudo $JOIN_COMMAND"

echo "Worker registration completed"
