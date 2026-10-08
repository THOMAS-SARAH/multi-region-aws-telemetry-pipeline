locals {
  node_exporter_user_data = <<-USERDATA
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y wget tar

    NODE_EXPORTER_VERSION="1.8.2"
    cd /tmp
    wget https://github.com/prometheus/node_exporter/releases/download/v$${NODE_EXPORTER_VERSION}/node_exporter-$${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
    
    tar -xvf node_exporter-$${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
    mv node_exporter-$${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
    
    useradd --no-create-home --shell /bin/false node_exporter || true
    chown node_exporter:node_exporter /usr/local/bin/node_exporter

    cat <<SERVICE_EOF > /etc/systemd/system/node_exporter.service
    [Unit]
    Description=Node Exporter
    Wants=network-online.target
    After=network-online.target

    [Service]
    User=node_exporter
    Group=node_exporter
    Type=simple
    ExecStart=/usr/local/bin/node_exporter

    [Install]
    WantedBy=multi-user.target
    SERVICE_EOF

    systemctl daemon-reload
    systemctl enable node_exporter
    systemctl start node_exporter
  USERDATA
}

data "aws_ami" "ubuntu_virginia" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "sg_virginia" {
  name        = "worker-node-sg-virginia"
  description = "Allow SSH and Node Exporter"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "worker_virginia" {
  ami                    = data.aws_ami.ubuntu_virginia.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_virginia.id]
  user_data              = local.node_exporter_user_data

  tags = {
    Name = "Worker-Node-Virginia"
    Role = "Prometheus-Target"
  }
}

data "aws_ami" "ubuntu_mumbai" {
  provider    = aws.mumbai
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "sg_mumbai" {
  provider    = aws.mumbai
  name        = "worker-node-sg-mumbai"
  description = "Allow SSH and Node Exporter"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "worker_mumbai" {
  provider               = aws.mumbai
  ami                    = data.aws_ami.ubuntu_mumbai.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_mumbai.id]
  user_data              = local.node_exporter_user_data

  tags = {
    Name = "Worker-Node-Mumbai"
    Role = "Prometheus-Target"
  }
}
