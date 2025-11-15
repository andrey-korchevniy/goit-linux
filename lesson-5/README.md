## Опис структури проєкту

```
lesson-5/
  backend.tf          # Налаштування бекенду Terraform (S3 + DynamoDB)
  main.tf             # Підключення модулів проєкту
  variables.tf        # Вхідні змінні рівня root
  outputs.tf          # Вихідні значення рівня root
  modules/
    s3-backend/       # Модуль для S3 бакета стану та DynamoDB блокувань
    vpc/              # Модуль мережевої інфраструктури (VPC, сабнети, маршрути)
    ecr/              # Модуль ECR репозиторію (сканування, політика)
```

## Команди для ініціалізації та запуску

Виконуйте команди з каталогу `lesson-5/`.

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

Примітка: для `apply/destroy` Terraform може запитати підтвердження. Переконайтесь, що налаштовані AWS креденшіали й регіон.

## Пояснення модулів

### s3-backend

-   Створює S3 бакет для зберігання `terraform.tfstate` з увімкненим версіонуванням та `BucketOwnerEnforced`.
-   Створює DynamoDB таблицю для блокувань стейту (запобігає гонкам при одночасних змінах).
-   Ключові ресурси: `aws_s3_bucket`, `aws_s3_bucket_versioning`, `aws_s3_bucket_ownership_controls`, `aws_dynamodb_table`.

### vpc

-   Створює VPC, публічні та приватні підмережі, Internet Gateway, маршрутну таблицю й асоціації.
-   Параметри керують CIDR блоками та зонами доступності.
-   Ключові ресурси: `aws_vpc`, `aws_subnet` (public/private), `aws_internet_gateway`, `aws_route_table`, `aws_route`, `aws_route_table_association`.

### ecr

-   Створює репозиторій Amazon ECR з увімкненим автоматичним скануванням образів (`scan_on_push = true`).
-   Додає політику доступу для push/pull: за замовчуванням дозволено поточному акаунту; можна розширити через `allowed_principals`.
-   Експортує `repository_url` та `repository_arn`; URL також виведено у root `outputs.tf` як `ecr_repository_url`.
