#!/bin/bash
# Do note this script by default compiles LineageOS 15.1 for both starlte and star2lte. There are commands to build for crownlte
# and other ROM's but they have been disabled to focus on one function. 
# If you are happy with the default script, or are done editing, type in to your terminal:
# '$ sudo chmod +x scripts/buildrom.sh' - Make the script executable;
# '$ bash scripts/buildrom.sh' - Activate the script.
# Key: To enable a command, remove the '#' at the start of the line; to disbale a command, insert a '#'.
# Example commands have no space between the '#' and the start of the command, so enable as you please but also disable accordingly,
# to avoid command conflicts and potentially an unsuccessful script.
# I would reccomend to keep the entirity of the script, to ensure that the guided comments are still there for reference, 
# so only disbable the commands you no longer want/require.
# If you want to stop/interupt the script at any point, input 'Ctrl + C'. You will notice that the script skiped the current
# process and moved onto the next command, but in most cases the script should abort anyway, due to a lacking command(s).
sudo apt update && sudo apt upgrade -y
# Update Distro's repository to be able to fetch and install all needed packages in next command.
sudo apt install -y openjdk-8-jdk toilet python gnupg flex clang gcc bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip lunzip schedtool imagemagick
# The abvove will install packages that are needed to compile most ROM's, for systems above Ubuntu 14.04.
# If you find that during your compile of a ROM that it errors to require another package then simply:
# '$ sudo apt install <saidpackagename>' and let me know so I can add it for future users.
# Once you have installed these building packages you can disable the command, as now you only need to update or upgrade.
mkdir ~/bin
PATH=~/bin:$PATH
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
# The above will install the repo tool which will allow you to download and then stay in sync with a ROM's Git source, if it is
# updated at remote.
# repo is a python wrapper for git.
git config --global user.name AzzyC
git config --global user.email azmath2000@gmail.com
# Change above config according to your GitHub account.
git config --global color.ui true
# Skips prompt on 'repo init' requiring User input for colourised tags during sync.
if [ ! -d "compiled" ]; then
# The script is checking 'if' the 'compiled' directory does not exist..
mkdir ~/compiled/
# 'then' to make one if there is not.
fi
if [ ! -d "rom" ]; then
# The script is checking 'if' the 'rom' directory does not exist..
mkdir ~/rom/
# 'then' to make one then to make one if there is not.
fi
cd ~/rom/
repo init -u https://github.com/LineageOS/android.git -b lineage-15.1
# This line will initialise a sync for oreo-based Lineage (15.1) ROM source. If you would like to build a build a different ROM,
# search on Google for '<romYouWantToBuildsName> manifest' e.g. 'bootleggers manifest', 'aex manifest'.
#
# To give an example of another ROM you could init(ialise), if you wanted oreo-based PixelExprience then your command should be:
#repo init -u https://github.com/PixelExperience/manifest -b oreo-mr1
# '-b' stands for branch which in most cases you have to specify as a different branch may be defaulted, within a
# particular repository. So become familiar with this and make sure you're not wasting time syncing an undesired source.
#
# A manifest is an .xml file which simply automates the cloning of all the all the ROM source directories, rather than a user
# manually having to clone hundreds of repositories leading to insanity. The manifest, can be found within a hidden directory where
# 'repo init' command occurred, called '.repo' => '~/rom/.repo/manifests'.
# I would advise you to inspect this manifest and the one that is 2 commands below.
cd .repo/
git clone https://github.com/AzzyC/local_manifests.git
# The file brought from cloning this repository will automatically clone repositories required for
# starxxx Device, Kernel and Vendor tree for Oreo. The file is commonly known as a 'roomservice.xml',
# as it fetches everything for you, but it could come under any name.
#
# This manifest will coincide with the ROM source manifest, when the script reaches the below '$ repo sync ..' command.
# Using these manifests as examples should give you enough knowledge to make your own, for a time of a tree bringup on a
# different device.
#
#git clone https://github.com/AzzyC/local_manifests.git -b lineage-16.0
# Cloning this repository holds the manifest to sync the Device, Kernel and Vendor alpha Pie tree for starxxx at the stage they were at,
# before they became private. DO NOT report bugs as they are known and most likely fixed in the private workings. You are expected
# to use these sources to experiment with an open-mind.
#
#git clone https://github.com/synt4x93/Manifest.git local_manifests
# To sync Crownlte's Device, Kernel and Vendor Tree instead, at version Oreo.
# Notice how on this command, local_manifests has been added. This is to direct a path which git should should clone the manfiest to,
# and this is where you should add your own manifests.
cd
cd ~/rom/
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
# This will begin syncing the ROM source. The attached tags should ensure an effective sync, otherwise you can just use '$ repo sync'
# Initially downloading your ROM's source will take a lot of time (factoring in your interent speed also), but if you aren't looking
# to change and build a different ROM's often, then you can simply hit the above command again and it will fetch any new updates from
# the remote source, if there are any. - You do not have to wait for the sync all over again.
. build/envsetup.sh
# This bashes a script tp setup a building workspace i.e. Tools, Paths etc. Validates if you have what is needed to compile.
lunch lineage_starlte-userdebug
# If you have changed to a different ROM source, then you should change the name of the 'lineage.mk' file found
# in '~/rom/device/samsung/starlte' and rename it to your ROM's needed .mk. For example 'PixelExperience' would
# need 'aosp_starlte.mk'.
# Likewise, within this file change the name of the product/device, for example from 'lineage_starlte' to aosp_starlte' if you are
# building 'PixelExperience'.
# Therefore, it would make sense to change the name of what you are 'lunch'ing, for example 'PixelExperience'
# would need '$ lunch aosp_starlte-userdebug'.	Hence in most cases, '$ lunch (romName)_(deviceName)-userdebug'
#
#lunch lineage_crownlte-userdebug
# The above comments for starlte apply to crownlte too, just change the names respectively.
make bacon -j$(nproc --all)
# This will use all available CPU threads to build, if you do not wish this remove '(nproc --all)' and replace it with
# the number of threads you would like to give to the compile. Example if you have 4 CPU Cores, then you can make 4
# threads using '$ make bacon -j4'
mv ~/rom/out/target/product/starlte/lineage-15.1-*.zip ~/compiled/
mv ~/rom/out/target/product/starlte/lineage-15.1-*.md5sum ~/compiled/
# If you are building a different ROM, it will output a different zip and md5sum file name, so edit accordingly if you would like
# to move the files out and put them into the 'compiled' directory.
# The reason for the move is to save time going through multiple directories, but if you don't mind it feel free to remove
# the command.
#
#mv ~/rom/out/target/product/crownlte/lineage-15.1-*.zip ~/compiled/
#mv ~/rom/out/target/product/crownlte/lineage-15.1-*.md5sum ~/compiled/
# If you would like the above comments to occur for crownlte.
toilet -f smblock "starlte done"
# To let you know clearly in the terminal that starlte ROM has compiled.
#
#toilet -f smblock "crownlte done"
# To let you know clearly in the terminal that crownlte ROM has compiled.
cd
cd ~/rom/
lunch lineage_star2lte-userdebug
# If you have changed to a different ROM source, then you should change the name of the 'lineage.mk' file found
# in '~/rom/device/samsung/star2lte' and rename it to your ROM's needed .mk. For example 'PixelExperience' would
# need 'aosp_star2lte.mk'.
# Likewise, within this file change the name of the product/device, for example from 'lineage_star2lte' to aosp_starlte' if you are
# building 'PixelExperience'.
# Therefore, it would make sense to change the name of what you are 'lunch'ing, for example 'PixelExperience'
# would need '$ lunch aosp_star2lte-userdebug'.	Hence in most cases, '$ lunch (romName)_(deviceName)-userdebug'
make bacon -j$(nproc --all)
# This will use all available CPU threads to build, if you do not wish this remove '(nproc --all)' and replace it with
# the number of threads you would like to give to the compile. Example if you have 4 CPU Cores, then you can make 4
# threads using '$ make bacon -j4'
mv ~/rom/out/target/product/star2lte/lineage-15.1-*.zip ~/compiled/
mv ~/rom/out/target/product/star2lte/lineage-15.1-*.md5sum ~/compiled/
# If you are building a different ROM, it will output a different zip and md5sum file name, so edit accordingly if you would like
# to move the files out and put them into the 'compiled' directory.
toilet -f smblock "star2lte done"
# To let you know clearly in the terminal that star2lte ROM has compiled.
make clean
# Clean out the obsolte workspace ready for the next time you bash this script. It is important that you 'make clean'
# from time to time, which clears build cache if it has been a long time since you have last built.
toilet -f smblock "script passed"
# To let you know clearly in the terminal that the script has finished. and it is safe to close terminal.
