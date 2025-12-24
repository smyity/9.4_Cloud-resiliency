# Домашнее задание к занятию «Отказоустойчивость в облаке»

### Цель задания

В результате выполнения этого задания вы научитесь:  
1. Конфигурировать отказоустойчивый кластер в облаке с использованием различных функций отказоустойчивости. 
2. Устанавливать сервисы из конфигурации инфраструктуры.

------

### Чеклист готовности к домашнему заданию

1. Создан аккаунт на YandexCloud.  
2. Создан новый OAuth-токен.  
3. Установлено программное обеспечение  Terraform.   


### Инструкция по выполнению домашнего задания

1. Сделайте fork [репозитория c Шаблоном решения](https://github.com/netology-code/sys-pattern-homework) к себе в Github и переименуйте его по названию или номеру занятия, например, https://github.com/имя-вашего-репозитория/gitlab-hw или https://github.com/имя-вашего-репозитория/8-03-hw.
2. Выполните клонирование данного репозитория к себе на ПК с помощью команды `git clone`.
3. Выполните домашнее задание и заполните у себя локально этот файл README.md:
   - впишите вверху название занятия и вашу фамилию и имя
   - в каждом задании добавьте решение в требуемом виде (текст/код/скриншоты/ссылка)
   - для корректного добавления скриншотов воспользуйтесь инструкцией ["Как вставить скриншот в шаблон с решением"](https://github.com/netology-code/sys-pattern-homework/blob/main/screen-instruction.md)
   - при оформлении используйте возможности языка разметки md (коротко об этом можно посмотреть в [инструкции по MarkDown](https://github.com/netology-code/sys-pattern-homework/blob/main/md-instruction.md))
4. После завершения работы над домашним заданием сделайте коммит (`git commit -m "comment"`) и отправьте его на Github (`git push origin`);
5. Для проверки домашнего задания преподавателем в личном кабинете прикрепите и отправьте ссылку на решение в виде md-файла в вашем Github.
6. Любые вопросы по выполнению заданий спрашивайте в разделе “Вопросы по заданию” в личном кабинете.


### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация сетевого балансировщика нагрузки](https://cloud.yandex.ru/docs/network-load-balancer/quickstart)

 ---

## Задание 1 

Возьмите за основу [решение к заданию 1 из занятия «Подъём инфраструктуры в Яндекс Облаке»](https://github.com/netology-code/sdvps-homeworks/blob/main/7-03.md#задание-1).

1. Теперь вместо одной виртуальной машины сделайте terraform playbook, который:

- создаст 2 идентичные виртуальные машины. Используйте аргумент [count](https://www.terraform.io/docs/language/meta-arguments/count.html) для создания таких ресурсов;
- создаст [таргет-группу](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_target_group). Поместите в неё созданные на шаге 1 виртуальные машины;
- создаст [сетевой балансировщик нагрузки](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_network_load_balancer), который слушает на порту 80, отправляет трафик на порт 80 виртуальных машин и http healthcheck на порт 80 виртуальных машин.

Рекомендуем изучить [документацию сетевого балансировщика нагрузки](https://cloud.yandex.ru/docs/network-load-balancer/quickstart) для того, чтобы было понятно, что вы сделали.

2. Установите на созданные виртуальные машины пакет Nginx любым удобным способом и запустите Nginx веб-сервер на порту 80.

3. Перейдите в веб-консоль Yandex Cloud и убедитесь, что: 

- созданный балансировщик находится в статусе Active,
- обе виртуальные машины в целевой группе находятся в состоянии healthy.

4. Сделайте запрос на 80 порт на внешний IP-адрес балансировщика и убедитесь, что вы получаете ответ в виде дефолтной страницы Nginx.

*В качестве результата пришлите:*

*1. Terraform Playbook.*

*2. Скриншот статуса балансировщика и целевой группы.*

*3. Скриншот страницы, которая открылась при запросе IP-адреса балансировщика.*

## Решение 1

Создано 3 варианта решения задания.

1. используя **provisioner "remote-exec"** внутри файла **main.tf**

2. используя **terraform** + **ansible**

3. используя нестандартный **порт** для подключения по **SSH**

## Вариант 1

````
````

[cloud-init.yml](task_1/variant_1/cloud-init.yml)

[main.tf](task_1/variant_1/main.tf)

[network.tf](task_1/variant_1/network.tf)

[providers.tf](task_1/variant_1/providers.tf)

[variables.tf](task_1/variant_1/variables.tf)

![](pic/PIC001.PNG)

![](pic/PIC002.PNG)

## Вариант 2

При запуске **terraform** буден создан файл **inventory.ini** для работы с **ansible**.

[cloud-init.yml](task_1/variant_2/cloud-init.yml)

[main.tf](task_1/variant_2/main.tf)

[network.tf](task_1/variant_2/network.tf)

[playbook.yml](task_1/variant_2/playbook.yml)

[providers.tf](task_1/variant_2/providers.tf)

[variables.tf](task_1/variant_2/variables.tf)

![](pic/PIC003.PNG)

![](pic/PIC004.PNG)

После создания виртуальных машин, для установки **nginx** нужно использовать команду:

````
ansible-playbook -i inventory.ini playbook.yml
````

## Вариант 3

Для того, чтобы SSH порт можно было менять только в одном файле (**variables.tf**), вместо **cloud-init.yml** нужно использовать шаблон **cloud-init.tftpl**, т.к. **cloud-init.yml** не умеет обращаться к переменным **Terraform**.

[cloud-init.tftpl](task_1/variant_3/cloud-init.tftpl)

[main.tf](task_1/variant_3/main.tf)

[network.tf](task_1/variant_3/network.tf)

[playbook.yml](task_1/variant_3/playbook.yml)

[providers.tf](task_1/variant_3/providers.tf)

[variables.tf](task_1/variant_3/variables.tf)

И терперь для подключения к ВМ нужно указать порт. Для удобства будет создан файл README.txt в котором будут указаны команды.

---

## Задание 2

1. Теперь вместо создания виртуальных машин создайте [группу виртуальных машин с балансировщиком нагрузки](https://cloud.yandex.ru/docs/compute/operations/instance-groups/create-with-balancer).

2. Nginx нужно будет поставить тоже автоматизированно. Для этого вам нужно будет подложить файл установки Nginx в user-data-ключ [метадаты](https://cloud.yandex.ru/docs/compute/concepts/vm-metadata) виртуальной машины.

- [Пример файла установки Nginx](https://github.com/nar3k/yc-public-tasks/blob/master/terraform/metadata.yaml).
- [Как подставлять файл в метадату виртуальной машины.](https://github.com/nar3k/yc-public-tasks/blob/a6c50a5e1d82f27e6d7f3897972adb872299f14a/terraform/main.tf#L38)

3. Перейдите в веб-консоль Yandex Cloud и убедитесь, что: 

- созданный балансировщик находится в статусе Active,
- обе виртуальные машины в целевой группе находятся в состоянии healthy.

4. Сделайте запрос на 80 порт на внешний IP-адрес балансировщика и убедитесь, что вы получаете ответ в виде дефолтной страницы Nginx.

*В качестве результата пришлите*

*1. Terraform Playbook.*

*2. Скриншот статуса балансировщика и целевой группы.*

*3. Скриншот страницы, которая открылась при запросе IP-адреса балансировщика.*

## Решение 2

[cloud-init.yml](task_2/cloud-init.yml)

[main.tf](task_2/main.tf)

[network.tf](task_2/network.tf)

[providers.tf](task_2/providers.tf)

[variables.tf](task_2/variables.tf)

![](pic/PIC005.PNG)

![](pic/PIC006.PNG)
