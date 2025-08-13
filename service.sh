#!/system/bin/sh

# Ждем загрузки системы
sleep 30

# Функция для удаления приложения
remove_max_app() {
    # Останавливаем приложение если оно запущено
    am force-stop ru.oneme.app 2>/dev/null
    
    # Пробуем удалить полностью (root)
    if su -c "pm uninstall ru.oneme.app" >/dev/null 2>&1; then
        echo "$(date): MAX app fully removed (root)" >> /data/local/tmp/max_blocker.log
    else
        # Если root нет — удаляем только для текущего пользователя
        pm uninstall --user 0 ru.oneme.app 2>/dev/null
        echo "$(date): MAX app removed for user 0" >> /data/local/tmp/max_blocker.log
    fi
}

# Проверяем наличие приложения и удаляем его
if pm list packages | grep -q "ru.oneme.app"; then
    remove_max_app
fi

# Мониторим каждые 10 секунд
while true; do
    sleep 10
    if pm list packages | grep -q "ru.oneme.app"; then
        remove_max_app
    fi
done &
