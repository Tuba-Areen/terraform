resource "aws_vpc" "name-1" {
  cidr_block = "10.0.0.0/16"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az = slice(data.aws_availability_zones.available.names, 0, 2)
}

resource "aws_subnet" "name-1" {
  vpc_id            = aws_vpc.name-1.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = local.az[0]
}

resource "aws_subnet" "name-2" {
  vpc_id            = aws_vpc.name-1.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = local.az[1]
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

resource "aws_route_table_association" "name-1" {
  subnet_id      = aws_subnet.name-1.id
  route_table_id = aws_route_table.name-1.id
}

resource "aws_security_group" "name-1" {
  vpc_id = aws_vpc.name-1.id

  ingress = [
    for port in [22, 3306, 80, 8080] :
    {
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      self             = false
      description      = "sg"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# # resource "aws_instance" "name-1" {
# #   subnet_id                   = aws_subnet.name-1.id
# #   associate_public_ip_address = true
# #   ami                         = data.aws_ami.available.id
# #   instance_type               = var.instance_type
# #   vpc_security_group_ids      = [aws_security_group.name-1.id]
# # }

resource "aws_db_subnet_group" "name-1" {
  subnet_ids = [aws_subnet.name-1.id, aws_subnet.name-2.id]
}

# data "aws_ami" "available" {
#   owners = ["amazon"]
#   most_recent = true
# }

resource "aws_db_instance" "name-1" {
  identifier              = "testdb"
  db_name                 = "test"
  db_subnet_group_name    = aws_db_subnet_group.name-1.id
  allocated_storage       = 5
  backup_window           = "01:00-02:00"
  engine                  = "mysql"
  backup_retention_period = 1
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = "Cloud12345"
  # manage_master_user_password = true
  skip_final_snapshot = true
}

# resource "aws_db_instance" "read_Replica" {
#   identifier= "readreplica"
#   instance_class = aws_db_instance.name-1.instance_class
#   engine = "mysql"
#   # db_subnet_group_name = aws_db_subnet_group.name-1.name
#   replicate_source_db = aws_db_instance.name-1.arn
#   region = "us-east-2"
#   skip_final_snapshot= true
# }

# resource "aws_s3_bucket" "name-1" {
#   bucket = "terraformasefcxzcsa"
#   force_destroy = true
# }







