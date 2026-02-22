# learn terraform

https://www.linkedin.com/learning/learning-terraform-15575129

# aws account

basic root profile for Derrick-rose1
login url : https://503122375317.signin.aws.amazon.com/console
account id : 503122375317
admin user : frils-mikirakira-admin
local profile : frils-mikirakira-admin
root : ahf.ampilahy@gmail.com
pass: passnormal2025

# terraform cloud

- terraform.io
- app.terraform.io # for workspace, run code ...
- registry.terraform.io # for module

# directory 02_01

---

- terraform init : initializes the working directory, downloads required provider plugins, and sets up the backend for state storage.
- terraform plan : shows what changes Terraform will make to your infrastructure (dry run). Displays added, modified, or deleted resources.
- terraform apply : executes the changes shown in the plan. Creates, updates, or destroys actual infrastructure resources.

## how terraform works

- define resources based on other resources even if they do not exist yet
- figuring out the hard part of resource ordering and lets you just treat the infrastructure as static code
- taking the infra describing the code, and compare to the state of what actually exists and essentially writing step by step script to make the changes
- the plan is critical since it describes what will be done and in what order, by using a datasctructure know as a graph (DAG)

## terraform states

- running a terraform, if figures out what changes to made based on the code
- running it the second time, it have to figure out what have changed
- to keep track of the infrastructure comes the notion of state "tfstate file"
- JSON state file (after terraform apply)

## variables

```terraform
variable "instance_type" {
    description = "The instance type to create"
    default = "t3.nano"
}
```

````

## outputs

```terraform
output "instance_ami" {
    value = aws_instance.web.ami
}
````

```terraform
output "instance_arn" {
    value = aws_instance.web.arn
}
```

## how to use variables

By just calling var.variable_name, let's modify the code bellow using variable "instance_type" defined inside variables.tf

- before

  ```terraform
  resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t3.nano"

  tags = {
      Name = "HelloWorld"
  }
  }
  ```

- using variable

  ```terraform
  resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  tags = {
      Name = "HelloWorld"
  }
  }
  ```

## errors

- scenario : we changed the name of the aws_instance from "web" to "blog", then push so terraform apply will fail
- 2 errors :
  - reference to undeclared resource on aws_instance.web.ami (recall we changed web to blog)

    ```text
    Error: Reference to undeclared resource

       on outputs.tf line 6, in output "instance_arn":
        6:   value = aws_instance.web.arn

    A managed resource "aws_instance" "web" has not been declared in the root module.
    ```

  - reference to undeclared resource on aws_instance.web.arn

- error contains line number and also a suggestion of how to resolve the issue

## resources

- building blocks of terraform code
- define the what of your infra and terraform figures out the how
- same syntax, different settings for every provider

```terraform
    provider "aws" {
    profile = "default"
    region = "eu-west-3"
    }
```

```terraform
    resource "aws_s3_bucket" "mikirakira_bronze" {
        bucket = "dev-eu-west-3-mikirakira-bronze"
        acl = "private"
    }
