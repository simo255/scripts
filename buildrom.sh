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
# If you want to stop/interupt the script at any point, input 'Ctrl + C'. You will notice that the script skipped the current
# process and moved onto the next command, but in most cases the script should abort anyway, due to a lacking command(s).
# Be prepared to see errors though as the script comes to its end, because the later commands are based on the previous commands
# having been done.
# Lastly, this is open so don't hesitate to share your ideas too! Telling me how this script could be improved could also help
# future users, so please do let me know on Telegram, @inivisibazinga2, or do a 'Pull Request' (PR) on GitHub and I will 
# review and add your changes when I can!
touch .buildrombashed
sudo chmod +x ~/scripts/gcloudvnc.sh
# Give executable permission to other script(s).
if [ ! -e ~/.gcloudvncbashed ]; then
# If user has bashed the './gcloudvnc.sh' script, prior to this one, then there is no need to spend time checking for
# updates (to then upgrade) as it was already done. A placeholder file was created in the './gcloudvnc.sh' script
# called 'updated' to check for this.
sudo apt update && sudo apt upgrade -y
fi
# Update Distro's repository to be able to fetch and install all needed packages in next command.
UBUNTU_14_PACKAGES="binutils-static curl figlet git-core libesd0-dev libwxgtk2.8-dev"
UBUNTU_16_PACKAGES="libesd0-dev"
UBUNTU_18_PACKAGES="curl"
PACKAGES=""

LSB_RELEASE="$(lsb_release -d)"

if [[ "${LSB_RELEASE}" =~ "Ubuntu 14" ]]; then
    PACKAGES="${UBUNTU_14_PACKAGES}"
elif [[ "${LSB_RELEASE}" =~ "Mint 18" || "${LSB_RELEASE}" =~ "Ubuntu 16" ]]; then
    PACKAGES="${UBUNTU_16_PACKAGES}"
elif [[ "${LSB_RELEASE}" =~ "Ubuntu 18" ]]; then
    PACKAGES="${UBUNTU_18_PACKAGES}"
fi

if [ ! -e ~/.buildrombashed ]; then
sudo apt install -y adb autoconf automake axel bc bison build-essential clang cmake expat fastboot flex \
g++ g++-multilib gawk gcc gcc-multilib git-core gnupg gperf imagemagick lib32ncurses5-dev lib32z-dev lib32z1-dev libtinfo5 \
libc6-dev libc6-dev-i386 libcap-dev libexpat1-dev libgl1-mesa-dev libgmp-dev liblz4-* liblzma* libmpc-dev libmpfr-dev \
libncurses5-dev libsdl1.2-dev libssl-dev libtool libx11-dev libxml2 libxml2-utils lunzip lzma* lzop maven ncftp ncurses-dev openjdk-8-jdk \
patch patchelf pkg-config pngcrush pngquant python python-all-dev re2c schedtool squashfs-tools subversion texinfo toilet \
unzip w3m x11proto-core-dev xsltproc zip zlib1g-dev "${PACKAGES}"
fi

# In Ubuntu 18.10, libncurses5 package is not available, so we need to hack our way by symlinking required library
if [[ "${LSB_RELEASE}" =~ "Ubuntu 18.10" ]]; then
  if [[ -e /lib/x86_64-linux-gnu/libncurses.so.6 && ! -e /usr/lib/x86_64-linux-gnu/libncurses.so.5 ]]; then
    sudo ln -s /lib/x86_64-linux-gnu/libncurses.so.6 /usr/lib/x86_64-linux-gnu/libncurses.so.5
  fi
