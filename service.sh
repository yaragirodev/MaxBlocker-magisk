#!/system/bin/sh
# Magisk service script: bind-mount a custom hosts file to block max.ru
# Runs at boot (late_start service mode).

MODDIR="${0%/*}"
TARGET="/system/etc/hosts"
OURHOSTS="$MODDIR/hosts"

log() {
  echo "[MBv1.2-siteblock] $1" > /dev/kmsg 2>/dev/null || log -t MBv1.2-siteblock "$1"
}

for i in 1 2 3 4 5; do
  [ -e "$TARGET" ] && break
  sleep 1
done

if [ ! -f "$OURHOSTS" ]; then
  if [ -r "$TARGET" ]; then
    cp -f "$TARGET" "$OURHOSTS"
  else
    # Minimal hosts baseline
    cat > "$OURHOSTS" <<'EOF'
127.0.0.1 localhost
::1 localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
  fi
fi

ensure_entry() {
  DOMAIN="$1"
  if ! grep -qE "^[[:space:]]*127\.0\.0\.1[[:space:]]+$DOMAIN(\s|$)" "$OURHOSTS" 2>/dev/null; then
    printf "\n127.0.0.1\t%s\n" "$DOMAIN" >> "$OURHOSTS"
  fi
  if ! grep -qE "^[[:space:]]*::1[[:space:]]+$DOMAIN(\s|$)" "$OURHOSTS" 2>/dev/null; then
    printf "::1\t%s\n" "$DOMAIN" >> "$OURHOSTS"
  fi
}

ensure_entry "max.ru"
ensure_entry "www.max.ru"
ensure_entry "download.max.ru"

mountpoint=""
mountpoint=$(toybox mount | grep " $TARGET " || true)
if [ -n "$mountpoint" ]; then
  # Attempt to unmount any previous bind to avoid stacking
  umount -l "$TARGET" 2>/dev/null
fi

mount -o bind "$OURHOSTS" "$TARGET" && log "Bound custom hosts to $TARGET"
chmod 644 "$OURHOSTS" 2>/dev/null

exit 0
