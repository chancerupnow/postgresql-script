#!/bin/bash
###########################################################
# IMPORTANT NOTE:
# - This script will need to be updated/changed for
#   deploying to different environments/regions/etc
# - Make sure the S3 Bucket has been deployed the name
#   will be needed
# - Make sure the proper AWS ClI account has been configure
#   to interact with the AWS account
###########################################################

# Example Usage: AWS_PROFILE=data-test ./scripts/deployment/infrastructure-deploy.sh test

if [ $1 == "dev" ]
then
  . ./config/dev.cfg  # Source the appropriate config files
elif [ $1 == "test" ]
then
  . ./config/test.cfg
elif [ $1 == "prod" ]
then
  . ./config/prod.cfg
else
  echo "Unsupported environment given."
  exit 1
fi

export AWS_REGION=${region}

#AWS_CLI_PROFILE="awb-user"
#BUCKET="s3://${s3_deploy_bucket}" # The bucket name created in infrastructure-bucket-deploy.sh should go here
STACK_NAME="${env}-collections-vpc-infrastructure"
CF_TEMPLATE="./templates/vpc-infrastructure-template.yaml"
TEMPLATE_BUCKET_URL="http://${s3_deploy_bucket}.s3.amazonaws.com"
ORGANIZATION_NAME="Seerist"
APPLICATION_NAME="collections"
ENVIRONMENT_NAME=${env}
VPC_CIDR=${vpc_cidr}
VPC_PEER_CONNECTION_ID=${vpc_peer_connection_id}
VPC_PEER_CONNECTION_CIDR="172.31.0.0/16" # For the Geospark account VPC
PUBLIC_SUBNET_1_CIDR=${public_subnet_1_cidr}
PUBLIC_SUBNET_2_CIDR=${public_subnet_2_cidr}
PUBLIC_SUBNET_3_CIDR=${public_subnet_3_cidr}
PRIVATE_SUBNET_1_CIDR=${private_subnet_1_cidr}
PRIVATE_SUBNET_2_CIDR=${private_subnet_2_cidr}
PRIVATE_SUBNET_3_CIDR=${private_subnet_3_cidr}

###########################################################
# Upload nested stacks to S3 bucket.
###########################################################
echo "[${AWS_REGION}]> Uploading nested stack templates to S3 bucket ${BUCKET}/infrastructure-templates"
aws s3 cp --profile $AWS_PROFILE --recursive ./templates/components $BUCKET/infrastructure-templates

###########################################################
# Deploy/update Infrastructure Stack
###########################################################
echo "[${AWS_REGION}]> Deploying ${STACK_NAME} to ${AWS_REGION}"
# aws cloudformation deploy --template-file $CF_TEMPLATE  --stack-name $STACK_NAME\
#   --parameter-overrides TemplateBucketUrl=$TEMPLATE_BUCKET_URL OrganizationName=$ORGANIZATION_NAME\
#   EnvironmentName=$ENVIRONMENT_NAME ApplicationName=$APPLICATION_NAME UiDomainName=$UI_DOMAIN_NAME\
#   AcmCertificateArn=$ACM_CERTIFICATE_ARN VpcCIDR=$VPC_CIDR PublicSubnet1CIDR=$PUBLIC_SUBNET_1_CIDR\
#   PublicSubnet2CIDR=$PUBLIC_SUBNET_2_CIDR PrivateSubnet1CIDR=$PRIVATE_SUBNET_1_CIDR\
#   PrivateSubnet2CIDR=$PRIVATE_SUBNET_2_CIDR VpcPeerConnectionId=$VPC_PEER_CONNECTION_ID\
#   VpcPeerConnectionCIDR=$VPC_PEER_CONNECTION_CIDR\
#   --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND

echo ${ORGANIZATION_NAME}

aws cloudformation deploy --template-file $CF_TEMPLATE  --stack-name $STACK_NAME \
--parameter-overrides TemplateBucketUrl=$TEMPLATE_BUCKET_URL OrganizationName=$ORGANIZATION_NAME \
EnvironmentName=$ENVIRONMENT_NAME ApplicationName=$APPLICATION_NAME \
VpcCIDR=$VPC_CIDR \
PublicSubnet1CIDR=$PUBLIC_SUBNET_1_CIDR PrivateSubnet1CIDR=$PRIVATE_SUBNET_1_CIDR \
PublicSubnet2CIDR=$PUBLIC_SUBNET_2_CIDR PrivateSubnet2CIDR=$PRIVATE_SUBNET_2_CIDR \
PublicSubnet3CIDR=$PUBLIC_SUBNET_3_CIDR PrivateSubnet3CIDR=$PRIVATE_SUBNET_3_CIDR \
--capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND
