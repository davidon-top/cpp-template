#!/bin/zsh

########################################################
## edit thease variables to match your project structure
########################################################
BUILD_DEBUG_FOLDER="build/debug"
BUILD_RELEASE_FOLDER="build/release"
DEFAULT_BUILD_TYPE="d" # "d" for debug and "r" for release
DEFAULT_TARGET="{{project-name}}" # should be the name of the executable beeing built, this is used for the run action

#######################################################################################
## this is where the script starts you should not need to edit anything below this line
#######################################################################################

if [ -n "$TARGET" ]; then
	DEFAULT_TARGET=$TARGET
fi

NC="\033[0m" # No Color
COLOR="\033[1;33m"

if [ -z "$1" ]
then
    echo "No action specified"
    echo "run cmakehelper.sh help for more info"
    exit 1
fi

case $1 in
    "init" | "-i" | "--init")
        SCRIPT_PATH=$(realpath $0)
        cp -f $SCRIPT_PATH ./cmakehelper.sh
        echo "Initialized cmakehelper.sh edit the variables at the top of the script to match your project structure"
        exit 0
        ;;
    "help" | "-h" | "--help")
        echo "Possible actions are:"
        echo "c - clean project"
        echo "g - generate cmake files"
        echo "b - build project"
        echo "r - run project"
        echo "s - strip executable"
		echo "d - debug with gdb"
        echo ""
        echo "actions can be chained so gbr will first run generate then build and then run"
        echo ""
        echo "second argument is the build type, possible values are d or debug and r or release"
        echo "if no build type is specified then DEFAULT_BUILD_TYPE is used"
        echo "build type is required for all actions (accept if you have the same folder for bouth build and release then its only needed for build action)"
        exit 0
        ;;
esac

if [ -z "$2" ]
then
    BUILD_TYPE=$DEFAULT_BUILD_TYPE
else
    BT=$(echo $2 | tr '[:upper:]' '[:lower:]')
    if [[ $BT == "d" || $BT == "debug" ]]; then
        BUILD_TYPE="d"
    elif [[ $BT == "r" || $BT == "release" ]]; then
        BUILD_TYPE="r"
    else
        echo "unknown build type $2"
        exit 1
    fi
fi

echo() {
    command echo -e "${COLOR}$@${NC}"
}

ARG=$1
if [[ $BUILD_TYPE == "d" ]]; then
	BUILD_FOLDER=$BUILD_DEBUG_FOLDER
else
	BUILD_FOLDER=$BUILD_RELEASE_FOLDER
fi
for (( i=0; i<${#ARG}; i++ )); do
    case ${ARG:$i:1} in
        "c")
            echo "cleaning project"
			rm -rf $BUILD_FOLDER
            ;;
        "g")
            echo "generating cmake files"
			mkdir -p $BUILD_FOLDER
            if [[ $BUILD_TYPE == "d" ]]; then
                cmake -S . -B $BUILD_DEBUG_FOLDER -DCMAKE_BUILD_TYPE=Debug
            else
                cmake -S . -B $BUILD_RELEASE_FOLDER -DCMAKE_BUILD_TYPE=Release
            fi
            ;;
        "b")
            echo "building project"
			cmake --build $BUILD_FOLDER
            ;;
        "r")
            echo "running project"
			./$BUILD_FOLDER/$DEFAULT_TARGET
            ;;
        "s")
            echo "stripping executable"
			strip -s $BUILD_FOLDER/$DEFAULT_TARGET -o "$BUILD_FOLDER/$DEFAULT_TARGET-stripped"
            ;;
		"d")
			echo "debug project"
			if [[ $BUILD_TYPE == "r" ]]; then
				echo "WARNING: debugging release build"
			fi
			gdb ./$BUILD_FOLDER/$DEFAULT_TARGET
        *)
            echo "unknown action ${1:$i:1}"
            exit 1
            ;;
    esac
done
