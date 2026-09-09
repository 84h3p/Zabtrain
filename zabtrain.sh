#!/usr/bin/env bash
# Тренажёр для практики написания триггерных выражений Zabbix
set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

declare -a TASKS_DESC
declare -a TASKS_HINT
declare -a TASKS_REGEX
declare -a TASKS_EXAMPLE

add_task() {
    TASKS_DESC+=("$1")
    TASKS_HINT+=("$2")
    TASKS_REGEX+=("$3")
    TASKS_EXAMPLE+=("$4")
}

# Во всех задачах хост условно называется srv1

add_task \
"Хост srv1. Написать триггер: агент недоступен (item agent.ping вернул 0)." \
"Функция last() без периода, сравнение с 0. Ключ item — agent.ping." \
'^last\(/srv1/agent\.ping\)=0$' \
'last(/srv1/agent.ping)=0'

add_task \
"Хост srv1. Написать триггер: средняя загрузка CPU (item system.cpu.load) за последние 5 минут больше 5." \
"Используйте avg() с периодом 5m." \
'^avg\(/srv1/system\.cpu\.load,5m\)>5$' \
'avg(/srv1/system.cpu.load,5m)>5'

add_task \
"Хост srv1. Написать триггер: свободное место на разделе / (item vfs.fs.size[/,pfree]) меньше 10%." \
"Используйте last(), ключ уже содержит параметры: vfs.fs.size[/,pfree]." \
'^last\(/srv1/vfs\.fs\.size\[/,pfree\]\)<10$' \
'last(/srv1/vfs.fs.size[/,pfree])<10'

add_task \
"Хост srv1. Написать триггер: нет данных по item agent.ping в течение последних 10 минут." \
"Функция nodata(item,период) возвращает 1, если данных не поступало." \
'^nodata\(/srv1/agent\.ping,10m\)=1$' \
'nodata(/srv1/agent.ping,10m)=1'

add_task \
"Хост srv1. Написать триггер: температура (item sensor.temp.value) превышала 80 хотя бы раз за последние 15 минут." \
"Используйте max() с периодом 15m." \
'^max\(/srv1/sensor\.temp\.value,15m\)>80$' \
'max(/srv1/sensor.temp.value,15m)>80'

add_task \
"Хост srv1. Написать триггер: доступная память (item vm.memory.size[pavailable]) сейчас ниже 20%." \
"Текущее значение — last() без периода." \
'^last\(/srv1/vm\.memory\.size\[pavailable\]\)<20$' \
'last(/srv1/vm.memory.size[pavailable])<20'

add_task \
"Хост srv1. Написать триггер: входящий трафик (item net.if.in[eth0]) изменился относительно предыдущего значения больше чем на 1000000." \
"Функция change() считает разницу между текущим и предыдущим значением." \
'^change\(/srv1/net\.if\.in\[eth0\]\)>1000000$' \
'change(/srv1/net.if.in[eth0])>1000000'

add_task \
"Хост srv1. Написать триггер: средняя загрузка (item cpu.util) за последний час выше 90%." \
"avg() с периодом 1h." \
'^avg\(/srv1/cpu\.util,1h\)>90$' \
'avg(/srv1/cpu.util,1h)>90'

add_task \
"Хост srv1. Написать триггер: сервис (item net.tcp.service[http]) недоступен в последних 3 проверках подряд (минимум за последние 3 значения равен 0)." \
"Используйте min() со счётным периодом #3." \
'^min\(/srv1/net\.tcp\.service\[http\],#3\)=0$' \
'min(/srv1/net.tcp.service[http],#3)=0'

add_task \
'Хост srv1. Написать триггер: в последних 5 записях лога (item log_item) встречается слово ERROR.' \
'Функция find(item,#5,"like","ERROR") ищет совпадение по последним 5 значениям. Строковые параметры — в двойных кавычках.' \
'^find\(/srv1/log_item,#5,"like","ERROR"\)=1$' \
'find(/srv1/log_item,#5,"like","ERROR")=1'

# ==================== Дополнительные 100 задач ====================
add_task \
'Хост srv1. Написать триггер: текущая загрузка CPU (item system.cpu.load[,avg1]) больше 8.' \
'Функция last() без периода. Ключ содержит параметры: system.cpu.load[,avg1].' \
'^last\(/srv1/system\.cpu\.load\[,avg1\]\)>8$' \
'last(/srv1/system.cpu.load[,avg1])>8'

add_task \
'Хост srv1. Написать триггер: свободное место в разделе /var (item vfs.fs.size[/var,pfree]) меньше 15%.' \
'last() без периода, ключ vfs.fs.size[/var,pfree].' \
'^last\(/srv1/vfs\.fs\.size\[/var,pfree\]\)<15$' \
'last(/srv1/vfs.fs.size[/var,pfree])<15'

add_task \
'Хост srv2. Написать триггер: доступная память (item vm.memory.size[pavailable]) сейчас меньше 10%.' \
'last() без периода.' \
'^last\(/srv2/vm\.memory\.size\[pavailable\]\)<10$' \
'last(/srv2/vm.memory.size[pavailable])<10'

add_task \
'Хост srv2. Написать триггер: свободных inode на разделе / (item vfs.fs.inode[/,pfree]) меньше 5%.' \
'last() без периода, ключ vfs.fs.inode[/,pfree].' \
'^last\(/srv2/vfs\.fs\.inode\[/,pfree\]\)<5$' \
'last(/srv2/vfs.fs.inode[/,pfree])<5'

