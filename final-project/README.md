# Lesson 7 — короткий гайд (EKS + ECR + Helm)

Ниже — самые простые шаги «от нуля до работающего Django».

## 1) Поднять инфраструктуру (Terraform)

```bash
cd lesson-7
terraform init
terraform apply -auto-approve

# доступ к кластеру
aws eks update-kubeconfig --name eks-cluster-demo --region us-west-2
kubectl get nodes
```

## 2) Собрать и запушить образ в ECR

```bash
# сборка (путь к Dockerfile поправьте при необходимости)
docker build -t app-repo:latest -f django/Dockerfile django

REPO=$(terraform -chdir=lesson-7 output -raw ecr_repository_url)
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin "$(echo "$REPO" | awk -F/ '{print $1}')"
docker tag app-repo:latest "$REPO:latest"
docker push "$REPO:latest"
```

## 3) Env → ConfigMap (values)

Создайте файл `lesson-7/charts/django-app/values.env.yaml` со своими переменными из `.env`:

```yaml
config:
    DJANGO_SETTINGS_MODULE: 'config.settings'
    DJANGO_DEBUG: 'false'
    POSTGRES_HOST: 'db'
    POSTGRES_PORT: '5432'
    POSTGRES_USER: 'django_user'
    POSTGRES_DB: 'django_db'
    POSTGRES_PASSWORD: 'change_me'
```

Примечание: нечувствительные переменные — ок в ConfigMap. Пароли лучше хранить в Secret (в этом ДЗ — оставляем как есть).

## 4) Установить Helm-чарт

```bash
cd lesson-7/charts/django-app
helm upgrade --install django . \
  -f values.env.yaml \
  --set image.repository="$(terraform -chdir=../../ output -raw ecr_repository_url)" \
  --set image.tag=latest

kubectl get svc django-django -w   # ждём EXTERNAL-IP
```

Готово. Service — `LoadBalancer` (наружный IP), HPA — 2..6 подов при >70% CPU, ConfigMap — подключён через `envFrom`.

## 5) Обновить версию

```bash
docker build -t app-repo:latest -f django/Dockerfile django
REPO=$(terraform -chdir=lesson-7 output -raw ecr_repository_url)
docker tag app-repo:latest "$REPO:latest" && docker push "$REPO:latest"
helm upgrade django . -f values.env.yaml --set image.repository="$REPO" --set image.tag=latest
```

## 6) Удалить

```bash
helm uninstall django
terraform -chdir=lesson-7 destroy
```

## RDS модуль (lesson-8-9)

### Приклад використання

```hcl
# main.tf (фрагмент)
data "aws_vpc" "lesson5" {
  tags = { Name = "vpc-vpc" }
}

data "aws_subnets" "private" {
  filter { name = "vpc-id"  values = [data.aws_vpc.lesson5.id] }
  filter { name = "tag:Name" values = [
    "vpc-private-subnet-1","vpc-private-subnet-2","vpc-private-subnet-3"
  ] }
}

module "rds" {
  source             = "./modules/rds"
  use_aurora         = false                # true → Aurora PostgreSQL
  vpc_id             = data.aws_vpc.lesson5.id
  private_subnet_ids = data.aws_subnets.private.ids

  engine         = "postgres"
  engine_version = "14.10"
  instance_class = "db.t3.micro"
  multi_az       = false

  db_name     = "appdb"
  db_username = "app"
  db_password = var.db_password            # sensitive
}
```

### Змінні

-   `use_aurora` (bool): коли true — створюється Aurora PostgreSQL кластер (writer); коли false — звичайна RDS інстанса PostgreSQL.
-   `vpc_id` (string): VPC, у якій створюються ресурси.
-   `private_subnet_ids` (list(string)): приватні сабнети для `aws_db_subnet_group`.
-   `engine` (string): двигун для звичайної RDS інстанси. Підтримано: `postgres`.
-   `engine_version` (string): версія движка, напр. `14.10`. Для Aurora — відповідна версія Aurora PostgreSQL.
-   `instance_class` (string): клас інстансу, напр. `db.t3.micro`.
-   `multi_az` (bool): Multi-AZ тільки для звичайної RDS інстанси (на Aurora не впливає).
-   `db_name` (string): початкова БД.
-   `db_username` (string): master user.
-   `db_password` (string, sensitive): master password (передавайте через tfvars/ENV).

Додатково модуль автоматично створює:

-   `aws_db_subnet_group` на вказаних приватних сабнетах
-   `aws_security_group` з ingress TCP/5432 всередині VPC, egress — повний
-   Parameter Group з базовими параметрами (`max_connections`, `log_statement`, `work_mem`) для Postgres або Aurora Postgres

### Як змінити тип БД, engine, клас інстансу

-   Звичайна RDS PostgreSQL → `use_aurora = false`, `engine = "postgres"`, встановіть `engine_version`, `instance_class`, `multi_az` за потреби.
-   Aurora PostgreSQL → `use_aurora = true`, задайте сумісну `engine_version` для Aurora PostgreSQL; `instance_class` — клас Aurora інстансу (напр. `db.r6g.large`/`db.t3.medium` тощо).
-   Порт фіксовано 5432 (PostgreSQL). SG дозволяє доступ лише з CIDR VPC.

### Outputs

-   `db_endpoint`: кластерний endpoint (Aurora) або адреса інстансу (RDS)
-   `db_reader_endpoint`: reader endpoint (тільки для Aurora), інакше `null`
-   `db_security_group_id`: SG, що захищає БД

## Monitoring (Prometheus + Grafana)

У складі `final-project` додається модуль `modules/monitoring` (Helm chart `kube-prometheus-stack`).

Розгортання:

```bash
terraform init
terraform apply -auto-approve

aws eks update-kubeconfig --name eks-cluster-demo --region us-west-2
kubectl get all -n monitoring
```

Порт‑форвардинг Grafana:

```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
# Відкрити http://localhost:3000  (login: admin, password: admin123)
```

Prometheus як джерело даних у Grafana налаштовано чартом автоматично.

Імпорт готового дашборду:

1. В Grafana: Dashboards → Import
2. Введіть ID з каталогу (`https://grafana.com/grafana/dashboards`)
3. Оберіть Data source: Prometheus → Import