fi
# The abvove will install packages that are needed to compile most ROM's, for systems above Ubuntu 14.04.
# If you find that during your compile of a ROM that it errors to require another package then simply:
# '$ sudo apt install <saidPackageName>' and let me know so I can add it for future users.
# Once you have installed these building packages you can disable the command, as now you only need to update or upgrade.
sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://github.com/akhilnarang/repo/raw/master/repo
sudo chmod a+x /usr/local/bin/repo
# The above will install the repo tool which will allow you to download and then stay in sync with a ROM's Git source, if it is
# updated at remote.
# repo is a python wrapper for git.
#
echo ""
echo "You will now be prompted to select a Java version."
echo "Ensure you select/type the number for 'java-8-jdk'"
echo ""
sudo update-alternatives --config java
echo ""
# Java version 8 is needed to execute the code compiling for our Android version(s), above Lollipop.
#
git config --global user.name AzzyC
git config --global user.email azmath2000@gmail.com
# Change above config according to your GitHub account.
git config --global color.ui true
# Skips prompt on 'repo init' requiring User input for colourised tags during sync.
if [ ! -d "compiled" ]; then
# The script is checking 'if' the 'compiled' directory does not exist..
mkdir ~/compiled/
# 'then' to make one if there is not. This is where you can collect your ROM's in an organised manner.
fi
while ! [[ $REPLY =~ ^(C|c|D|d)$ ]] && [ -d ~/props/ ]
do
	echo ""
	ls -a -1 ~/props/
	echo ""
	echo "'c'/'C' = Continue"
	echo "'d'/'D' = Delete 'props'; Compile ROM with new props"
	echo ""
	read -p "buildrom.sh: A 'props' directory already exists, from a previous compile. If syncing & compiling a ROM \
with the same props as last time, input 'c' to continue. If you want to compile a new ROM with different props \
, input 'd' to delete the exiting props. (c/d) " -n 2 -r
# This props should make the script run a lot smoother. With pre-emptive props, the script can recognise what needs to be
# done seamlessly and less of a need for User input, given that they do not delete props.
if [[ $REPLY =~ ^[Dd]$ ]]
	then
		echo ""
		sudo rm -rf ~/props/
		echo "'props' directory removed"
		echo ""
elif [[ ! $REPLY =~ ^[Cc|Rr|Dd]$ ]]
	then
		echo ""
		echo ""
		echo "You did not input 'c'/'C' or 'd'/'D' ! Try again."
		echo ""
fi
done
while ! [[ $REPLY =~ ^(C|c|R|r|D|d)$ ]] && [ -d ~/rom/ ]
do
	echo ""
	echo "Size of existing 'rom' directory"
	du -sh ~/rom/
	echo ""
	echo "'c'/'C' = Continue"
	echo "'r'/'R' = Rename 'rom'"
	echo "'d'/'D' = Delete 'rom'; Start fresh"
	echo ""
	read -p "buildrom.sh: A 'rom' directory already exists. If syncing & compiling same ROM source that is in this directory, input \
'c' to continue. If are syncing a new ROM source and want to keep your previous, rename existing 'rom' directory by \
inputting 'r' which will rename to 'prevROM'. If you want to save storage and start fresh removing existing 'rom' \
directory, input 'd' to delete. (c/r/d) " -n 2 -r
# This prompt is to avoid error or loss of a synced ROM source, so either make sure it's the same ROM source being synced or 
# seperate the sources into different folders.
# Note: ROM Sources take up a lot of space e.g. 160GB, so if you do choose to seperate them then make sure you have the storage
# as required.
if [[ $REPLY =~ ^[Rr]$ ]]
then
	echo ""
	mv ~/rom/ ~/prevROM/
	echo ""
	echo ""
	echo "'rom' directory renamed to 'prevROM'"
	echo ""
elif [[ $REPLY =~ ^[Dd]$ ]]
	then
		echo ""
		sudo rm -rf ~/rom/
		echo "'rom' directory removed"
		echo ""
elif [[ ! $REPLY =~ ^[Cc|Rr|Dd]$ ]]
	then
		echo ""
		echo ""
		echo "You did not input 'c'/'C' or 'r'/'R' or 'd'/'D' ! Try again."
		echo ""