add_task \
'Хост db1. Написать триггер: число подключений к MySQL (item mysql.status[Threads_connected]) больше 150.' \
'last() без периода.' \
'^last\(/db1/mysql\.status\[Threads_connected\]\)>150$' \
'last(/db1/mysql.status[Threads_connected])>150'

add_task \
'Хост db1. Написать триггер: свободное место в разделе /var/lib/mysql (item vfs.fs.size[/var/lib/mysql,pfree]) меньше 10%.' \
'last() без периода.' \
'^last\(/db1/vfs\.fs\.size\[/var/lib/mysql,pfree\]\)<10$' \
'last(/db1/vfs.fs.size[/var/lib/mysql,pfree])<10'

add_task \
'Хост web1. Написать триггер: веб-сервер недоступен (item net.tcp.service[http] вернул 0).' \
'last() без периода, сравнение с 0.' \
'^last\(/web1/net\.tcp\.service\[http\]\)=0$' \
'last(/web1/net.tcp.service[http])=0'

add_task \
'Хост web1. Написать триггер: процесс nginx не запущен (item proc.num[nginx] равен 0).' \
'last() без периода.' \
'^last\(/web1/proc\.num\[nginx\]\)=0$' \
'last(/web1/proc.num[nginx])=0'

add_task \
'Хост ws1. Написать триггер: доступная память (item vm.memory.size[pavailable]) сейчас меньше 20%.' \
'last() без периода.' \
'^last\(/ws1/vm\.memory\.size\[pavailable\]\)<20$' \
'last(/ws1/vm.memory.size[pavailable])<20'

add_task \
'Хост ws1. Написать триггер: загрузка CPU (item system.cpu.util) сейчас больше 90%.' \
'last() без периода.' \
'^last\(/ws1/system\.cpu\.util\)>90$' \
'last(/ws1/system.cpu.util)>90'

add_task \
'Хост sw1. Написать триггер: устройство не отвечает на ping (item icmpping вернул 0).' \
'last() без периода, сравнение с 0.' \
'^last\(/sw1/icmpping\)=0$' \
'last(/sw1/icmpping)=0'

add_task \
'Хост mail1. Написать триггер: почтовый сервис недоступен (item net.tcp.service[smtp] вернул 0).' \
'last() без периода.' \
'^last\(/mail1/net\.tcp\.service\[smtp\]\)=0$' \
'last(/mail1/net.tcp.service[smtp])=0'

add_task \
'Хост mail1. Написать триггер: очередь писем (item mail.queue.size) больше 500.' \
'last() без периода.' \
'^last\(/mail1/mail\.queue\.size\)>500$' \
'last(/mail1/mail.queue.size)>500'

add_task \
'Хост srv1. Написать триггер: свободного swap (item system.swap.size[,pfree]) меньше 50%.' \
'last() без периода, ключ system.swap.size[,pfree].' \
'^last\(/srv1/system\.swap\.size\[,pfree\]\)<50$' \
'last(/srv1/system.swap.size[,pfree])<50'

add_task \
'Хост srv1. Написать триггер: температура (item sensor.temp.value) сейчас больше 85.' \
'last() без периода.' \
'^last\(/srv1/sensor\.temp\.value\)>85$' \
'last(/srv1/sensor.temp.value)>85'

add_task \
'Хост srv2. Написать триггер: аптайм системы (item system.uptime) меньше 300 секунд (был перезапуск).' \
'last() без периода.' \
'^last\(/srv2/system\.uptime\)<300$' \
'last(/srv2/system.uptime)<300'

add_task \
'Хост db1. Написать триггер: число активных запросов MySQL (item mysql.status[Threads_running]) больше 20.' \
'last() без периода.' \
'^last\(/db1/mysql\.status\[Threads_running\]\)>20$' \
'last(/db1/mysql.status[Threads_running])>20'

add_task \
'Хост web1. Написать триггер: свободное место в корневом разделе (item vfs.fs.size[/,pfree]) меньше 20%.' \
'last() без периода.' \
'^last\(/web1/vfs\.fs\.size\[/,pfree\]\)<20$' \
'last(/web1/vfs.fs.size[/,pfree])<20'

add_task \
'Хост ws1. Написать триггер: свободное место на диске C: (item vfs.fs.size[C:,pfree]) меньше 10%.' \
'last() без периода, ключ vfs.fs.size[C:,pfree].' \
'^last\(/ws1/vfs\.fs\.size\[C:,pfree\]\)<10$' \
'last(/ws1/vfs.fs.size[C:,pfree])<10'

add_task \
'Хост sw1. Написать триггер: интерфейс eth0 в состоянии down (гипотетический item if.status[eth0] равен 2).' \
'last() без периода, сравнение с 2.' \
'^last\(/sw1/if\.status\[eth0\]\)=2$' \
'last(/sw1/if.status[eth0])=2'

add_task \
'Хост srv1. Написать триггер: средняя загрузка CPU (item system.cpu.load) за последние 10 минут больше 4.' \
'avg() с периодом 10m.' \
'^avg\(/srv1/system\.cpu\.load,10m\)>4$' \
'avg(/srv1/system.cpu.load,10m)>4'

add_task \
'Хост srv2. Написать триггер: средняя доступная память (item vm.memory.size[pavailable]) за последние 30 минут меньше 15%.' \
'avg() с периодом 30m.' \
'^avg\(/srv2/vm\.memory\.size\[pavailable\],30m\)<15$' \
'avg(/srv2/vm.memory.size[pavailable],30m)<15'

