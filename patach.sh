function os_updates {
  
  if  [[ $(uname -r | tr '[:upper:]' '[:lower:]') =~ "amzn1" ]] || [[ $(uname -r | tr '[:upper:]' '[:lower:]') =~ "amzn2" ]]; then
    yum install jq -y
  fi
  yum -y update
}

os_updates

