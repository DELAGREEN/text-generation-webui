#!/usr/bin/env expect

# Запускаем скрипт и автоматически отвечаем на вопросы PS Заполняем параметры по запросу stdin
spawn ./start_linux.sh

expect "Параметр 1:"
send "A\r"

expect "Параметр 2:"
send "N\r"

interact
