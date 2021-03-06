# tf-sample-web-app
Repo contains terraform files (.tf) for a web based application.

## Design Principles
Basic web application that has frontend and backend instances in public and private subnets respectively. The backend instances are auto-scaled and both tiers are using ALBs to manage load across the instances (2 for each tier). 

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
