#!/bin/zsh

########################################################
## edit thease variables to match your project structure
########################################################
BUILD_DEBUG_FOLDER="build/debug"
BUILD_RELEASE_FOLDER="build/release"
DEFAULT_BUILD_TYPE="d" # "d" for debug and "r" for release
EXECUTABLE_NAME="{{project-name}}" # should be the name of the executable beeing built, this is used for the run action

COLOR="\033[1;33m" # https://stackoverflow.com/a/5947802

#######################################################################################
## this is where the script starts you should not need to edit anything below this line
#######################################################################################

NC="\033[0m" # No Color

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
for (( i=0; i<${#ARG}; i++ )); do
    case ${ARG:$i:1} in
        "c")
            echo "cleaning project"
            if [[ $BUILD_TYPE == "d" ]]; then
                rm -rf $BUILD_DEBUG_FOLDER
            else
                rm -rf $BUILD_RELEASE_FOLDER
            fi
            ;;
        "g")
            echo "generating cmake files"
            if [[ $BUILD_TYPE == "d" ]]; then
                mkdir -p $BUILD_DEBUG_FOLDER
                cmake -S . -B $BUILD_DEBUG_FOLDER -DCMAKE_BUILD_TYPE=Debug
            else
                mkdir -p $BUILD_RELEASE_FOLDER
                cmake -S . -B $BUILD_RELEASE_FOLDER -DCMAKE_BUILD_TYPE=Release
            fi
            ;;
        "b")
            echo "building project"
            if [[ $BUILD_TYPE == "d" ]]; then
                cmake --build $BUILD_DEBUG_FOLDER
            else
                cmake --build $BUILD_RELEASE_FOLDER
            fi
            ;;
        "r")
            echo "running project"
            if [[ $BUILD_TYPE == "d" ]]; then
                ./$BUILD_DEBUG_FOLDER/$EXECUTABLE_NAME
            else
                ./$BUILD_RELEASE_FOLDER/$EXECUTABLE_NAME
            fi
            ;;
        "s")
            echo "stripping executable"
            if [[ $BUILD_TYPE == "d" ]]; then
                strip -s $BUILD_DEBUG_FOLDER/$EXECUTABLE_NAME -o "$BUILD_DEBUG_FOLDER/$EXECUTABLE_NAME-stripped"
            else
                strip -s $BUILD_RELEASE_FOLDER/$EXECUTABLE_NAME -o "$BUILD_RELEASE_FOLDER/$EXECUTABLE_NAME-stripped"
            fi
            ;;
        *)
            echo "unknown action ${1:$i:1}"
            exit 1
            ;;
    esac
done
