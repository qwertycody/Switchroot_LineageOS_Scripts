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
    rm -Rf ~/platform-tools-latest-linux.zip
    rm -Rf ~/platform-tools

    curl -o ~/platform-tools-latest-linux.zip "https://dl.google.com/android/repository/platform-tools-latest-linux.zip"

    unzip -o platform-tools-latest-linux.zip -d ~

    PATH_STRING_ALREADY_ADDED=$(misc_stringInFile '$HOME/platform-tools' "~/.profile")

    if [ "$PATH_STRING_ALREADY_ADDED" = "FALSE" ]
    then
        echo '# add Android SDK platform tools to path
if [ -d "$HOME/platform-tools" ] ; then
    PATH="$HOME/platform-tools:$PATH"
fi' >> ~/.profile
    fi

    source ~/.profile
}

function setup_packages()
{
    apt-get install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev
    apt-get install -y openjdk-9-jdk
}

function setup_repo_command()
{
    rm -Rf ~/bin/repo

    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    chmod a+x ~/bin/repo

    PATH_STRING_ALREADY_ADDED=$(misc_stringInFile '$HOME/bin' "~/.profile")

    if [ "$PATH_STRING_ALREADY_ADDED" = "FALSE" ]
    then
        echo '# set PATH so it includes users private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi' >> ~/.profile
    fi

    source ~/.profile
}

function setup_lineage_source()
{
    rm -Rf ~/android/lineage
    mkdir -p ~/android/lineage
    cd ~/android/lineage
    repo init -u https://github.com/LineageOS/android.git -b lineage-16.0
    repo sync
}

function main()
{
    setup_platform_tools
    setup_packages
    setup_repo_command
    setup_lineage_source
}

main