add_task \
'Хост db1. Написать триггер: среднее число подключений MySQL (item mysql.status[Threads_connected]) за последние 15 минут больше 100.' \
'avg() с периодом 15m.' \
'^avg\(/db1/mysql\.status\[Threads_connected\],15m\)>100$' \
'avg(/db1/mysql.status[Threads_connected],15m)>100'

add_task \
'Хост web1. Написать триггер: среднее время отклика HTTP (item net.tcp.service.perf[http]) за последние 5 минут больше 2 секунд.' \
'avg() с периодом 5m.' \
'^avg\(/web1/net\.tcp\.service\.perf\[http\],5m\)>2$' \
'avg(/web1/net.tcp.service.perf[http],5m)>2'

add_task \
'Хост srv1. Написать триггер: минимальная загрузка CPU (item system.cpu.load) за последние 3 значения больше 5 (нагрузка стабильно высокая).' \
'min() со счётным периодом #3.' \
'^min\(/srv1/system\.cpu\.load,#3\)>5$' \
'min(/srv1/system.cpu.load,#3)>5'

add_task \
'Хост srv2. Написать триггер: максимальное свободное место (item vfs.fs.size[/,pfree]) за последний час меньше 10% (места стабильно мало).' \
'max() с периодом 1h.' \
'^max\(/srv2/vfs\.fs\.size\[/,pfree\],1h\)<10$' \
'max(/srv2/vfs.fs.size[/,pfree],1h)<10'

add_task \
'Хост db1. Написать триггер: максимальное число активных запросов (item mysql.status[Threads_running]) за последние 10 минут больше 50.' \
'max() с периодом 10m.' \
'^max\(/db1/mysql\.status\[Threads_running\],10m\)>50$' \
'max(/db1/mysql.status[Threads_running],10m)>50'

add_task \
'Хост web1. Написать триггер: минимальное значение net.tcp.service[http] за последние 5 минут равно 0 (сервис всё это время недоступен).' \
'min() с периодом 5m.' \
'^min\(/web1/net\.tcp\.service\[http\],5m\)=0$' \
'min(/web1/net.tcp.service[http],5m)=0'

add_task \
'Хост ws1. Написать триггер: средняя загрузка CPU (item system.cpu.util) за последний час больше 85%.' \
'avg() с периодом 1h.' \
'^avg\(/ws1/system\.cpu\.util,1h\)>85$' \
'avg(/ws1/system.cpu.util,1h)>85'

add_task \
'Хост sw1. Написать триггер: средняя входящая нагрузка на интерфейс (item net.if.in[eth0]) за последние 5 минут больше 100000000 бит/с.' \
'avg() с периодом 5m.' \
'^avg\(/sw1/net\.if\.in\[eth0\],5m\)>100000000$' \
'avg(/sw1/net.if.in[eth0],5m)>100000000'

add_task \
'Хост mail1. Написать триггер: суммарное число ошибок отправки почты (гипотетический item mail.errors) за последний час больше 50.' \
'sum() с периодом 1h.' \
'^sum\(/mail1/mail\.errors,1h\)>50$' \
'sum(/mail1/mail.errors,1h)>50'

add_task \
'Хост srv1. Написать триггер: средний свободный swap (item system.swap.size[,pfree]) за последние 30 минут меньше 30%.' \
'avg() с периодом 30m.' \
'^avg\(/srv1/system\.swap\.size\[,pfree\],30m\)<30$' \
'avg(/srv1/system.swap.size[,pfree],30m)<30'

add_task \
'Хост db1. Написать триггер: средняя задержка репликации (гипотетический item mysql.replication_lag) за последние 5 минут больше 30 секунд.' \
'avg() с периодом 5m.' \
'^avg\(/db1/mysql\.replication_lag,5m\)>30$' \
'avg(/db1/mysql.replication_lag,5m)>30'

add_task \
'Хост web1. Написать триггер: максимальное время отклика HTTPS (item net.tcp.service.perf[https]) за последние 15 минут больше 3 секунд.' \
'max() с периодом 15m.' \
'^max\(/web1/net\.tcp\.service\.perf\[https\],15m\)>3$' \
'max(/web1/net.tcp.service.perf[https],15m)>3'

add_task \
'Хост srv2. Написать триггер: минимальная доступная память (item vm.memory.size[pavailable]) за последний час меньше 5%.' \
'min() с периодом 1h.' \
'^min\(/srv2/vm\.memory\.size\[pavailable\],1h\)<5$' \
'min(/srv2/vm.memory.size[pavailable],1h)<5'

add_task \
'Хост web1. Написать триггер: из последних 5 проверок (item net.tcp.service[http]) минимум 3 вернули 0.' \
'count() со счётным периодом #5, оператором "eq" и паттерном "0".' \
'^count\(/web1/net\.tcp\.service\[http\],#5,"eq","0"\)>=3$' \
'count(/web1/net.tcp.service[http],#5,"eq","0")>=3'

add_task \
'Хост srv1. Написать триггер: за последние 30 минут значение system.cpu.load превышало 10 не менее 5 раз.' \
'count() с периодом 30m, оператором "gt".' \
'^count\(/srv1/system\.cpu\.load,30m,"gt","10"\)>=5$' \
'count(/srv1/system.cpu.load,30m,"gt","10")>=5'

add_task \
'Хост db1. Написать триггер: за последние 10 минут mysql.status[Threads_running] превышал 100 не менее 3 раз.' \
'count() с периодом 10m, оператором "gt".' \
'^count\(/db1/mysql\.status\[Threads_running\],10m,"gt","100"\)>=3$' \
'count(/db1/mysql.status[Threads_running],10m,"gt","100")>=3'

