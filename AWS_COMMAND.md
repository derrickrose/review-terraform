# Command to list available instance types withing the free tiels

## EC2

- ec2 instance types within the free tier

```shell
aws ec2 describe-instance-types --filters Name=free-tier-eligible,Values=true | jq '.InstanceTypes[] | .InstanceType'
```

```shell
aws ec2 describe-instance-types --filters Name=free-tier-eligible,Values=true --output text --query 'InstanceTypes[*].InstanceType'
```

- Ordered by Performance (Larger to Less Performant)

1. `c7i-flex.large` - compute optimized, 2 vCPUs, Intel, current generation
2. `m7i-flex.large` - general purpose, 2 vCPUs, Intel, current generation
3. `t4g.small` - burstable, 2 vCPUs, ARM (Graviton), newer generation
4. `t3.small` - burstable, 2 vCPUs, Intel, older generation
5. `t4g.micro` - burstable, 1 vCPU, ARM (Graviton), newer generation
6. `t3.micro` - burstable, 1 vCPU, Intel, older generation
