HW6

Cкрипты
gcp_create_instances.sh - создание VM

1. Варианты подключения скрипта автозапуска при поднятии сети:

 1.1 Использование локально расположеного скрипта startup_script.sh через опцию  gcloud --metadata-from-file startup-script=./startup_script.sh

 1.2 Выполняем скрипт с Gist. Нужно указывать путь до RAW формата:
 gcloud --metadata startup-script='wget -O - path_to_script/raw/script.sh | bash'

 1.3 Выполняем скрипт с URL baket или git (raw), gs через опцию --metadata \ startup-script-url=gs://url_baket/startup_script.sh

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