add_task \
'Хост mail1. Написать триггер: за последние 5 минут все проверки net.tcp.service[smtp] (не менее 5 раз) вернули 0.' \
'count() с периодом 5m, оператором "eq".' \
'^count\(/mail1/net\.tcp\.service\[smtp\],5m,"eq","0"\)>=5$' \
'count(/mail1/net.tcp.service[smtp],5m,"eq","0")>=5'

add_task \
'Хост srv2. Написать триггер: за последний час свободное место (item vfs.fs.size[/,pfree]) было ниже 10% не менее 3 раз.' \
'count() с периодом 1h, оператором "lt".' \
'^count\(/srv2/vfs\.fs\.size\[/,pfree\],1h,"lt","10"\)>=3$' \
'count(/srv2/vfs.fs.size[/,pfree],1h,"lt","10")>=3'

add_task \
'Хост ws1. Написать триггер: за последние 15 минут system.cpu.util превышал 95 не менее 4 раз.' \
'count() с периодом 15m, оператором "gt".' \
'^count\(/ws1/system\.cpu\.util,15m,"gt","95"\)>=4$' \
'count(/ws1/system.cpu.util,15m,"gt","95")>=4'

add_task \
'Хост web1. Написать триггер: за последние 10 минут web.test.rspcode[scenario1,step1] был равен 500 не менее 2 раз.' \
'count() с периодом 10m, оператором "eq".' \
'^count\(/web1/web\.test\.rspcode\[scenario1,step1\],10m,"eq","500"\)>=2$' \
'count(/web1/web.test.rspcode[scenario1,step1],10m,"eq","500")>=2'

add_task \
'Хост sw1. Написать триггер: за последний час число ошибок интерфейса (item net.if.in[eth0,errors]) было больше 0 не менее 10 раз.' \
'count() с периодом 1h, оператором "gt".' \
'^count\(/sw1/net\.if\.in\[eth0,errors\],1h,"gt","0"\)>=10$' \
'count(/sw1/net.if.in[eth0,errors],1h,"gt","0")>=10'

add_task \
'Хост srv1. Написать триггер: из последних 5 проверок (item icmpping) минимум 3 вернули 0.' \
'count() со счётным периодом #5, оператором "eq".' \
'^count\(/srv1/icmpping,#5,"eq","0"\)>=3$' \
'count(/srv1/icmpping,#5,"eq","0")>=3'

add_task \
'Хост db1. Написать триггер: за последние 20 минут mysql.status[Threads_connected] превышал 200 ровно 1 раз.' \
'count() с периодом 20m, оператором "gt".' \
'^count\(/db1/mysql\.status\[Threads_connected\],20m,"gt","200"\)=1$' \
'count(/db1/mysql.status[Threads_connected],20m,"gt","200")=1'

add_task \
'Хост srv1. Написать триггер: нет данных по item vfs.fs.size[/,pfree] за последние 15 минут.' \
'nodata() с периодом 15m.' \
'^nodata\(/srv1/vfs\.fs\.size\[/,pfree\],15m\)=1$' \
'nodata(/srv1/vfs.fs.size[/,pfree],15m)=1'

add_task \
'Хост db1. Написать триггер: нет данных по item mysql.status[Threads_connected] за последние 5 минут.' \
'nodata() с периодом 5m.' \
'^nodata\(/db1/mysql\.status\[Threads_connected\],5m\)=1$' \
'nodata(/db1/mysql.status[Threads_connected],5m)=1'

add_task \
'Хост web1. Написать триггер: нет данных по item net.tcp.service.perf[http] за последние 10 минут.' \
'nodata() с периодом 10m.' \
'^nodata\(/web1/net\.tcp\.service\.perf\[http\],10m\)=1$' \
'nodata(/web1/net.tcp.service.perf[http],10m)=1'

add_task \
'Хост ws1. Написать триггер: нет данных по item system.cpu.util за последние 20 минут.' \
'nodata() с периодом 20m.' \
'^nodata\(/ws1/system\.cpu\.util,20m\)=1$' \
'nodata(/ws1/system.cpu.util,20m)=1'

add_task \
'Хост sw1. Написать триггер: нет данных по item net.if.in[eth0] за последние 30 минут.' \
'nodata() с периодом 30m.' \
'^nodata\(/sw1/net\.if\.in\[eth0\],30m\)=1$' \
'nodata(/sw1/net.if.in[eth0],30m)=1'

add_task \
'Хост mail1. Написать триггер: нет данных по item net.tcp.service[smtp] за последние 5 минут.' \
'nodata() с периодом 5m.' \
'^nodata\(/mail1/net\.tcp\.service\[smtp\],5m\)=1$' \
'nodata(/mail1/net.tcp.service[smtp],5m)=1'

add_task \
'Хост srv2. Написать триггер: нет данных по item system.cpu.load за последний час.' \
'nodata() с периодом 1h.' \
'^nodata\(/srv2/system\.cpu\.load,1h\)=1$' \
'nodata(/srv2/system.cpu.load,1h)=1'

add_task \
'Хост srv1. Написать триггер: нет данных по item log_item (лог не пишется) за последние 30 минут.' \
'nodata() с периодом 30m.' \
'^nodata\(/srv1/log_item,30m\)=1$' \
'nodata(/srv1/log_item,30m)=1'

