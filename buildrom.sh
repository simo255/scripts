#!/bin/bash
# Easier to make a script and describe within what is happening. If you are happy with this script, or are done editing,
# to activate the script type in terminal '$ bash <filepath>/buildrom.sh'
# Do note this script default compiles LineageOS 15.1 for both starlte and star2lte, so reduce the script as you want.
sudo apt install -y openjdk-8-jdk git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip lunzip schedtool imagemagick
# The abvove will install packages that are needed to compile most ROM's, for systems above Ubuntu 14.04.
# If you find that during your compile of a ROM that it errors to require another package then simply add it to the end of the 
# above command.
mkdir ~/bin
PATH=~/bin:$PATH
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
# The above will install the repo tool which will enable you to download and then stay in sync with a ROM's source, if it's updated
# at remote.
git config --global user.name AzzyC
git config --global user.email azmath2000@gmail.com
# Change above config according to your GitHub account.
if [ ! -d "compiled" ]; then
mkdir -/compiled/
fi
if [ ! -d "rom" ]; then
mkdir ~/rom/
fi
cd ~/rom/
repo init -u git://github.com/LineageOS/android.git -b lineage-15.1
# This line will sync the ROM source for oreo based Lineage. Do edit if you want to build a build a different ROM with the
# according manifest.
cd .repo
git clone https://github.com/AzzyC/local_manifests.git
# If you are part of the Exynos 9810 family, the file brought from git cloning this repository will automatically sync 
# star and star2 device tree. If you have your own manifest for your devices trees, remove the above command.
cd ~/rom/
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
# This will begin syncing the ROM source.
# Initially downloading your ROM's source will take a lot of time (depending on your interent also, but if you aren't looking
# to change and build a different ROM, then you can simply hit the above command again and it will fetch any new updates from 
# the remote source, if there are any.
. build/envsetup.sh
lunch lineage_starlte-userdebug
# If you have changed to a different ROM source, then you should change the name of the 'lineage.mk' file found 
# in 'builddir/device/samsung/starlte' and rename it to ypur ROM's needed .mk. For example 'PixelExperience' would need 'aosp_starlte.mk'.
# Likewise, within this file change the name of the product/device, for example from lineage_starlte to aosp_starlte if you are
# building 'PixelExperience'.
make bacon -j$(nproc --all)
# This will use all available CPU threads to build, if you do not wish to do this remove '$(nproc --all)' and replace it with the number
# threads you would like to give. Example if you have 4 CPU Cores, then you can make 4 threads using '$ make bacon -j4'
mv ~/rom/out/target/product/starlte/lineage-15.1-*.zip ~/compiled/
mv ~/rom/out/target/product/starlte/lineage-15.1-*.md5sum ~/compiled/
# If you are building a different ROM, it will output a different zip and md5sum file name, so edit accordingly if you would like
# to move the files out and put them into the 'compiled' directory.
# The reason for the move is due to the below 'make clean' command which will wipe out the 'builddir/build' where the ROM .zip
# is also held.
toilet -f mono12 "star done"
# Just to let you know clearly in the terminal that starlte ROM has compiled.
make clean
# Start again fresh, for building the next device.
cd
cd ~/rom/
. build/envsetup.sh
lunch lineage_star2lte-userdebug
# If you have changed to a different ROM source, then you should change the name of the 'lineage.mk' file found 
# in 'builddir/device/samsung/star2lte' and rename it to ypur ROM's needed .mk. For example 'PixelExperience' would need 'aosp_star2lte.mk'.
# Likewise, within this file change the name of the product/device, for example from lineage_star2lte to aosp_star2lte if you are
# building 'PixelExperience'.
make bacon -j$(nproc --all)
# This will use all available CPU threads to build, if you do not wish to do this remove '$(nproc --all)' and replace it with the number
# threads you would like to give. Example if you have 4 CPU Cores, then you can make 4 threads using '$ make bacon -j4'
mv ~/rom/out/target/product/starlte/lineage-15.1-*.zip ~/compiled/
mv ~/rom/out/target/product/starlte/lineage-15.1-*.md5sum ~/compiled/
# If you are building a different ROM, it will output a different zip and md5sum file name, so edit accordingly if you would like
# to move the files out and put them into the 'compiled' directory.
toilet -f mono12 "star2 done"
# Just to let you know clearly in the terminal that star2lte ROM has compiled.
