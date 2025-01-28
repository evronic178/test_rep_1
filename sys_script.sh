#!/bin/bash

# Системные переменные для работы скрипта
HOME_LOG="/root/bin/script_log"
LOG_FILE="script_log.$(date +%Y.%m.%d)"
COLOR_1='\e[32m'
COLOR_2='\e[36m'
RESET='\e[0m'
TOTAL_MEM=$(free -h | grep Mem | awk '{print $2}')
USED_MEM=$(free -h | grep Mem | awk '{print $3}')
TOTAL_TIME=0
CONDITIONS_OZU=85  # Указывается значение использования ОЗУ при котором собираются Thread Dump
CONDITIONS_CPU=85  # Указывается значение нагрузки на CPU при которой собираются Thread Dump

# Переменные для подключения и работы Wildfly
WILDFLY_HOME="/u01/CM/wildfly"
HOST="localhost"
PORT_CLI="9990"
PORT_APP="8080"
URL="https://10.7.39.16:8080/ssrv-war/"

# Создание временных файлов
TEMP_FILE_CM5=$(mktemp)
TEMP_FILE_CMJ=$(mktemp)
TEMP_FILE_WF_CLI=$(mktemp)
TEMP_FILE_PZDC=$(mktemp)

# Переменные для подключения к удаленной БД PostgreSQL
DB_CM5="cm5_17_new"
DB_CMJ="cmj_17_new"
DB_USER="admin"
DB_PASSWORD="admin"
DB_HOST="10.7.39.8"
DB_PORT="5432"

# Переменные для содания Thread Dump
DUMP_FILE="thread_dump.$(date +%Y-%m-%d_%H:%M:%S)"
DUMP_DIR="/u01/CM/wildfly/ThreadDump"
JAVA_HOME="/u01/CM/liberica-1.8.0_345"
WF_SERVICE="/etc/systemd/system/wildfly.service"


# === Системные данные ===

if [ ! -d "$HOME_LOG" ]; then
    mkdir "$HOME_LOG"
fi
if [ ! -f "$HOME_LOG/$LOG_FILE" ]; then
   touch "$HOME_LOG/$LOG_FILE"
fi
# Отображение данных об ОЗУ и CPU
echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Общий объем ОЗУ в системе: ${COLOR_1}$TOTAL_MEM ${RESET}"
echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Объем занятой ОЗУ: ${COLOR_1}$USED_MEM ${RESET}"
echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Средняя нагрузка на ЦП за 1 минуту, 5 минут, 15 минут: ${COLOR_1}$(uptime | awk '{print $10}') $(uptime | awk '{print $11}') $( uptime | awk '{print $12}')${RESET}"

# Рассчет загрузки ОЗУ
OZU_LOAD=$(awk -v total="$(free | grep Mem | awk '{print $2}')" -v use="$(free | grep Mem | awk '{print $3}')" 'BEGIN {printf "%.2f", ((use / total) * 100)}')
echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Процент использования ОЗУ: ${COLOR_1}$OZU_LOAD%${RESET}"