add_task \
'Хост db1. Написать триггер: нет данных по item vfs.fs.size[/var/lib/mysql,pfree] за последние 10 минут в строгом режиме.' \
'nodata() с периодом 10m и третьим параметром "strict".' \
'^nodata\(/db1/vfs\.fs\.size\[/var/lib/mysql,pfree\],10m,"strict"\)=1$' \
'nodata(/db1/vfs.fs.size[/var/lib/mysql,pfree],10m,"strict")=1'

add_task \
'Хост web1. Написать триггер: нет данных по item proc.num[nginx] за последние 5 минут.' \
'nodata() с периодом 5m.' \
'^nodata\(/web1/proc\.num\[nginx\],5m\)=1$' \
'nodata(/web1/proc.num[nginx],5m)=1'

add_task \
'Хост srv1. Написать триггер: значение system.uptime уменьшилось относительно предыдущего (произошёл перезапуск).' \
'change() = текущее минус предыдущее значение; при перезапуске оно отрицательное.' \
'^change\(/srv1/system\.uptime\)<0$' \
'change(/srv1/system.uptime)<0'

add_task \
'Хост db1. Написать триггер: значение mysql.status[Threads_connected] изменилось относительно предыдущего.' \
'diff() возвращает 1, если последнее значение отличается от предыдущего.' \
'^diff\(/db1/mysql\.status\[Threads_connected\]\)=1$' \
'diff(/db1/mysql.status[Threads_connected])=1'

add_task \
'Хост web1. Написать триггер: количество процессов nginx (item proc.num[nginx]) изменилось относительно предыдущего значения.' \
'diff() без периода.' \
'^diff\(/web1/proc\.num\[nginx\]\)=1$' \
'diff(/web1/proc.num[nginx])=1'

add_task \
'Хост srv2. Написать триггер: входящий трафик (item net.if.in[eth0]) увеличился более чем на 500000000 относительно предыдущего значения.' \
'change() без периода.' \
'^change\(/srv2/net\.if\.in\[eth0\]\)>500000000$' \
'change(/srv2/net.if.in[eth0])>500000000'

add_task \
'Хост mail1. Написать триггер: доступность SMTP (item net.tcp.service[smtp]) изменилась относительно предыдущей проверки.' \
'diff() без периода.' \
'^diff\(/mail1/net\.tcp\.service\[smtp\]\)=1$' \
'diff(/mail1/net.tcp.service[smtp])=1'

add_task \
'Хост web1. Написать триггер: 95-й перцентиль времени отклика HTTP (item net.tcp.service.perf[http]) за последний час больше 2 секунд.' \
'percentile() с периодом 1h и процентилем 95.' \
'^percentile\(/web1/net\.tcp\.service\.perf\[http\],1h,95\)>2$' \
'percentile(/web1/net.tcp.service.perf[http],1h,95)>2'

add_task \
'Хост srv1. Написать триггер: 90-й перцентиль загрузки CPU (item system.cpu.load) за последние 30 минут больше 6.' \
'percentile() с периодом 30m и процентилем 90.' \
'^percentile\(/srv1/system\.cpu\.load,30m,90\)>6$' \
'percentile(/srv1/system.cpu.load,30m,90)>6'

add_task \
'Хост db1. Написать триггер: 99-й перцентиль числа подключений (item mysql.status[Threads_connected]) за последний час больше 300.' \
'percentile() с периодом 1h и процентилем 99.' \
'^percentile\(/db1/mysql\.status\[Threads_connected\],1h,99\)>300$' \
'percentile(/db1/mysql.status[Threads_connected],1h,99)>300'

add_task \
'Хост srv2. Написать триггер: 50-й перцентиль (медиана) доступной памяти (item vm.memory.size[pavailable]) за последние 2 часа меньше 15%.' \
'percentile() с периодом 2h и процентилем 50.' \
'^percentile\(/srv2/vm\.memory\.size\[pavailable\],2h,50\)<15$' \
'percentile(/srv2/vm.memory.size[pavailable],2h,50)<15'

add_task \
'Хост sw1. Написать триггер: 95-й перцентиль входящего трафика (item net.if.in[eth0]) за последние 15 минут больше 900000000.' \
'percentile() с периодом 15m и процентилем 95.' \
'^percentile\(/sw1/net\.if\.in\[eth0\],15m,95\)>900000000$' \
'percentile(/sw1/net.if.in[eth0],15m,95)>900000000'

add_task \
'Хост srv1. Написать триггер: среднее значение по трендам (item system.cpu.load) за последний день больше 5.' \
'trendavg() с периодом 1d.' \
'^trendavg\(/srv1/system\.cpu\.load,1d\)>5$' \
'trendavg(/srv1/system.cpu.load,1d)>5'

add_task \
'Хост db1. Написать триггер: максимальное значение по трендам (item mysql.status[Threads_connected]) за последнюю неделю больше 500.' \
'trendmax() с периодом 1w.' \
'^trendmax\(/db1/mysql\.status\[Threads_connected\],1w\)>500$' \
'trendmax(/db1/mysql.status[Threads_connected],1w)>500'

add_task \
'Хост web1. Написать триггер: минимальное значение по трендам (item net.tcp.service[http]) за последний месяц равно 0 (были простои).' \
'trendmin() с периодом 1M.' \
'^trendmin\(/web1/net\.tcp\.service\[http\],1M\)=0$' \
'trendmin(/web1/net.tcp.service[http],1M)=0'

add_task \
'Хост srv2. Написать триггер: суммарное значение по трендам (item net.if.in[eth0]) за последний день больше 5000000000.' \
'trendsum() с периодом 1d.' \
'^trendsum\(/srv2/net\.if\.in\[eth0\],1d\)>5000000000$' \
'trendsum(/srv2/net.if.in[eth0],1d)>5000000000'

