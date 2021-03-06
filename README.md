# tf-sample-web-app
Repo contains terraform files (.tf) for a web based application.

## Design Principles
> Basic web application that has frontend and backend instances in public and private subnets respectively. The backend instances are auto-scaled and both tiers are using ALBs to manage load across the instances (2 for each tier). 

## Features
- Minimum ports used for communication (80, 443, 8092 [application])
- Use of individual modules and variables instead of hardcoded values/names (scalable)
- Separation of TF files (per resource) for managable code changes
- Backend configured for S3
- Root priviledges not required
- Security
- Appropriate comments and proper naming conventions followed

## Infra Module
**Role:** Creates resources such as VPC and Subnets.

## Services Module:
**Role:** Creates underlying infrastructure such as EC2 and ELBs.

### Initialize (download plugins & create backend)
```terraform init```

### Plan (see changes)
```terraform plan```

### Apply Changes
```terraform apply```

### Check for specific module
```
terraform plan -target module.module_name
terraform apply -target module.module_name
```
