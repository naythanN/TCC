#!/bin/bash

# Retrieve a list of target group ARNs
target_group_arns=$(aws elbv2 describe-target-groups --query 'TargetGroups[].TargetGroupArn' | grep k8s | grep -oP "[A-z0-9-:/_]*")

# Iterate over each target group ARN
while IFS= read -r target_group_arn; do
  # Enable sticky sessions for the target group
  aws elbv2 modify-target-group-attributes --target-group-arn "$target_group_arn" --attributes Key=stickiness.enabled,Value=true Key=preserve_client_ip.enabled,Value=true

  echo "Enabled sticky sessions for target group: $target_group_arn"
done <<< "$target_group_arns"