add_task \
'Хост sw1. Написать триггер: количество сохранённых часовых значений трендов (item net.if.in[eth0]) за последний день меньше 20 (пропуски в данных).' \
'trendcount() с периодом 1d.' \
'^trendcount\(/sw1/net\.if\.in\[eth0\],1d\)<20$' \
'trendcount(/sw1/net.if.in[eth0],1d)<20'

add_task \
'Хост srv1. Написать триггер: по данным за последний час прогноз (forecast) свободного места (item vfs.fs.size[/,pfree]) через 1 день будет меньше 5%.' \
'forecast(item,период_данных,время_прогноза).' \
'^forecast\(/srv1/vfs\.fs\.size\[/,pfree\],1h,1d\)<5$' \
'forecast(/srv1/vfs.fs.size[/,pfree],1h,1d)<5'

add_task \
'Хост db1. Написать триггер: по данным за последние 30 минут прогноз числа подключений (item mysql.status[Threads_connected]) через 2 часа превысит 500.' \
'forecast(item,период_данных,время_прогноза).' \
'^forecast\(/db1/mysql\.status\[Threads_connected\],30m,2h\)>500$' \
'forecast(/db1/mysql.status[Threads_connected],30m,2h)>500'

add_task \
'Хост srv1. Написать триггер: по данным за последний час расчётное время (timeleft) до падения свободного места (item vfs.fs.size[/,pfree]) ниже порога 5% меньше 1 дня.' \
'timeleft(item,период_данных,порог).' \
'^timeleft\(/srv1/vfs\.fs\.size\[/,pfree\],1h,5\)<1d$' \
'timeleft(/srv1/vfs.fs.size[/,pfree],1h,5)<1d'

add_task \
'Хост srv2. Написать триггер: по данным за последние 30 минут расчётное время (timeleft) до падения доступной памяти (item vm.memory.size[pavailable]) ниже порога 10% меньше 2 часов.' \
'timeleft(item,период_данных,порог).' \
'^timeleft\(/srv2/vm\.memory\.size\[pavailable\],30m,10\)<2h$' \
'timeleft(/srv2/vm.memory.size[pavailable],30m,10)<2h'

add_task \
'Хост mail1. Написать триггер: по данным за последний час расчётное время (timeleft) до превышения очередью писем (item mail.queue.size) порога 1000 меньше 6 часов.' \
'timeleft(item,период_данных,порог).' \
'^timeleft\(/mail1/mail\.queue\.size,1h,1000\)<6h$' \
'timeleft(/mail1/mail.queue.size,1h,1000)<6h'

add_task \
'Хост srv1. Написать триггер: последнее значение лога (item log_item) содержит подстроку "CRITICAL".' \
'find(item,,"like","паттерн") без указания периода означает проверку последнего значения (два подряд идущих запятых).' \
'^find\(/srv1/log_item,,"like","CRITICAL"\)=1$' \
'find(/srv1/log_item,,"like","CRITICAL")=1'

add_task \
'Хост web1. Написать триггер: в последних 10 записях лога (item log_item) есть совпадение с регулярным выражением "50[0-9]".' \
'find() со счётным периодом #10 и оператором "regexp".' \
'^find\(/web1/log_item,#10,"regexp","50\[0-9\]"\)=1$' \
'find(/web1/log_item,#10,"regexp","50[0-9]")=1'

add_task \
'Хост mail1. Написать триггер: в последних 20 записях лога (item log_item) встречается слово "reject" без учёта регистра.' \
'find() со счётным периодом #20 и оператором "iregexp".' \
'^find\(/mail1/log_item,#20,"iregexp","reject"\)=1$' \
'find(/mail1/log_item,#20,"iregexp","reject")=1'

add_task \
'Хост srv2. Написать триггер: в последних 5 записях лога (item log_item) НЕТ совпадений со словом "OK".' \
'find() со счётным периодом #5 и оператором "like"; результат сравнивается с 0.' \
'^find\(/srv2/log_item,#5,"like","OK"\)=0$' \
'find(/srv2/log_item,#5,"like","OK")=0'

add_task \
'Хост db1. Написать триггер: последнее событие лога (item log_item) имеет ID события, совпадающий с шаблоном "^1000$".' \
'logeventid(item,паттерн), без периода.' \
'^logeventid\(/db1/log_item,"\^1000\$"\)=1$' \
'logeventid(/db1/log_item,"^1000$")=1'

add_task \
'Хост ws1. Написать триггер: последнее событие Windows-журнала (item eventlog[Application]) соответствует шаблону ID "^(4625|529)$" (неудачный вход).' \
'logeventid(item,паттерн).' \
'^logeventid\(/ws1/eventlog\[Application\],"\^\(4625\|529\)\$"\)=1$' \
'logeventid(/ws1/eventlog[Application],"^(4625|529)$")=1'

add_task \
'Хост srv1. Написать триггер: системное время хоста (item system.localtime) рассинхронизировано с сервером Zabbix более чем на 60 секунд.' \
'fuzzytime(item,sec) возвращает 0, если рассинхронизация превышает лимит.' \
'^fuzzytime\(/srv1/system\.localtime,60\)=0$' \
'fuzzytime(/srv1/system.localtime,60)=0'

add_task \
'Хост srv2. Написать триггер: в последних 3 записях лога (item log_item) встречается слово "PANIC".' \
'find() со счётным периодом #3 и оператором "like".' \
'^find\(/srv2/log_item,#3,"like","PANIC"\)=1$' \
'find(/srv2/log_item,#3,"like","PANIC")=1'

