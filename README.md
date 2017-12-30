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