# Рассчет загрузки CPU
CPU_STAT=$(cat /proc/stat | head -n 1)
CPU_TIME=(${CPU_STAT// / })
unset CPU_TIME[0]

CPU_IDLE_1="$(echo $CPU_STAT | awk '{print $5}')"
CPU_IDLE_2="$(echo $CPU_STAT | awk '{print $6}')"
CPU_IDLE_SUM="$(($CPU_IDLE_1 + $CPU_IDLE_2))"

for time in "${CPU_TIME[@]}";do
    TOTAL_TIME=$(($TOTAL_TIME + time ))
done

CPU_LOAD=$(awk -v total="$TOTAL_TIME" -v idle="$CPU_IDLE_SUM" 'BEGIN {printf "%.2f", 100 - ((idle / total) * 100)}')

echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Нагрузка на CPU составляет: ${COLOR_1}$CPU_LOAD%${RESET}"


# === Данные PostgreSQL ===

# Получение данных о количестве подключений к БД CM5
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_CM5" -t -A  -c "
SELECT COUNT(*)
FROM pg_stat_activity
WHERE datname = '$DB_CM5';
" > "$TEMP_FILE_CM5"

# Получение данных о количестве подключеий к БД CMJ
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_CMJ" -t -A  -c "
SELECT COUNT(*)
FROM pg_stat_activity
WHERE datname = '$DB_CMJ';
" > "$TEMP_FILE_CMJ"

# Извлечение количества активных подключений к CM5
ACTIVE_CONNECTION_CM5=$(cat "$TEMP_FILE_CM5")

# Извлечение количества активных подключений к CMJ
ACTIVE_CONNECTION_CMJ=$(cat "$TEMP_FILE_CMJ")

# Проверка успешности извлечения данных
if [ -n "$ACTIVE_CONNECTION_CM5" ]; then
    echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Количество активных подключений к CM5: ${COLOR_1}$(($ACTIVE_CONNECTION_CM5 - 1))${RESET}"
else
    echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Не удалось получить количество подключений к CM5"
fi

# Проверка успешности извлечения данных
if [ -n "$ACTIVE_CONNECTION_CMJ" ]; then
    echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Количество активных подключений к CMJ: ${COLOR_1}$(($ACTIVE_CONNECTION_CMJ - 1))${RESET}"
else
    echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Не удалось получить количество подключений к CMJ"
fi


# === Данные WIldFly ===

# Получение данных о количестве активных сессий WildFly
"$WILDFLY_HOME/bin/jboss-cli.sh" --connect --controller="$HOST:$PORT_CLI" --commands="/deployment=ssrv-rshb-war-7.0.3.226.war/subsystem=undertow/:read-attribute(name=active-sessions)" > "$TEMP_FILE_WF_CLI"

# Извлечение количества активных сессий к WildFly
ACTIVE_CONNECTION_WF=$(cat "$TEMP_FILE_WF_CLI" | grep result | awk '{print $3}')

# Вывод количества активных сессий WildFly
if [ -n "$ACTIVE_CONNECTION_WF" ]; then
    echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Количество активных сессий к серверу WildFly: ${COLOR_1}$ACTIVE_CONNECTION_WF${RESET}"
else
    echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Не удалось получить данные о количетсве активных сессий WildFly"
fi

# Получение времени отклика сервлета
RESPONSE_TIME=$(curl -w "%{time_total}" -o /dev/null  -s "$URL")

# Проверка получения времени ответа
if [ -n "$RESPONSE_TIME" ]; then
    echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Время отклика сервлета: ${COLOR_1}$RESPONSE_TIME${RESET} секунд"
else
    echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Не удалось получить время отклика сервлета. Error 3"
    exit 3
fi

# Отслеживаем данные о запросах
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -t -A  -c "
SELECT (state_change - query_start) AS time_in_work, (NOW() - query_start) AS time_in_progress,(NOW() - state_change) AS idle_time, datname, pid, state, client_addr, application_name
FROM pg_stat_activity
WHERE datname = '$DB_CM5' OR datname = '$DB_CMJ'
ORDER BY time_in_progress DESC;" > "$TEMP_FILE_PZDC"

# Определение статистики базы данных по активным запросам и последним выполенным запросам
if [ -s "$TEMP_FILE_PZDC" ]; then
    echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Количество серверных процессов БД"
    echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} В $DB_CM5: ${COLOR_1}$(cat "$TEMP_FILE_PZDC" | grep cm5_17_new | wc -l)${RESET} активных серверных процессов"
    echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} В $DB_CMJ: ${COLOR_1}$(cat "$TEMP_FILE_PZDC" | grep cmj_17_new | wc -l)${RESET} активных серверных процессов"
    if [[ $(cat "$TEMP_FILE_PZDC" | grep cmj_17_new | grep active | wc -l) != '0' ]]; then
        echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Количество серверных процессов с активными запросами в $DB_CMJ: ${COLOR_1} $(cat "$TEMP_FILE_PZDC" | \
            grep cmj_17_new| grep active | wc -l)${RESET}"
    else
        echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Активных запросов в $DB_CMJ нет"
    fi
    if [[ $(cat "$TEMP_FILE_PZDC" | grep cm5_17_new | grep active | wc -l) != '0' ]]; then
        echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Количество серверных процессов с активными запросами в $DB_CM5: ${COLOR_1}$(cat "$TEMP_FILE_PZDC" | grep cm5_17_new | grep active | wc -l)${RESET}"
    else
        echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Активных запросов в $DB_CM5 нет"
    fi
    echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Длительность выполнения последних запросов в CM5"
    echo -e "$( cat "$TEMP_FILE_PZDC" | grep cm5_17_new | awk -F '|' '{print $1}' | sort -r )"
    echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Длительность выполенния последних запросов в CMJ"
    echo -e "$( cat "$TEMP_FILE_PZDC" | grep cmj_17_new | awk -F '|' '{print $1}' | sort -r )"
else
    echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Данные по базам данных не получены. Error 4"
    exit 4
fi

cat "$TEMP_FILE_PZDC"


# Удаление временного файла со статистикой базы данных
rm "$TEMP_FILE_PZDC" "$TEMP_FILE_CM5" "$TEMP_FILE_CMJ" "$TEMP_FILE_WF_CLI"


# Создание Thread Dump

# Сбор Thread Dump при достижении пороговых значений в использовании ОЗУ или загруженности CPU
USER_WF=$(cat $WF_SERVICE | grep User | awk -F '=' '{print $2}')
PID_WF=$( "$JAVA_HOME/bin/jps" | grep jboss-modules | awk '{print $1}')

if [[ $(awk -v ozu_1=$OZU_LOAD -v ozu_2=$CONDITIONS_OZU 'BEGIN {if (ozu_1 >= ozu_2) print 1; else print 0}') -eq 1 ]] || \
    [[ $(awk -v cpu_1=$CPU_LOAD -v cpu_2=$CONDITIONS_CPU 'BEGIN {if (cpu_1 >= cpu_2) print 1; else print 0}') -eq 1 ]]; then
    if [[ -n $USER_WF && -n $PID_WF ]]; then
        if [ ! -d "$DUMP_DIR" ]; then
            mkdir "$DUMP_DIR"
            echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Директория для Thread Dump создана"
        fi
        touch "$DUMP_DIR/$DUMP_FILE"
        sudo -u "$USER_WF" "$JAVA_HOME/bin/jcmd" "$PID_WF" Thread.print > "$DUMP_DIR/$DUMP_FILE"
        echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Thread dump успешно создан в папке${COLOR_1} $DUMP_DIR${RESET} с названием ${COLOR_1}$DUMP_FILE${RESET}"
    else
        echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Не выполнены условия для сосздания Thread Dump. Error 5"
 exit 5
    fi
else
    echo -e "${COLOR_2}[$(date +"%Y-%m-%d %H:%M:%S")]${RESET} Показатели состояния сервера не превышают пороговых значений. Показаний для сбора Thread dump нет."
fi