add_task \
'Хост mail1. Написать триггер: за последние 15 минут в логе (item log_item) есть совпадение с регулярным выражением "(virus|malware)" без учёта регистра.' \
'find() с периодом 15m и оператором "iregexp".' \
'^find\(/mail1/log_item,15m,"iregexp","\(virus\|malware\)"\)=1$' \
'find(/mail1/log_item,15m,"iregexp","(virus|malware)")=1'

add_task \
'Хост db1. Написать триггер: в последних 5 записях лога (item log_item) НЕТ совпадений с регулярным выражением "ERROR|FATAL".' \
'find() со счётным периодом #5 и оператором "regexp"; результат сравнивается с 0.' \
'^find\(/db1/log_item,#5,"regexp","ERROR\|FATAL"\)=0$' \
'find(/db1/log_item,#5,"regexp","ERROR|FATAL")=0'

add_task \
'Хост srv1. Написать триггер: сегодня выходной (суббота или воскресенье) и средняя загрузка CPU (item system.cpu.load) за последние 5 минут больше 8.' \
'Используйте функцию dayofweek(); часть с or оберните в скобки, условия объедините через and (все ключевые слова строчными буквами, без лишних пробелов внутри скобок).' \
'^avg\(/srv1/system\.cpu\.load,5m\)>8and\(dayofweek\(\)=6ordayofweek\(\)=7\)$' \
'avg(/srv1/system.cpu.load,5m)>8 and (dayofweek()=6 or dayofweek()=7)'

add_task \
'Хост web1. Написать триггер: одновременно недоступны и сервис (item net.tcp.service[http]), и агент (item agent.ping) — проблема на уровне всего хоста.' \
'Соедините два условия last()=0 через and.' \
'^last\(/web1/net\.tcp\.service\[http\]\)=0andlast\(/web1/agent\.ping\)=0$' \
'last(/web1/net.tcp.service[http])=0 and last(/web1/agent.ping)=0'

add_task \
'Хосты srv1 и srv2. Написать триггер: средняя загрузка CPU (item system.cpu.load) за последние 5 минут больше 5 одновременно на обоих хостах.' \
'Два условия avg(), объединённые через and, каждое со своим хостом.' \
'^avg\(/srv1/system\.cpu\.load,5m\)>5andavg\(/srv2/system\.cpu\.load,5m\)>5$' \
'avg(/srv1/system.cpu.load,5m)>5 and avg(/srv2/system.cpu.load,5m)>5'

add_task \
'Хост db1. Написать триггер: заканчивается место (item vfs.fs.size[/,pfree] меньше 15%) ИЛИ слишком много подключений (item mysql.status[Threads_connected] больше 300).' \
'Соедините два условия через or.' \
'^last\(/db1/vfs\.fs\.size\[/,pfree\]\)<15orlast\(/db1/mysql\.status\[Threads_connected\]\)>300$' \
'last(/db1/vfs.fs.size[/,pfree])<15 or last(/db1/mysql.status[Threads_connected])>300'

add_task \
'Хост ws1. Написать триггер: сейчас окно с 02:00 до 04:00 (функция time()) и при этом загрузка CPU (item system.cpu.util) за последние 5 минут выше 90%.' \
'time() возвращает текущее время в формате ЧЧММСС; сравните его с 020000 и 040000, все условия объедините через and.' \
'^avg\(/ws1/system\.cpu\.util,5m\)>90andtime\(\)>020000andtime\(\)<040000$' \
'avg(/ws1/system.cpu.util,5m)>90 and time()>020000 and time()<040000'

add_task \
'Хост db1. Написать триггер (гипотетический item mysql.status_flags — битовая маска): у последнего значения установлен бит 4.' \
'count() со счётным периодом #1, оператором "band" и паттерном "4" (проверка последнего значения через побитовое И).' \
'^count\(/db1/mysql\.status_flags,#1,"band","4"\)=1$' \
'count(/db1/mysql.status_flags,#1,"band","4")=1'

add_task \
'Хост srv1. Написать триггер: важность последней записи лога (item log_item) не ниже Warning (числовой код 2).' \
'logseverity(item) возвращает числовой код важности последней записи лога, без периода.' \
'^logseverity\(/srv1/log_item\)>=2$' \
'logseverity(/srv1/log_item)>=2'

add_task \
'Хост mail1. Написать триггер: заряд батареи ИБП (гипотетический item ups.battery.charge) меньше 30%.' \
'last() без периода.' \
'^last\(/mail1/ups\.battery\.charge\)<30$' \
'last(/mail1/ups.battery.charge)<30'

add_task \
'Хост srv2. Написать триггер: среднее число операций чтения с диска sda (item vfs.dev.read[sda,ops]) за последние 5 минут больше 1000.' \
'avg() с периодом 5m.' \
'^avg\(/srv2/vfs\.dev\.read\[sda,ops\],5m\)>1000$' \
'avg(/srv2/vfs.dev.read[sda,ops],5m)>1000'

add_task \
'Хост web1. Написать триггер: среднее время выполнения веб-сценария целиком (item web.test.time[scenario1,,total]) за последние 10 минут больше 5 секунд.' \
'avg() с периодом 10m.' \
'^avg\(/web1/web\.test\.time\[scenario1,,total\],10m\)>5$' \
'avg(/web1/web.test.time[scenario1,,total],10m)>5'

