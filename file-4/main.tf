#iam role
resource "aws_iam_role" "name-1" {
  name               = "test_role-ec2-s3"
  assume_role_policy = jsonencode ({
        "Version" : "2012-10-17",
        "Statement" : [{
            "Action" : "sts:AssumeRole",
            "Effect" : "Allow",
            "Principal" : {
                "Service" : "ec2.amazonaws.com"
            }
            },
        ]
        })
}

#create policy

resource "aws_iam_policy" "name-1" {
  name = "ec2-s3"
  path = "/"
  # service= ec2
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect"  : "Allow",
      "Action"   : ["s3:*"],
      "Resource" : "*"

    }]
  })
}

# attach policy
resource "aws_iam_role_policy_attachment" "name-1" {
  role       = aws_iam_role.name-1.name
  policy_arn = aws_iam_policy.name-1.arn
}


# instance profile
resource "aws_iam_instance_profile" "name-1" {
    name = "test_profile_ec2_s3"
    role= aws_iam_role.name-1.name
}

# role association

resource "aws_instance" "name-1" {
  ami                    = data.aws_ami.name-1.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.name-1.id]
  iam_instance_profile   = aws_iam_instance_profile.name-1.name
  subnet_id              = aws_subnet.name-1.id

}

resource "aws_vpc" "name-1" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "name-1" {
  vpc_id     = aws_vpc.name-1.id
  cidr_block = "10.0.0.0/24"
}

resource "aws_security_group" "name-1" {
  vpc_id = aws_vpc.name-1.id
  name   = "allow"

  ingress = [
    for port in [22, 80, 3306] : {
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "allow"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false

  }]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_internet_gateway" "name-1" {
  vpc_id = aws_vpc.name-1.id
}

resource "aws_route_table" "name-1" {
  vpc_id = aws_vpc.name-1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.name-1.id
  }
}


# fetch ami id

data "aws_ami" "name-1" {
    most_recent = true
    owners = ["amazon"]

    filter {
      name= "architecture"
      values = ["x86_64"]
    }
}