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
    git clone https://gitlab.com/switchroot/android/manifest.git $HOME/android/lineage/,repo/local_manifests
    cd $HOME/android/lineage
    repo sync
}

function main()
{
    setup_platform_tools
    setup_packages
    setup_repo_command
    setup_lineage_source
    setup_switchroot_manifest
}

main