add_task \
'Хост web1. Написать триггер: последний код ответа веб-проверки (item web.test.rspcode[scenario1,step1]) не равен 200.' \
'last() без периода; оператор неравенства в Zabbix записывается как <>.' \
'^last\(/web1/web\.test\.rspcode\[scenario1,step1\]\)<>200$' \
'last(/web1/web.test.rspcode[scenario1,step1])<>200'

add_task \
'Хост srv2. Написать триггер: среднее время ожидания в очереди (гипотетический item mq.queue.wait) за последние 10 минут больше 30 секунд.' \
'avg() с периодом 10m.' \
'^avg\(/srv2/mq\.queue\.wait,10m\)>30$' \
'avg(/srv2/mq.queue.wait,10m)>30'

add_task \
'Хост db1. Написать триггер: репликация MySQL остановлена (item mysql.status[Slave_SQL_Running] равен 0).' \
'last() без периода.' \
'^last\(/db1/mysql\.status\[Slave_SQL_Running\]\)=0$' \
'last(/db1/mysql.status[Slave_SQL_Running])=0'

add_task \
'Хост sw1. Написать триггер: средняя температура коммутатора (item sensor.temp.value) за последние 10 минут больше 70.' \
'avg() с периодом 10m.' \
'^avg\(/sw1/sensor\.temp\.value,10m\)>70$' \
'avg(/sw1/sensor.temp.value,10m)>70'

add_task \
'Хост mail1. Написать триггер: минимальное свободное место в очереди почты (item vfs.fs.size[/var/spool,pfree]) за последние 30 минут меньше 15%.' \
'min() с периодом 30m.' \
'^min\(/mail1/vfs\.fs\.size\[/var/spool,pfree\],30m\)<15$' \
'min(/mail1/vfs.fs.size[/var/spool,pfree],30m)<15'

TOTAL=${#TASKS_DESC[@]}

normalize() {
    printf '%s' "$1" | tr -d ' \t'
}

print_header() {
    echo -e "${CYAN}${BOLD}=== Тренажёр триггеров Zabbix ===${NC}"
}

# Возвращает: 0 - верно, 1 - выход, 2 - показан ответ (пропуск)
ask_task() {
    local idx=$1
    echo
    echo -e "${BOLD}Задача:${NC} ${TASKS_DESC[$idx]}"
    while true; do
        echo -en "${YELLOW}Ваш ответ${NC} (h - подсказка, s - показать ответ, q - выйти из тренировки): "
        if ! read -r answer; then
            return 1
        fi
        case "$answer" in
            h|H)
                echo -e "${CYAN}Подсказка:${NC} ${TASKS_HINT[$idx]}"
                ;;
            s|S)
                echo -e "${YELLOW}Пример правильного ответа:${NC} ${TASKS_EXAMPLE[$idx]}"
                SKIPPED=$((SKIPPED+1))
                return 2
                ;;
            q|Q)
                return 1
                ;;
            *)
                local norm
                norm=$(normalize "$answer")
                if [[ "$norm" =~ ${TASKS_REGEX[$idx]} ]]; then
                    echo -e "${GREEN}Верно!${NC}"
                    CORRECT=$((CORRECT+1))
                    return 0
                else
                    echo -e "${RED}Неверно.${NC} Попробуйте ещё раз (или введите h / s)."
                fi
                ;;
        esac
    done
}

run_training() {
    local order=("$@")
    CORRECT=0
    SKIPPED=0
    local n=${#order[@]}
    local interrupted=0
    for idx in "${order[@]}"; do
        ask_task "$idx"
        local rc=$?
        if [[ $rc -eq 1 ]]; then
            interrupted=1
            echo
            echo -e "${YELLOW}Тренировка прервана.${NC}"
            break
        fi
    done
    echo
    echo -e "${BOLD}Итог:${NC} правильно с первой/последующих попыток — ${CORRECT}, показан ответ — ${SKIPPED}, всего задач в заходе — ${n}."
}

shuffle_indices() {
    seq 0 $((TOTAL-1)) | shuf
}

ordered_indices() {
    seq 0 $((TOTAL-1))
}

show_all_tasks() {
    for ((i=0;i<TOTAL;i++)); do
        echo -e "${BOLD}[$((i+1))]${NC} ${TASKS_DESC[$i]}"
    done
}

choose_task() {
    show_all_tasks
    echo -en "Введите номер задачи: "
    read -r num
    if [[ "$num" =~ ^[0-9]+$ ]] && (( num>=1 && num<=TOTAL )); then
        CORRECT=0
        SKIPPED=0
        ask_task $((num-1))
        echo
        echo -e "${BOLD}Итог по задаче:${NC} правильно — ${CORRECT}, показан ответ — ${SKIPPED}."
    else
        echo -e "${RED}Некорректный номер.${NC}"
    fi
}

main_menu() {
    while true; do
        echo
        print_header
        echo "1) Тренировка (случайный порядок, все ${TOTAL} задач)"
        echo "2) Тренировка по порядку"
        echo "3) Выбрать конкретную задачу"
        echo "4) Показать список всех задач"
        echo "5) Выход"
        echo -en "Выбор: "
        if ! read -r choice; then
            echo; echo "Пока!"; exit 0
        fi
        case "$choice" in
            1) mapfile -t idxs < <(shuffle_indices); run_training "${idxs[@]}" ;;
            2) mapfile -t idxs < <(ordered_indices); run_training "${idxs[@]}" ;;
            3) choose_task ;;
            4) show_all_tasks ;;
            5) echo "Пока!"; exit 0 ;;
            *) echo -e "${RED}Некорректный выбор.${NC}" ;;
        esac
    done
}

main_menu
