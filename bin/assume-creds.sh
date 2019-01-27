#! /bin/bash

set -o errexit \
    -o nounset

if [[ $# < 2 ]] ; then
  echo 'usage: aws-assume-role <aws-account> <cosmos-accounts-mfa-token-code>
  Run on your laptop, then paste into your cpair.
'
  exit 1
fi

IAM_USERNAME="jacklund"
COSMOS_ACCOUNTS_ID=009737888067

account=$1
token_code=$2
mfa_device_serial_number_clause="--serial-number arn:aws:iam::${COSMOS_ACCOUNTS_ID}:mfa/${IAM_USERNAME}"

case $account in

  experimental)
    role_to_assume="infra-admin"
    account_id=179734101033
    ;;
  dev)
    role_to_assume="infra-admin"
    account_id=782759316251
    ;;
  sandbox)
    role_to_assume="infra-admin"
    account_id=303892774901
    ;;
  production)
    role_to_assume="infra-admin"
    account_id=123910207971
    ;;
  auth)
    role_to_assume="Deployer"
    account_id=565094359779
    ;;
  cosmos-accounts)
    role_to_assume="Administrator"
    account_id=$COSMOS_ACCOUNTS_ID
    ;;
  splunk)
    role_to_assume="infra-admin"
    account_id=195526673873
    ;;
  *)
    echo "unknown account: $account"
    exit 1
    ;;
esac

resp="$(aws sts assume-role --role-arn arn:aws:iam::${account_id}:role/${role_to_assume} --role-session-name ${account} ${mfa_device_serial_number_clause} --token-code ${token_code})"

echo "export AWS_ACCESS_KEY_ID=$(echo $resp | jq .Credentials.AccessKeyId)"
echo "export AWS_SECRET_ACCESS_KEY=$(echo $resp | jq .Credentials.SecretAccessKey)"
echo "export AWS_SESSION_TOKEN=$(echo $resp | jq .Credentials.SessionToken)"
echo "export AWS_SECURITY_TOKEN=$(echo $resp | jq .Credentials.SessionToken)"
echo "export COSMOS_ACCOUNT=${account}"
echo "export AWS_ACCOUNT_ID=${account_id}"


echo "[default]"
echo "aws_access_key_id=$(echo $resp | jq -r .Credentials.AccessKeyId)"
echo "aws_secret_access_key=$(echo $resp | jq -r .Credentials.SecretAccessKey)"
echo "aws_session_token=$(echo $resp | jq -r .Credentials.SessionToken)"
echo "aws_security_token=$(echo $resp | jq -r .Credentials.SessionToken)"
echo "COSMOS_ACCOUNT=${account}"
echo "aws_account_id=${account_id}"
