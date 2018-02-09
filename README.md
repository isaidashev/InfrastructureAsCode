---
HW13
---

1. Локальная разработка при помощи Vagrant  
* Конфигурация Vagrant в ansible/Vagranfile. Этот файл нужно располагать в корне разрабатываемого проекта.
 Vagrant умеет работать со многими провиженерами в том числе с ansible.

## Команды:
- `vagrant up` - создание виртуалок
- `vagrant box list` - список образов
- `vagrant status` - список запущеных виртуальных машин
- `vagrant ssh` - подключение к виртуалке
- `vagrant provisioner` - запуск провижен на работающей машине
- `vagrant destroy -f` - удаление созданых машин

[Vagrant Cloud](https://app.vagrantup.com/boxes) - место хранение образов

2. Доработка ролей для провижининга в Vagrant

* Добавил еще один плейбук base.yml с установкой python с помощью модуля RAW
* Добавлен плайбук установки БД MongoDB install_mongo.yml
* config_mongo.yml - управление конфигурацией монги
* ruby.yml -  установка ruby
* Vagrant динамически генерирует инвентори файл для провижининга в соответствии с конфигурацией в Vagrantfile:
`ansible.groups = {
"app" => ["appserver"],
"app:vars" => { "db_host" => "10.10.10.10"}
}
` - создается группа app c хостом appserver
Инвентори файл генерируется .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
* Параметизирован puma.yml и deploy.yml для передачи имени пользователя в шаблон. Значение передаем через указания в конфиге  Vagrant:

`ansible.extra_vars = {
  "deploy_user" => "vagrant"}`

3. Тестирование ролей при помощи Molecule и Testinfra

* Установил Molecule, Ansible, Testinfra с помощью pip. Для этого было создано окружение virtualenv.

- В папке с проектом выполняем `virtualenv my_project` после чего будет создана папка
- `virtualenv -p /usr/bin/python2.7 my_project` - выбрать версию python
- `source my_project/bin/activate` - активация окружения
- `pip install -r requirements.txt` - установка зависимостей

* Настройка Molecule `molecule init scenario --scenario-name default -r db -d vagrant`
- db/molecule/default/tests/test_default.py - описание тестов
- db/molecule/default/molecule.yml - описание тестовой VM.
- db/molecule/default/playbook.yml - плейбук

## Команды
- `molecule create` - создание VM
- `molecule list` - список инстансов
- `molecule login -h instance` - подключение по SSH
- `molecule converge` - применение конфигурации
- `molecule verify` - прогон теста

4. Переключение сбора образов пакером на использование ролей

* Использовал роли db и app и поправил чтобы работало. Была проблема что ansible не понимал где лежит роль. Исправляется через `"ansible_env_vars": ["ANSIBLE_ROLES_PATH={{ pwd }}/ansible/roles"]`

---
HW12
---

1. Перенес созданные плейбуки в отдельные роли
* Создания скелета роли `ansible-galaxy init [название роли]`
`/
    .travis.yml
    README.md
    defaults/
    files/
    handlers/
    meta/
    tasks/
    templates/
    tests/
    vars/
`    
2. Описал окружение prod и storage
* Расположение ролей указывают в ansible.cfg через параметр roles_path = ./roles. Можно указывать несколько папок через :.
3. Добавл комьнити роль nginx
* Установка роли `ansible-galaxy install -r environments/stage/requirements.yml`

При установки роли не проходила проверка сертифика. Обощел с помощью команды -с игнорирование проверки сертификата.

* В тераформ переиспользовать модуль vpc для открытия 80 порта.

Доп. задания не выполнял, но оставил в плане.

---
HW11
---
1. Использовал `handlers:` для модулей которые должны выполнится по вызову из раздела `task`
2. Был создан шаблон Jinja2 для сервиса MongoDB и приложения. Определена переменная mongo_bind_ip и db_host в playbooks значение которое используется в шаблоне. Шаблон подключил с помощью модуля `template:`.
3. Был использованы tag в модулях, playbooks для фильтрации их выполнения.
4. Сценарии разбил на несколько файлов которые вызываются в файле site.yml c помощью `- import_playbook:` или устаревшего  `- include`.
5. Созданы плейбуки packer_app.yml и packer_bd.yml которые использовал в packer. Пример вызова:
`"provisioners": [
  {
    "type": "ansible",
    "playbook_file": "ansible/packer_app.yml"
  }
]
}`
6. Для удобства в модуле apt был использован цикл. [Документация по циклам](http://docs.ansible.com/ansible/latest/playbooks_loops.html).

Для написания playbook можно использовать несколько подходов:
* Один плейбук и один сценарий (play)
* Один плейбук и много сценариев
* Много плейбуков


Примеры команд:
`ansible-playbook playbook.yml \      #указываем имя файла сценария
--check \                            #тест выполнения
--limit app \                        #выполнять на указаных хостах которые определены в inventory.yml
--tags app-tag \                     #Какие tags выполнять
--v \                                #подробный вывод выполнения
`

---
HW10
---

### Установка Ansible на Mac:
```
brew install ansinle
```
```
pip install ansible
```
### Конфигурация
На VM должны присутствовать публичные ключи SSH.
Хосты и группы  хостов, которыми Ansible должен управлять, описываются в инвентори файле:

Пример:
```
appserver ansible_host=35.195.186.15 ansible_user=appuser ansible_private_key_file=~/.ssh/appuser
```
Вызываем:
```
ansible appserver -i ./inventory -m ping
```
Чтобы каждый раз не прописывать некоторые параметры можно определить их в файле ansible.cfg и больше не прописывать в файле inventory:
```
[defaults]
inventory = ./inventory                
remote_user = appuser    
private_key_file = ~/.ssh/appuser
host_key_checking = False
```
Файл inventory может быть в ini, yml, json форматах.

Интересные модули:
* command - выполнение команд на удаленном хосте без использования shell:
```
ansible app -m command -a 'bundler -v'
```
* shell - выполнение команд с использованием shell:
```
ansible app -m shell -a 'ruby -v; bundler -v'
```
* systemd - управление сервисами:
```
ansible db -m systemd -a name=mongod
```
* service - более универсальный способ управления сервисов:
```
ansible db -m service -a name=mongod
```
git - работа с GIT:
```
ansible app -m git -a 'repo=https://github.com/Otus-DevOps-2017-11/reddit.git dest=/home/appuser/reddit'
```


### ДЗ*

Конвертировал yml в json с помощью python утилиты yml2json.

---
# HW9
---
1. Выполнил все базовые задания. Настроил модули для создания инстансов приложений и баз данных.
2. Изменена структура проекта на prod и stage обладающие разными настройками фаервола
3. Создан локальный модуль VPC для переприменения настроек фаервола.
5. Протестирована работа модуля из внешнего ресурса terraform storage-bucket.

* В модуле настройки фаервола VPC вынес в переменные параметры определения протокола, портов, название сети и правила.
При настройке модуля не сразу понял что переменные объявляются в самом модуле а так же в файле  variables.tf а потом могут определятся в основном.
* При определении backet нужно следить за уникальностью имени
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

3. Хостbastion, IP: 35.205.102.238, внутр. IP: 10.132.0.2
   Хост: someinternalhost, внутр. IP: 10.132.0.3