fi
done
if [ ! -d ~/rom/ ]; then
# The script is checking 'if' the 'rom' directory does not exist..
mkdir ~/rom/
# 'then' to make one then to make one if there is not.
fi
cd ~/rom/
if [ -d ~/props/ ]
	then
		echo "Using existing props.."
			if [ -e ~/props/.los15 ]
			then
				echo ""
				echo "Initialising LineageOS 15"
				echo ""
				repo init -u https://github.com/LineageOS/android.git -b lineage-15.1
				echo ""
			elif [ -e ~/props/.los16 ]
				then
					echo ""
					echo "Initialising LineageOS 16"
					echo ""
					repo init -u git://github.com/LineageOS/android.git -b lineage-16.0
					echo ""
			elif [ -e ~/props/.pexpie ]
				then
					echo ""
					echo "Initialising PixelExperience Pie"
					echo ""
					repo init -u https://github.com/PixelExperience/manifest -b pie
					echo ""
			elif [ -e ~/props/.norom ]
				then
					echo ""
					echo "No predefined ROM source chosen, assuming added into script manually"
					echo ""
			fi
			if [ -e ~/props/.staroreo ]
				then
					cd ~/rom/.repo
					echo ""
					echo "Initialising Starxxx Oreo Tree"
					echo ""
					git clone https://github.com/AzzyC/local_manifests.git
					echo ""
			elif [ -e ~/props/.crownoreo ]
				then
					cd ~/rom/.repo
					echo ""
					echo "Initialising Crownlte Oreo Tree"
					echo ""
					git clone https://github.com/AzzyC/local_manifests-crown.git local_manifests
					echo ""
			elif [ -e ~/props/.uni9810pie ]
				then
					cd ~/rom/.repo
					echo ""
					echo "Initialising Universal-9810 Pie Tree"
					echo ""
					git clone https://github.com/AzzyC/local_manifests.git -b lineage-16.0
					echo ""
			elif [ -e ~/props/.nodevice ]
				then
					echo ""
					echo "No predefined Device Tree(s) chosen, assuming added to script manually"
					echo ""
			elif [ -z "$(ls -A ~/props)" ]
				then
					echo ""
					echo "There are no props present in this folder"
					echo "Reverting to normal User prompts"
					echo ""
					cd
					sudo rm -rf ~/props/
			fi
fi
if [ ! -d ~/props/ ]
then
# The script is checking 'if' the 'props' directory does not exist..
	mkdir ~/props/
# 'then' to make one then to make one if there is not.
	cd ~/rom/
	echo ""
	PS3='Which Rom_AndroidVersion would you like to build? (1/2/3/4) '
	options=("LineageOS 15.1 (Oreo)" "LineageOS 16 (Pie)" "PixelExperience (Pie)" "Other ROM")
	select opt in "${options[@]}"
	do
	    case $opt in
	        "LineageOS 15.1 (Oreo)")
	            echo ""
	            echo "You chose '$opt' at Option $REPLY"
	            echo ""
	            repo init -u https://github.com/LineageOS/android.git -b lineage-15.1
	            touch ~/props/.los15
# This will initialise a manifest repo to sync LineageOS 15.1 (Oreo).
	            echo ""
	            break
	            ;;
	        "LineageOS 16 (Pie)")
    	        echo ""
        	    echo "You chose '$opt' at Option $REPLY"
	            echo ""
	            repo init -u git://github.com/LineageOS/android.git -b lineage-16.0
	            touch ~/props/.los16
# This will initialise a manifest repo to sync LineageOS 16 (Pie).
	            echo ""
	            break
	            ;;
	        "PixelExperience (Pie)")
	            echo ""
	            echo "You chose '$opt' at Option $REPLY"
	            echo ""
	            repo init -u https://github.com/PixelExperience/manifest -b pie
	            touch ~/props/.pexpie
# This will initialise a manifest repo to sync Pixel Experience (Pie).
	            echo ""
	            break
	            ;;
	        "Other ROM")
	            echo ""
	            echo "You chose '$opt' at Option $REPLY"
	            echo ""
	            echo "No predefined ROM Source manifest selected."
	            echo "Assuming User has edited/added their chosen ROM Source, below this prompt."
	            touch ~/props/.norom
# This Option is for the Users that have already edited this script and repo initialised a ROM of their choice.
# Users can add the command to init a ROM after this prompt, under 'done', whereby examples have been given.
# (Can enable)
	            echo ""
	            break
	            ;;
	        *) echo ""
	            echo "Invalid: '$REPLY'. You did not choose '1' '2' '3' or '4'! Try again."
	            echo ""
	            ;;
	    esac
	done
#repo init -u git://github.com/AospExtended/manifest.git -b 8.1.x
#repo init -u https://github.com/Havoc-OS/android_manifest.git -b oreo
#repo init -u https://github.com/ResurrectionRemix/platform_manifest.git -b oreo
# Common task: Search on Google for '<romYouWantToBuildsName> manifest' e.g. 'bootleggers manifest', 'aex manifest'.
#
# The '-b' in the above example commands stands for 'branch' which in most cases you will have to specify as a different
# branch may be defaulted, within a particular repository. So become familiar with this and make sure you're not wasting
# time syncing an undesired source.
#
# A manifest is an .xml file which simply automates the cloning of all the all the ROM source directories, rather than a user
# manually having to clone hundreds of repositories leading to insanity. The manifest, can be found within a hidden directory
# where 'repo init' command occurred, called '.repo' => '~/rom/.repo/manifests'. (Use Ctrl + H to view hidden files/directories).
# I would advise you to inspect this manifest and the one that is cloned below.
#
	cd ~/rom/.repo/
	echo ""
	PS3='Which Device_AndroidVersion would you like to build? (1/2/3/4) '
	options=("Star-common Oreo" "Crownlte Oreo" "Universal-9810 Pie" "Other Manifest")
	select opt in "${options[@]}"
	do
	    case $opt in
	        "Star-common Oreo")
				echo ""
	            echo "You chose '$opt' at Option $REPLY"
	            echo ""
				git clone https://github.com/AzzyC/local_manifests.git
				touch ~/props/.staroreo
# The file brought from cloning this repository will automatically clone repositories required for
# starxxx Device, Kernel and Vendor tree for Oreo. The file is commonly known as a 'roomservice.xml',
# as it fetches everything for you, but it could come under any name.
				echo ""
	            break
	            ;;
	        "Crownlte Oreo")
				echo ""
				echo "You chose '$opt' at Option $REPLY"
				echo ""
	            git clone https://github.com/AzzyC/local_manifests-crown.git local_manifests
	            touch ~/props/.crownoreo
# To sync Crownlte's Device, Kernel and Vendor Tree instead, at version Oreo. These Trees are sourced from @synt4x93.
# Notice how on this command, local_manifests has been added. This is to direct a path which git should should clone the manfiest
# to, and this is where you should add your own manifests.
	            echo ""
	            break
	            ;;
	        "Universal-9810 Pie")
				echo ""
	            echo "You chose '$opt' at Option $REPLY"
	            echo ""
				git clone https://github.com/AzzyC/local_manifests.git -b lineage-16.0
				touch ~/props/.uni9810pie
# Cloning this repository holds the manifest to sync the Device, Kernel and Vendor alpha Pie tree for starxxx and crownlte at the
# state they were at, before they became private. DO NOT report bugs as they are known and most likely fixed in the private
# workings.
# You are expected to use these sources to experiment with an open-mind.
				echo ""
	            break
	            ;;
	        "Other Manifest")
				echo ""
				echo "You chose '$opt' at Option $REPLY"
				echo ""
				touch ~/props/.nodevice
				echo "No predefined Manifest selected."
				echo "Assuming User has edited/added their Devices Manifest, below this prompt."
# This Option is for the Users that have already edited this script to git clone the manifest for the Device, Kernel, Vendor Tree according
# to their phone. Users can add the command to clone their manifest after this prompt, under 'done; fi', whereby an example has been given (Not 
# one to enable).
				echo ""
	            break
	            ;;
	        *) echo ""
				echo "Invalid: '$REPLY'. You did not choose '1' '2' '3' or '4'! Try again."
				echo ""
				;;
	    esac
	done
