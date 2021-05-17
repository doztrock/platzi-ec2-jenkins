data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    ]
  }
  filter {
    name = "root-device-type"
    values = [
      "ebs"
    ]
  }
  filter {
    name = "virtualization-type"
    values = [
      "hvm"
    ]
  }
  owners = [
    "099720109477"
  ]
}

module "sg-jenkins" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"

  name   = "jenkins-sg"
  vpc_id = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "all-icmp"]

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "18.206.107.24/29"
      description = "EC2_INSTANCE_CONNECT"
    },
    {
      rule        = "ssh-tcp"
      cidr_blocks = var.PUBLIC_IP
    }
  ]

  egress_rules = ["all-all"]

  tags = local.tags
}

module "key-jenkins" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "1.0.0"

  key_name   = "jenkins-key"
  public_key = var.SSH_PUBLIC_KEY

  tags = local.tags
}

module "ec2-jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.19.0"

  name = "jenkins-ec2"

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.small"

  key_name = module.key-jenkins.key_pair_key_name

  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  associate_public_ip_address = true

  vpc_security_group_ids = [module.sg-jenkins.security_group_id]

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 30
    }
  ]

  tags        = local.tags
  volume_tags = local.tags
}

resource "aws_eip" "eip-jenkins" {
  vpc      = true
  instance = module.ec2-jenkins.id[0]
  tags     = local.tags
}
