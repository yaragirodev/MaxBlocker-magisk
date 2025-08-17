#!/system/bin/sh

# Создаем директорию для логов
mkdir -p /data/local/tmp

# Блокируем приложение сразу после монтирования файловой системы
if pm list packages | grep -q "ru.oneme.app"; then
    pm disable-user ru.oneme.app 2>/dev/null
    echo "$(date): MAX disabled at boot" >> /data/local/tmp/max_blocker.log
fi
