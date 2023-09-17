ip=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=vpc-0315997a1ba44c020" --query 'NatGateways[].NatGatewayAddresses[].PublicIp' | grep \" | grep -oP '[.0-9]*')
echo $ip


aws ec2 delete-nat-gateway --nat-gateway-id nat-0b87714b0538b5922