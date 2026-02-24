#!/bin/bash
set -e

# 1. Запоминаем папку GitHub, чтобы потом скинуть сюда прошивку
GH_DIR=$PWD

# 2. Уходим в папку /tmp на сервере Crave. Здесь полно места и сверхбыстрые SSD!
mkdir -p /tmp/build
cd /tmp/build

echo "=== Инициализация PixelOS ==="
repo init -u https://github.com/LF52406/android_manifest.git -b sixteen-qpr2 --git-lfs

echo "=== Создание локального манифеста ==="
mkdir -p .repo/local_manifests
cat << 'EOF' > .repo/local_manifests/mondrian.xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
    <project path="device/xiaomi/mondrian" name="LF52406/android_device_xiaomi_mondrian" remote="github" revision="lineage-23.2" />
    <project path="device/xiaomi/sm8450-common" name="LF52406/android_device_xiaomi_sm8450-common" remote="github" revision="lineage-23.2" />
    <project path="vendor/xiaomi/mondrian" name="LF52406/proprietary_vendor_xiaomi_mondrian" remote="github" revision="lineage-23.2" />
    <project path="vendor/xiaomi/sm8450-common" name="LF52406/proprietary_vendor_xiaomi_sm8450-common" remote="github" revision="lineage-23.2" />
    <project path="kernel/xiaomi/sm8450" name="LF52406/android_kernel_xiaomi_sm8450" remote="github" revision="lineage-23.2" />
    <project path="kernel/xiaomi/sm8450-modules" name="LineageOS/android_kernel_xiaomi_sm8450-modules" remote="github" revision="lineage-23.2" />
    <project path="kernel/xiaomi/sm8450-devicetrees" name="LineageOS/android_kernel_xiaomi_sm8450-devicetrees" remote="github" revision="lineage-23.2" />
    <project path="hardware/xiaomi" name="LineageOS/android_hardware_xiaomi" remote="github" revision="lineage-23.2" />
</manifest>
EOF

echo "=== Синхронизация исходников ==="
repo sync -c -j$(nproc --all) --force-sync --no-tags --no-clone-bundle

echo "=== Сборка прошивки ==="
source build/envsetup.sh
lunch pixelos_mondrian-userdebug
mka bacon -j$(nproc --all)

echo "=== Копирование прошивки на GitHub ==="
# Отправляем только готовую прошивку весом 2 ГБ, а не 150 ГБ исходников!
cp out/target/product/mondrian/*.zip $GH_DIR/
echo "Сборка успешно завершена!"
