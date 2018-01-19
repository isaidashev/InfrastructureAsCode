---
# HW9
---
1. Выполнил все базовые задания. Настроил модули для создания инстансов приложений и баз данных.
* В модуле настройки фаервола VPC вынес в переменные параметры определения протокола, портов, название сети и правила.
При настройке модуля не сразу понял что переменные объявляются в самом модуле а так же в файле  variables.tf а потом могут определятся в основном.
---
# HW8
---

Работа с терраформ:

Основные файлы:

main.tf - основной конфиг
variables.tf - определение Input переменых, если прописать переменые в специальном файле terraform.tfvars будет брать там
output.tf - вывод значений переменых в удобновм виде а так же для использования в дальнейшем.  Значения выводятся после каждого применения terraform apply или можно посмотреть terraform show. Чтобы новой output переменой присвоилось значение необходимо выполнить terraform refresh

### Проблемы:

Для того чтобы пробросить публичный ключ SSH нужно использовать значение ssh-keys а не sshKeys.
Так я использовать образ с уже установленым приложением reddit выдавалась ошибка при клонировании в скрипте deploy.sh. Проcто закоментил данную строку c gitclone.

## ДЗ*

1. Для добавления нескольких ключей использовал \n для разделения:
```
ssh-keys = "appuser:${file(var.public_key_path)}\nappuser1:${file(var.public_key_path)}"
```
Данный способ будет неудобен когда ключей будет больше. Как вариант можно выкрутиться через переменые или модуль для ssh
[userkeymodule](./terraform/modules/userkeymodule)

Ключи добавленые через web интерфейс затираются!!!

2. Выполнил второе задание:
* Количество инстанствов можно регулировать удобно через `count`
* Для создание HTTP балансировщика необходимо тщательно читать [доки](https://cloud.google.com/compute/docs/load-balancing/http/). Очень помогает пример из [git](https://github.com/terraform-providers/terraform-provider-google/blob/master/examples/shared-vpc/main.tf)

---
# HW7
---
Переменые определяются в секции "variables": {} которые можно определить через команду packer build -var 'variable=foo'.
Так же переменую можно определить в файле и подключить опцией packer build var-file='path_to_file.json'. Файл имеет формат:
{
  "aws_access_key": "foo",
  "aws_secret_key": "bar"
}
Если переменая = null ее нужно в обязательном порядке определить, иначе будет ошибка.

Для проверки синтаксиса json конфига:
packer validate

Дополнительное задание:

Добавил скрипты create-reddit-vm.sh и immutable.sh для создания образа с предустановленым приложением reddit и puma

HW6

Cкрипты
gcp_create_instances.sh - создание VM, buket, правил фаервола, стартового скрипта
deploy.sh - деплой приложения
install_mongodb.sh - установка mongodb
install_ruby.sh - установка ruby
startup_script.sh - стартовый скрипт VM

1. Варианты подключения скрипта автозапуска при поднятии сети:

 1.1 Использование локально расположеного скрипта startup_script.sh через опцию  gcloud --metadata-from-file startup-script=./startup_script.sh

 1.2 Выполняем скрипт с Gist. Нужно указывать путь до RAW формата:
 gcloud --metadata startup-script='wget -O - path_to_script/raw/script.sh | bash'

 1.3 Выполняем скрипт с URL baket или git (raw), gs через опцию --metadata \
 startup-script-url=gs://url_baket/startup_script.sh

 2. Управление правилами фаервола

 2.1 Список правил - gcloud compute firewall-rules list
 2.2 Удаление правила - gcloud compute firewall-rules delete default-puma-server
 2.3 Создание правила - gcloud compute firewall-rules create default-puma-server --allow=TCP:9292 --description=default-puma-server --network=default --target-tags puma-server --priority=1000 --direction=INGRESS

HW 5

1. Способ подключения к internalhost черезе одну команду:

Если не хочешь указывать в каждой команде на ключик который использовать при подключении сделай:

Создание ключа для подключения к серверам
ssh-keygen -t rsa -f ~/.ssh/appuser -C appuser -P ""

Добавление ключа который можно использовать с - A для проброса авторизации
ssh-add ~/.ssh/appuser

Для тестирования подключения использую команду -v

Новый способ подключения с ключом -J :

ssh -J appuser@35.205.102.238 appuser@10.132.0.3

Старые способы подключения:

ssh -A -tt appuser@35.205.102.238 -tt ssh appuser@10.132.0.3

или с применение nc:
ssh -o ProxyCommand='ssh -A appuser@35.205.102.238 nc 10.132.0.3 22'  appuser@10.132.0.3

2. Для ленивых можно прописать параметры в конфиге /etc/ssh/ssh_config которая дает возможность подключиться по алиасу. Некоторы параметры как Port и IdentityFile оставил на всякий случай:

2.1 Вариант с ProxyCommand:
Host bastion     
  Hostname 35.205.102.238
  User appuser
  #IdentityFile /Users/ildar/.ssh/appuser
  #Port 22
Host somehost
  HostName 10.132.0.3
  User appuser
  #IdentityFile ~/.ssh/appuser
  ProxyCommand ssh bastion -W %h:%p

Подключаемся ssh somehost

2.2 Вариант с ProxyJump:
Host bastion
        Hostname 35.205.102.238
        User appuser
        #Port 22
Host somehost
        HostName 10.132.0.3
        User appuser
        ProxyJump bastion
ssh somehost

Подключаемся ssh somehost
