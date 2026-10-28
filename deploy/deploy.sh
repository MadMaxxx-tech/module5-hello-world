#!/usr/bin/env bash
set -euo pipefail

: "${VERSION:?VERSION is required}"
: "${NEXUS_URL:?NEXUS_URL is required}"
: "${NEXUS_USER:?NEXUS_USER is required}"
: "${NEXUS_PASSWORD:?NEXUS_PASSWORD is required}"
: "${NEXUS_REPO:?NEXUS_REPO is required}"

APP_DIR="/opt/hello-world"
ARCHIVE_NAME="hello-world_${VERSION}.tar.gz"
ARCHIVE_PATH="${APP_DIR}/${ARCHIVE_NAME}"
BINARY_NAME="hello-world_${VERSION}"
CURRENT_BINARY="${APP_DIR}/hello-world"
BACKUP_BINARY="${APP_DIR}/hello-world_bkp"

echo "Deploying hello-world version ${VERSION}"

# Устанавливаем systemd unit
sudo cp deploy/hello-world.service /etc/systemd/system/hello-world.service

# Скачиваем архив из Nexus
curl -f -u "${NEXUS_USER}:${NEXUS_PASSWORD}" \
  -o "${ARCHIVE_PATH}" \
  "${NEXUS_URL}/repository/${NEXUS_REPO}/${VERSION}/${ARCHIVE_NAME}"

# Распаковываем архив
tar -xzf "${ARCHIVE_PATH}" -C "${APP_DIR}"

# Делаем backup предыдущей версии
if [ -f "${CURRENT_BINARY}" ]; then
  mv "${CURRENT_BINARY}" "${BACKUP_BINARY}"
fi

# Активируем новую версию под стабильным именем
mv "${APP_DIR}/${BINARY_NAME}" "${CURRENT_BINARY}"
chmod +x "${CURRENT_BINARY}"

# Удаляем временный архив
rm -f "${ARCHIVE_PATH}"

# Применяем unit и перезапускаем сервис
sudo systemctl daemon-reload
sudo systemctl enable hello-world
sudo systemctl restart hello-world

# Проверяем работоспособность
sleep 2
curl -fsS http://127.0.0.1:8080/

echo
echo "Deploy completed: hello-world ${VERSION}"