fi
# git clone https://github.com/'yourGitHubName'/'repoNameOfWhereManifestSaved.git local_manifests
#
# This manifest will coincide with the ROM source manifest, when the script reaches the below '$ repo sync ..' command.
# Using these manifests as examples should give you enough knowledge to make your own, for a time of a tree bringup on a
# different device.
#
cd ~/rom/
echo "Syncing Sources:"
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags --quiet
# This will begin syncing the ROM source and respective device's trees you have enabledusing the manifests (or roomservice) found 
# in the '~/rom/.repo' directory.
# The attached tags should ensure an effective sync e.g. the --force-sync tag is to make sure that if the sync gets interrupted
# or 'sleeps' that it can just pick up wherever it terminated, avoiding a missing a file and causing knock-on errors.
# Otherwise you can simply use: 
#repo sync
# Initially downloading your ROM's source will take a lot of time (factoring in your interent speed also), but if you
# aren't looking to change and build a different ROM's often, then you can simply hit the above command again and it will
# fetch any new updates from the remote source, if there are any. - You do not have to wait for the sync all over again.
while ! [[ $REPLY =~ ^(Y|y|N|n)$ ]]
do
read -p "buildrom.sh: Sync Status: Complete. Are your files ready to compile? (y/n) " -n 2 -r
if [[ $REPLY =~ ^[Nn]$ ]]
then
	echo ""
	echo ""
	echo No worries! Simply bash script again, when you are ready.
	echo ""
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
elif [[ ! $REPLY =~ ^[Yy|Nn]$ ]]
	then
		echo ""
		echo ""
		echo "You did not input 'y'/'Y' or 'n'/'N'! Try again."
		echo ""
fi
done
# This prompt is to work as a breaker between the sync and the compile stage, as an opportunity for the user to make file
# changes i.e. modifying the original 'lineage.mk' and contents within, for a ROM that isn't supported by the Device Tree
# If you are absolutely sure that you do not require to change files beyond what is prebuilt on the Device Tree and have
# enabled a lunch command from below, then feel free to disable the prompts functions.
#
# If you have chosen a ROM outside of Device Tree's support then there are a couple of changes to make:
# (This will be done in the example of starlte, change with respect to your device codename star/star2/crown)
#
# 1) In '~/rom/device/samsung/starlte' change the name of the 'lineage.mk' file and rename it to your ROM's needed .mk.
# To keep with above examples of 'PixelExperience', it would need to be renamed to 'aosp_starlte.mk'. 
#
# 2) Opening your renamed *.mk file and you will see lines inhertiting files at the top and then device properties at the bottom.
# So it is sensible to understand that not all ROMs will follow the same folder structure and include the same files and names
# as they have brought ROM source up differently to suit their own.
# The most common line(s) that we should be concerned about is based on when inheriting from 'vendor' folder i.e. '~/rom/vendor'.
# For example inside the original 'lineage.mk' it has an inherit line of 'vendor/lineage/config/..', though in a ROM source like 
# PixelExperience they do not use a folder called 'lineage'. Therefore, we should modify the line to 'vendor/aosp/config/..'.
#
# 3) However, it is not enough to simply rename a filepath at face value, you should go into the '~/rom/vendor' folder and see if
# the filepath holds true/exists and if it is not then of course when compiling you are going to get an error so explore and find
# the file. It may even be that if it doesn't exist then you have to go for a similar target e.g. if there is
# no 'common_full_phone.mk' file then inherit 'common.mk'.
#
# 4) Compare your *.mk to devices that your chosen ROM officially supports on their GitHub so that you can find missing
# inherits which may be crucial for your ROM e.g. a missing Dialer is never desired.
#
# 5) Finally, now in the bottom section of the *.mk, change the 'PRODUCT_NAME :=' according to your ROMs name.
# For example, for 'PixelExperience' change from 'lineage_starlte' to aosp_starlte'.
#
# Note: If you do not make the changes or correctly based on the instructions below then your compile will be aborted but should
# give you an error to prompt you what to fix.
# Reminding what was mentioned in the first few lines of this script (guide), the script will run from its first command right to
# its last, and if there is any lacking command(s) be prepared to see errors based on the remaining commands as a knock-on effect.
# Also that this script does not terminate unless a user makes it do so, so refrain from dividing blame on the script when it
# comes to a compiling issue.
#
echo ""
toilet -f smblock "Compile initiated"
. build/envsetup.sh
# This bashes a script tp setup a building workspace i.e. Tools, Paths etc. Validates if you have what is needed to compile.
	export LC_ALL=C
# Exposing an environment variable needed for systems above Ubuntu 18.04, This command should avoid compiling errors e.g. reading
# and using files and libraries in the correct charset.
if [ -e ~/props/.los15 ] || [ -e ~/props/.los16 ]
# These below commands are specific to LineageOS and reflect differently to each device.
then
	if [ -e ~/props/.staroreo ]
	then
		cd ~/rom/kernel/samsung/star-common
		git revert e4a56a974913373fe046159905d0e6fe47420d6a
