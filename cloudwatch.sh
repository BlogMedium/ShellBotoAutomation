#!/bin/bash

# Log all output for troubleshooting
exec > /var/log/user-data.log 2>&1

# Step 1: Retrieve the IMDSv2 token
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s)

# Step 2: Fetch the Instance ID and Region using the token
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)

INSTANCE_REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/region)



install_cloudwatch_agent() {
  local config_url="$1"
  local config_file="/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json"

  # Step 1: Install the CloudWatch Agent
  echo "Installing CloudWatch Agent..."
  sudo yum install -y amazon-cloudwatch-agent

  # Step 2: Download the configuration from S3 (if provided)
  if [[ -n "$config_url" ]]; then
    echo "Fetching CloudWatch Agent configuration from $config_url..."
    aws s3 cp "$config_url" "$config_file"

    # Replace placeholders with actual values
    echo "Replacing placeholders in the configuration..."
    sed -i "s/{instance_id}/$INSTANCE_ID/g" "$config_file"
    sed -i "s/{region}/$INSTANCE_REGION/g" "$config_file"
  fi

  # Step 3: Start the CloudWatch Agent
  echo "Starting CloudWatch Agent..."
  sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config -m ec2 \
    -c "file:$config_file" -s

  echo "CloudWatch Agent started in region: $INSTANCE_REGION"
}

# Run the function with the provided S3 URL
install_cloudwatch_agent "s3://userdatacdit/cloudwatch.json"
