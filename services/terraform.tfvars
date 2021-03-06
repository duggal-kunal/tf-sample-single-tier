owner="kunal.duggal"
stage="stg"
service="sample"
region="us-west-2"
profile="vdsvcfpt"
component="test"

prefix="tf"
creator="terraform"

az1="us-west-2b"
az2="us-west-2c"

elb_name_all="tf-stg-sample-all-elb"
sg_elb_name_all="tf-elbsg-stg-sample-all"

ami_openapi = "ami-074909ffb47ae3210"
instance_type_openapi = "c5.xlarge"
elb_name_openapi = "tf-stg-sample-oregon-openapi"
sg_elb_name_openapi = "tf-elbsg-stg-sample-elb-oregon-openapi"
openapi_key="oregon-stg-sample-openapi"
target_group_name_openapi ="tf-tg-stg-sample-oregon-openapi"

ami_backend = "ami-0354ae58f2d8d8ea9"
instance_type_backend = "c5.xlarge"
backend_key="oregon-stg-sample-backend"
target_group_name_backend = "tf-tg-stg-sample-oregon-backend"

ami_gateway = "ami-06e3bc3e4d4493953"
instance_type_gateway = "c5.large"
gateway_key="oregon-stg-sample-gateway"