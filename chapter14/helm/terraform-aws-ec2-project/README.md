# Terraform AWS EC2 생성 프로젝트

이 프로젝트는 Terraform을 사용하여 AWS 서울 리전(ap-northeast-2)에 `t2.micro` 타입의 EC2 인스턴스 한 대를 생성합니다.

## 사전 준비 사항

1.  **Terraform 설치**: 로컬 PC에 Terraform이 설치되어 있어야 합니다.
2.  **AWS CLI 설치 및 구성**: 로컬 PC에 AWS CLI가 설치되고, `aws configure` 명령어를 통해 액세스 키가 설정되어 있어야 합니다. 이 프로젝트는 해당 설정을 자동으로 사용합니다.

## 실행 방법

1.  터미널에서 이 폴더(`terraform-aws-ec2-project`)로 이동합니다.

2.  **Terraform 초기화**
    AWS 프로바이더를 다운로드합니다.
    ```bash
    terraform init
    ```

3.  **실행 계획 확인**
    어떤 리소스가 생성될지 미리 확인합니다.
    ```bash
    terraform plan
    ```

4.  **인프라 적용**
    실제로 EC2 인스턴스를 생성합니다. `yes`를 입력하여 확인합니다.
    ```bash
    terraform apply
    ```
    완료되면 생성된 EC2 인스턴스의 Public IP가 화면에 출력됩니다.

## 리소스 삭제

테스트가 끝난 후, 불필요한 비용이 발생하지 않도록 반드시 아래 명령어를 실행하여 생성된 리소스를 삭제하세요.

```bash
terraform destroy
```
