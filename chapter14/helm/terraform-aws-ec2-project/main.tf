# 1. 사용할 프로바이더(AWS)와 리전을 선언합니다.
# 자격 증명은 `aws configure`로 설정한 것을 자동으로 사용합니다.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2" # 서울 리전
}

# 2. EC2 인스턴스의 기반이 될 AMI(Amazon Machine Image) 정보를 동적으로 조회합니다.
# 이렇게 하면 AMI ID가 바뀌어도 코드를 수정할 필요가 없습니다.
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical(Ubuntu)의 공식 계정 ID
}



# 4. 기존 보안 그룹을 참조합니다.
data "aws_security_group" "existing_sg" {
  id = "sg-0c6aa5c912ae35b40"
}

# 5. 생성할 EC2 인스턴스 리소스를 정의합니다.
# 위에서 정의한 키 페어와 기존 보안 그룹을 연결합니다.
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro" # 프리티어 사용 가능 유형
  key_name      = "aws-generated-key" # AWS에서 직접 생성한 키 페어 사용
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id] # 기존 보안 그룹 연결

  # 리소스를 쉽게 식별하기 위한 태그
  tags = {
    Name = "MyWebServer-Terraform"
  }
}

# 4. 생성된 인스턴스의 Public IP 주소를 출력합니다.
output "instance_public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "생성된 EC2 인스턴스의 Public IP 주소"
}
