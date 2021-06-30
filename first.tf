# provider
provider "aws" {
    region  = "us-east-1"
    profile = "default"
}

# VPC and subnet, internet gateway, route table
resource "aws_vpc" "lwterra" {
    cidr_block = "10.0.0.0/16"
    tags       = {
        Name = "lwterra"
    }
}

resource "aws_internet_gateway" "lw_gw" {
  vpc_id = aws_vpc.lwterra.id
  tags = {
    Name = "lw_gw"
  }
}

resource "aws_subnet" "lw_subnet" {
    vpc_id     = aws_vpc.lwterra.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "lw_subnet"
    }
}

resource "aws_route_table" "lw_rt" {
    vpc_id = aws_vpc.lwterra.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.lw_gw.id
    }
    tags = {
        Name = "lw_rt"
    }
}
resource "aws_route_table_association" "a" {
    subnet_id      = aws_subnet.lw_subnet.id
    route_table_id = aws_route_table.lw_rt.id
}




# launching ec2 instance
resource "aws_instance" "lw_ins" {
  ami           = "ami-0ab4d1e9cf9a1215a"
  instance_type = "t2.micro"
  subnet_id  = aws_subnet.lw_subnet.id

  key_name = "av"
  security_groups = ["sg-04655af5225f516e7"]
  tags = {
    Name = "tf_ins"
  }
}
# configuring web serever using apache
resource "null_resource" "Resource_Items" {
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("C:/Users/hp/Downloads/av.pem")
    host = aws_instance.lw_ins.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      
      "sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "sudo yum install git -y",
      "sudo git clone https://github.com/AyushWahane/HTML.git /var/www/html/"
    ]
  }
}

#creating snapshot
resource "aws_ebs_snapshot" "lw_SS" {
  volume_id = #volume_id

  tags = {
    Name = "lw_SS"
  }
}

