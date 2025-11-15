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