# Commit Summary: 'defconfigs: Correct path for GCC 9.1'
		git revert 68b85dadc180efaab5311fbfbf2325ded6ccd0fc
# Commit Summary: 'Makefile: Disable psabi warnings: We don't need to worry about this, as all of our libraries are being
# compiled exclusively with GCC 9.1.'
		cd ~/rom/
		lunch lineage_starlte-userdebug
# In most cases, it is '$ lunch (romName)_(deviceName)-userdebug'
#
		make bacon -j$(nproc --all)
# This will use all available CPU threads to build, if you do not wish this remove '(nproc --all)' and replace it with
# the number of threads you would like to give to the compile. Example if you have 4 CPU Cores, then you can make 4
# threads using '$ make bacon -j4'
#
		echo ""
		if [ -d ~/rom/out/target/product/**/ ]
		toilet -f smblock "starlte done"
		fi
# To let you know clearly in the terminal that starlte ROM has compiled.
#
# If you only want to build for one of these devices, then disable the 3 commands on either side accordingly.
#
		lunch lineage_star2lte-userdebug
# In most cases, it is '$ lunch (romName)_(deviceName)-userdebug'
#
		make bacon -j$(nproc --all)
# This will use all available CPU threads to build, if you do not wish this remove '(nproc --all)' and replace it with
# the number of threads you would like to give to the compile. Example if you have 4 CPU Cores, then you can make 4
# threads using '$ make bacon -j4'
#
		echo ""
		if [ -d ~/rom/out/target/product/**/ ]
		toilet -f smblock "star2lte done"
		fi
# To let you know clearly in the terminal that star2lte ROM has compiled.
# All above commands will only run if U# These below commands are specific to LineageOS and reflect differently to each device.ser had chosen props or inputted a reply for the the Starxxx Device Manifest and the
# LineageOS sources, beit LOS 15 or LOS 16.1, which will compile for both devices granted the User keeps the commands enabled. 
	elif [ -e ~/props/.crownoreo ]
	then
		lunch lineage_crownlte-userdebug
# In most cases, it is '$ lunch (romName)_(deviceName)-userdebug'
		make bacon -j$(nproc --all)
# This will use all available CPU threads to build, if you do not wish this remove '(nproc --all)' and replace it with
# the number of threads you would like to give to the compile. Example if you have 4 CPU Cores, then you can make 4
# threads using '$ make bacon -j4'
		echo ""
		if [ -d ~/rom/out/target/product/**/ ]
		toilet -f smblock "crownlte done"
		fi
# To let you know clearly in the terminal that crownlte ROM has compiled.
	fi
	if [ -d ~/rom/out/target/product/**/ ]
	then
		mv ~/rom/out/target/product/**/lineage-1*.zip ~/compiled/
		mv ~/rom/out/target/product/**/lineage-1*.md5sum ~/compiled/
	fi
# This command is only to save the user time from going through multiple directories to find the ROM zip and instead find it
# right it away in the 'compiled' folder.
#
fi
if [ -e ~/props/.pexpie ]
# These below commands are specific to PixelExperience and reflect differently to each device.
then
	rename 's/lineage/aosp/' ~/rom/device/**/**/*.mk
# Most Device Tree(s) are brought up accommodating to LineageOS ROM, so the initial ROM makefile may be 'lineage.mk'
# or 'lineage_(deviceName).mk' so this command suits to either possible filename to rename the ROM part of the file to
# 'aosp' as this is the name that PixelExperience uses to recognise the environment is set up to compile.
	sed -i 's/lineage/aosp/' ~/rom/device/**/**/aosp*.mk
# As the ROM makefile (.mk) name is 'aosp*' we now have to target changes accordingly. Fortunately the filepath inherits in the
# original 'lineage.mk' follows a similar file stucture to PixelExperience. Therefore wherever the word 'lineage' is spotted it can
# be replaced with 'aosp'. Note that these may not always be the changes required, sometimes filepaths need to be checked if they exist.
# Refer between lines 413 to 442, in this script to understand what other changes may be required.
	sed -i 's/lineage/aosp/' ~/rom/device/**/**/AndroidProducts.mk