```

## basic resource types

- A static website hosted on s3 bucket

  ```terraform
      resource "aws_s3_bucket" "mikirakira_web" {
          bucket = "dev-eu-west-3-mikirakira-web"
          acl = "public-read"
          policy = file("policy.json") # from external json file
      }

        # previous terraform version, this conf is defined within the bucket resource
        # the benefit is updating without worrying of file deletion inside the bucket
      resource "aws_s3_bucket_website_configuration" "mikirakira_web_conf" {
          bucket = aws_s3_bucket.mikirakira_web.bucket # recall the resource earlier the mikirakira_web s3 bucket
          index_document {
              suffix = "index.html" # so that s3 will know which files to use as index page of the public facing web site
          }
      }
  ```

- VPC

  ```terraform
      resource "aws_vpc" "mikirakira_net_qa" {
          cidr_block = "10.0.0.0/16"
      }

      resource "aws_vpc" "mikirakira_net_staging" {
          cidr_block = "10.1.0.0/16"
      }
  ```

- Security Group (can be seen as firewall)

  ```terraform
      resource "aws_security_group" "allow_tls" {
        ingress {
            from_port = 443
            to_port = 443
            protocol = "tcp"
            cidr_blocks ["1.2.3.4/32"]
        }
        egress {#outbounds traffic to any protocol to anyport
            from_port = 0
            to_port = 0
            protocol = "-1"
        }
      }
  ```

- similarly to how s3 bucket was defined, security group also can be defined separately

  ```terraform
      resource "aws_security_group" "allow_tls" { }
      resource "aws_security_group_rule" "https_inbounds" {
        type = "ingress"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["1.2.3.4/32"]
        security_group_id = aws_security_group.allow_tls.id
     }
  ```

- AWS instance (using dynamic variable)

  ```terraform
      resource "aws_instance" "web" {
        ami = data.aws_ami.ubuntu.id # base image to use but for this case we used variable, which can be defined in a static file aside our tf code or tf code to dynamically lookup for the latest official ubuntu AMI
        instance_type = "t3.nano" # how big is the computer
      }
  ```

- AWS elastic Ip (Dynamic Syntax)

  ```terraform
      resource "aws_eip" "web" {
        instance = aws_instance.web.id # for this case we used variables, so that web instance can be terminated, then redeployed then assigned the ip again
        vpc = true
      }
  ```

## terraform style

- 2 spaces to indent
- meta argument for example inside the code bellow the argument count, standard argument to define what terraform pass to the provider
- another way of using meta arguments is to explicitly define a relationship between two resources so that terraform knows to provision one before the other
- single meta argument like count
- block meta-arguments should be at the end of the resource
- use blank lines to separate the code and make it more readable
- group single arguments
- think about readability
- line up equal signs

  ```terraform
      resource "aws_instance" "web" {
        count = 2 # meta argument

        # standard arguments
        ami = data.aws_ami.ubuntu.id # base image to use but for this case we used variable, which can be defined in a static file aside our tf code or tf code to dynamically lookup for the latest official ubuntu AMI
        instance_type = "t3.nano" # how big is the computer


        ## meta arguments block
      }
  ```

# directory 03_04

Setting up security group

- calling the default vpc using data
- creating security group
- defining ingress and egress
- creating instance
- setting security group to the instance

# directory 03_07

## modules

- Terraform feature that let you combine some of your code in a separate directory that can be managed together
- You can bundle together some logical block of codes, and pass in arguments that apply for that block
- work like custom resources
- all terraform code has at list one module known as root
- how to call a module

```terraform
  module "web_server" {
    source = "./modules/servers" # tell terraform where to find the module

    web_ami = "ami-12345"
    server_name = "prod-web"

  }
```

- defining a module:
  - creating input variables
  - module can output values
  - important !!! you cannot directly access data from a module unless it was set up as an output value
  - the content of a module is encapsulated and work as black box
  - so if you need data elswhere in your code, be sure it was set as output value
  - same rule apply for the inputs, if you need data in the module, make sure you pass in a variable
  - to use an output from a module, call it with module.resource_name....
  - creating a module, the minimum files are :
    - main.tf
    - variables.tf
    - output.tf
    - README.md
    - no need to document inputs and outputs, it can be auto-generated
    - a complex module can nest some other modules
  - it is possible to use remote resource like s3 bucket or git repo for a module
  - there is a detailed guidance in the docs on how to use versioning to ensure that the module is actually what you'd expect
  - a module can include a provider block, even set a specific version for that provider, but its recommended to set a provider in root module
  - there is terraform registry where you can find pre-made module for managing all sorts of infra registry.terraform.io

    ```terraform
      # creating input variables
      variable "web_ami" {
        type = string
        default = "ami-abc123"
      }

      variable "server_name" {
        type = string
        default = "web"
      }
    ```

    ```terraform
      # outputing values ec2 instance and s3 bucket
      output "instance_public_ip" {
        value = aws_instance.web.public_ip
      }

      output "app_bucket" {
        value = aws_s3_bucket.web.bucket
      }
    ```

    ```terraform
      # using a variable outputed by a module
      resource "aws_route53_record" "www" {
        name = "www.example.com"
        zone_id = aws_route53_zone.main.zone_id
        type = "A"
        ttl = "300"
        records = [module.web.public_ip]
      }
    ```

## terraform registry: providers

go to registry.terraform.io then click on browse providers, there is 3 kind of providers :

- official (aws, azeure, gcp, kubernetes)
- partner (can be actually maintained by Hashicorp)
- community
- note: kubernetes is not really a provider, it is more public service
- so you can use aws provider to deploy kubernetes on aws, then use kubernetes provider to manage the cluster
- there is also documentation there, like resource and data (deployed infra)

## terraform registry: modules

- we are going to use module to simplify our code
- go to registry.terraform.io then click on browse modules, filter down to aws provider, scroll down then click on your desired module (security-group for our case)
- we can see the inputs, outputs, etc for the module ...
- we can see some basic example use
- we can see how to call the module on the section Provision Instructions
- now go to Feature, we need rule so click on Named rules
- then copy and paste the arguments needed to set up our rule ..
- VERY IMPORTANT !!! do not forget to init first since it have to install the module
