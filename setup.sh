#!/bin/bash

function misc_stringInFile()
{
    STRING_TO_FIND="$1"
    FILE_TO_SEARCH="$2"

    if grep -qF "$STRING_TO_FIND" "$FILE_TO_SEARCH";then
        echo "TRUE"
    else
        echo "FALSE"
    fi
}

function setup_platform_tools()
{
    rm -Rf $HOME/platform-tools-latest-linux.zip
    rm -Rf $HOME/platform-tools

    sudo apt-get install -y curl

    curl -o $HOME/platform-tools-latest-linux.zip "https://dl.google.com/android/repository/platform-tools-latest-linux.zip"

    unzip -o platform-tools-latest-linux.zip -d $HOME

    PATH_STRING_ALREADY_ADDED=$(misc_stringInFile '$HOME/platform-tools' "$HOME/.profile")

    if [ "$PATH_STRING_ALREADY_ADDED" = "FALSE" ]
    then
        echo '# add Android SDK platform tools to path
if [ -d "$HOME/platform-tools" ] ; then
    PATH="$HOME/platform-tools:$PATH"
fi' >> $HOME/.profile
    fi

    source $HOME/.profile
}

function setup_packages()
{
    sudo apt-get install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev
    sudo apt-get install -y openjdk-9-jdk
}

function setup_repo_command()
{
    rm -Rf $HOME/bin/repo

    sudo apt-get install -y curl

    mkdir -p $HOME/bin/

    curl https://storage.googleapis.com/git-repo-downloads/repo > $HOME/bin/repo
    chmod a+x $HOME/bin/repo

    PATH_STRING_ALREADY_ADDED=$(misc_stringInFile '$HOME/bin' "$HOME/.profile")

    if [ "$PATH_STRING_ALREADY_ADDED" = "FALSE" ]
    then
        echo '# set PATH so it includes users private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi' >> $HOME/.profile
    fi

    source $HOME/.profile
}

function setup_lineage_source()
{
    mkdir -p $HOME/android/lineage
    cd $HOME/android/lineage
    repo init -u https://github.com/LineageOS/android.git -b lineage-16.0
    repo sync
}

function setup_switchroot_manifest()
{
    mkdir -p $HOME/android/lineage/.repo/local_manifests
    git clone https://gitlab.com/switchroot/android/manifest.git $HOME/android/lineage/.repo/local_manifests
    cd $HOME/android/lineage
    repo sync
}

function misc_getTimestamp()
{
    date +"%Y-%m-%d_%H-%M-%S"
}

function misc_applyPatch()
{
    DIRECTORY_TO_PATCH="$1"
    PATCH_FILE="$2"
    PATCH_NAME="$3"

    cd "$DIRECTORY_TO_PATCH"

    if ! patch -R -p1 -s -f --dry-run <$PATCH_FILE; then
        echo "Applying Patch $PATCH_NAME to $DIRECTORY_TO_PATCH"
        patch -p1 <patchfile
    else
        echo "Skipping Patch $PATCH_NAME to $DIRECTORY_TO_PATCH - Applied already or failed..."
    fi
}

function setup_patches()
{
    BASE_DIR="$HOME/android/lineage"
    PATCHES_DIR="$BASE_DIR/.repo/local_manifests/patches"

    cd $HOME/android/lineage
    repopick -t nvidia-enhancements-p
    repopick -t joycon-p 
    repopick -t icosa-bt
    misc_applyPatch "$BASE_DIR/vendor/lineage" "$PATCHES_DIR/vendor_lineage-kmod.patch" "vendor_lineage-kmod"
    misc_applyPatch "$BASE_DIR/frameworks/native" "$PATCHES_DIR/frameworks_native-hwc.patch" "frameworks_native-hwc.patch"
}

function setup_optional_patches()
{
    BASE_DIR="$HOME/android/lineage"
    PATCHES_DIR="$BASE_DIR/.repo/local_manifests/patches"

    misc_applyPatch "$BASE_DIR/frameworks/base" "$PATCHES_DIR/frameworks_base-rsmouse.patch" "frameworks_base-rsmouse.patch"
    misc_applyPatch "$BASE_DIR/vendor/nvidia" "$PATCHES_DIR/0001-HACK-use-platform-sig-for-shieldtech.patch" "0001-HACK-use-platform-sig-for-shieldtech.patch"
    
    #Backup Original NvShieldTech just in case 
    #Put a timestamp on file to preserve original if script is ran again

    mkdir -p "$HOME/Backups"

    NVIDIA_BACKUP_FILENAME="$HOME/Backups/NvShieldTech.apk_"
    NVIDIA_BACKUP_FILENAME+=$(misc_getTimestamp)

    cp -f "$BASE_DIR/vendor/nvidia/shield/shieldtech/app/NvShieldTech.apk" "$NVIDIA_BACKUP_FILENAME"

    #Overwrite NvShieldTech with Switchroot Version
    cp -f "$PATCHES_DIR/NvShieldTech-hack.apk" "$BASE_DIR/vendor/nvidia/shield/shieldtech/app/NvShieldTech.apk"
}

function misc_findReplace()
{
    VARIABLE_FIND="$1"
    VARIABLE_REPLACE="$2"
    VARIABLE_FILE="$3"

    sed -i "s/${VARIABLE_FIND}/${VARIABLE_REPLACE}/g" "$VARIABLE_FILE"
}

function setup_build_image()
{
    BASE_DIR="$HOME/android/lineage"
    cd "$BASE_DIR"

    source build/envsetup.sh
    export USE_CCACHE=1
    ccache -M 50G
    `lunch lineage_icosa-userdebug` #or `lunch lineage_foster_tab-userdebug` if the icosa variant doesn't work
    make systemimage -j$(nproc)
    make vendorimage -j$(nproc)

    #Modifying BoardConfig.mk
    BOARD_CONFIG_FILE="$HOME/device/nvidia/foster/BoardConfig.mk"
    BOARD_KERNEL_IMAGE_NAME='BOARD_KERNEL_IMAGE_NAME := zImage'
    BOARD_MKBOOTIMG_ARGS='BOARD_MKBOOTIMG_ARGS    += --cmdline " "'
    COMBINED_STRINGS="$BOARD_KERNEL_IMAGE_NAME\n$BOARD_MKBOOTIMG_ARGS"

    BOARD_MKBOOTIMG_ARGS_ADDED=$(misc_stringInFile "$BOARD_MKBOOTIMG_ARGS" "$BOARD_CONFIG_FILE")

    if [ "$BOARD_MKBOOTIMG_ARGS_ADDED" = "FALSE" ]
    then
       misc_findReplace "$BOARD_KERNEL_IMAGE_NAME" "$COMBINED_STRINGS" "$BOARD_CONFIG_FILE"
    fi

    make bootimage -j$(nproc)
}

function main()
{
    setup_platform_tools
    setup_packages
    setup_repo_command
    setup_lineage_source
    setup_switchroot_manifest
    setup_patches
    setup_optional_patches
    setup_build_image
}

main