# If this file does exist in a Device Tree then when it comes to the lunch environment setup stage, this file will be used to recognise
# the name of the ROM makefile, holding the device and ROM inherits. Since the file has been renamed, it would be appropriate to rename it
# here too, so that the file can be found and hence no error.
#
# Notice that no particular has been specified in the filepath, such as 'samsung'/'starlte/star2lte/crownlte'. This for those handful 
# of users that may be using this script outside of Exynos9810, so the changes can be applicable universally.
# I will try and keep commands device neutral, when possible.
	if [ -e ~/props/.staroreo ]
	then
		lunch aosp_starlte-userdebug
# In most cases, it is '$ lunch (romName)_(deviceName)-userdebug'
		mka bacon -j$(nproc --all)
# This will use all available CPU threads to build, if you do not wish this remove '(nproc --all)' and replace it with
# the number of threads you would like to give to the compile. Example if you have 4 CPU Cores, then you can make 4
# threads using '$ make bacon -j4'.
# 'mka' is used here because PixelExperience have customed their make/compile command.
		echo ""
		if [ -d ~/rom/out/target/product/**/ ]
		toilet -f smblock "starlte done"
		fi
#
# If you only want to build for one of these devices, then disable the 3 commands on either side accordingly.
#
		lunch aosp_star2lte-userdebug
# In most cases, it is '$ lunch (romName)_(deviceName)-userdebug'
#
		mka bacon -j$(nproc --all)
# This will use all available CPU threads to build, if you do not wish this remove '(nproc --all)' and replace it with
# the number of threads you would like to give to the compile. Example if you have 4 CPU Cores, then you can make 4
# threads using '$ make bacon -j4'
# 'mka' is used here because PixelExperience have customed their make/compile command.
		echo ""
		if [ -d ~/rom/out/target/product/**/ ]
		toilet -f smblock "star2lte done"
		fi
	elif [ -e ~/props/.crownoreo ]
	then
		lunch aosp_crownlte-userdebug
# In most cases, it is '$ lunch (romName)_(deviceName)-userdebug'
		mka bacon -j$(nproc --all)
# This will use all available CPU threads to build, if you do not wish this remove '(nproc --all)' and replace it with
# the number of threads you would like to give to the compile. Example if you have 4 CPU Cores, then you can make 4
# threads using '$ make bacon -j4'.
# 'mka' is used here because PixelExperience have customed their make/compile command.
		echo ""
		if [ -d ~/rom/out/target/product/**/ ]
		toilet -f smblock "crownlte done"
		fi
# To let you know clearly in the terminal that crownlte ROM has compiled.
	fi
	if [ -d ~/rom/out/target/product/**/ ]
	then
		mv ~/rom/out/target/product/**/PixelExperience_*.zip ~/compiled/
		mv ~/rom/out/target/product/**/PixelExperience_*.md5sum ~/compiled/
	fi
# This command is only to save the user time from going through multiple directories to find the ROM zip and instead find it
# right it away in the 'compiled' folder.
#
fi
if [ -e ~/props/.gcloudvncbashed ]; then
echo ""
toilet -f smblock "script passed"
# To let you know clearly in the terminal that the script has finished. and it is safe to close terminal.
fi
while ! [[ $REPLY =~ ^(Y|y|N|n)$ ]] && [ ! -e ~/.gcloudvncbashed ]
do
read -p "buildrom.sh: Compile Status: Complete. Would you like to bash './gcloudvnc.sh' to upload your \
ROM, if you are using a GCloud VM Instance? (y/n) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo ""
	bash ~/scripts/gcloudvnc.sh
	echo ""
	echo ""
	toilet -f smblock "GCloud VNC started"
	echo ""
elif [[ $REPLY =~ ^[Nn]$ ]]
then
	echo ""
	echo ""
	toilet -f smblock "script passed"
	echo ""
# To let you know clearly in the terminal that the script has finished. and it is safe to close terminal.
else
	echo ""
	echo ""
	echo "You did not input 'y'/'Y' or 'n'/'N'! Try again."
	echo ""
fi
done
