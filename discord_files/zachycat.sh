#Follow https://wiki.lineageos.org/devices/foster/build upto "Prepare the device-specific code"
#Make sure to init with "lineage-16.0", not "lineage-15.1" or anything else during "Initialize the LineageOS source repository"
cd .repo
git clone https://gitlab.com/switchroot/android/manifest.git local_manifests
cd ../
repo sync
repopick -t nvidia-enhancements-p
repopick -t joycon-p 
repopick -t icosa-bt
cd vendor/lineage
patch -p1 < ../../.repo/local_manifests/patches/vendor_lineage-kmod.patch
cd ../../frameworks/native
patch -p1 < ../../.repo/local_manifests/patches/frameworks_native-hwc.patch
cd ../../
(Optional Start)
cd frameworks/base
patch -p1 < ../../.repo/local_manifests/patches/frameworks_base-rsmouse.patch
cd ../../vendor/nvidia
patch -p1 < ../../.repo/local_manifests/patches/0001-HACK-use-platform-sig-for-shieldtech.patch
cd ../../
cp .repo/local_manifests/patches/NvShieldTech-hack.apk vendor/nvidia/shield/shieldtech/app/NvShieldTech.apk
(Optional End)
source build/envsetup.sh
export USE_CCACHE=1
ccache -M 50G
`lunch lineage_foster_tab-userdebug` or `lunch lineage_icosa-userdebug` (either *should* work, I have only tested foster_tab, but others have reported Icosa works fine too)
make systemimage -j$(nproc)
make vendorimage -j$(nproc)
#Add `BOARD_MKBOOTIMG_ARGS    += --cmdline " "` at line 50 in device/nvidia/foster/BoardConfig.mk
make bootimage -j$(nproc)
#Download https://cdn.discordapp.com/attachments/604648722491768883/662677413037080600/part.sh and run `sudo ./part.sh /dev/sdX' (X obviously being whatever letter your SD card is :P)
#Download hekate and yeet it's contents to the fat32 HOS data partition
#Put this in /bootloader/ini https://cdn.discordapp.com/attachments/604648722491768883/662687691061592078/00-android.ini
#Put these in /switchroot_android in the fat32 HOS data partition https://cdn.discordapp.com/attachments/604648722491768883/662687795000901662/coreboot.rom and https://cdn.discordapp.com/attachments/604648722491768883/662687799111057419/boot.scr
#Run hekate, hold down vol + and -, and select the Android config while still holding them. Then plug the Switch into your PC
fastboot devices (to check that it's being detected)
cd out/target/product/foster_tab (or out/target/product/icosa if you built for icosa)
fastboot flash boot boot.img
fastboot flash vendor vendor.img
fastboot flash system system.img
fastboot flash dtb obj/KERNEL_OBJ/arch/arm64/boot/dts/tegra210-icosa.dtb
fastboot reboot
#Then boot hekate again, select the config, and it should boot