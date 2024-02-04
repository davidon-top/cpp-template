#!/usr/bin/env zsh

###########################################################
## edit thease variables to match your project structure ##
###########################################################
BUILD_FOLDER="build"
DEFAULT_BUILD_TYPE="debug" # "debug" or "release"
TARGETS=["{{project-name}}"]

##########################################################################################
## this is where the script starts you should not need to edit anything below this line ##
##########################################################################################
#
NC="\033[0m"
COLOR="\033[1;33m"

zparseopts -D -E -F -- d:=debug r:=release t+=target h:=help || exit 1

if (( $#help > 0 )); then
	echo "Usage:"
	echo "	./ch actions [options]"
	echo ""
	echo "Actions:"
	echo "	c - clean project"
	echo "	g - generate cmake files"
	echo "	b - build project"
	echo "	r - run project"
	echo "	s - strip executable"
	echo "	d - debug with gdb"
	echo ""
	echo "actions can be chained so gbr will first run generate then build and then run"
	echo ""
	echo "Options:"
	echo "	-d, --debug         Builds cmake in debug mode"
	echo "	-r, --release       Builds cmake in release mode"
	echo "	-t CMAKE_TARGET, --target CMAKE_TARGET"
	echo "	                    Builds specific target. Builds all targets specified in order that they are specified in. Clean action is not recomended when using multiple targets."
	exit 0
fi

if [[ -z "$1" ]]; then
	echo "no actions provided"
	exit 1
fi

if (( $#debug > 0 )); then
	BUILD_TYPE="debug"
elif (( $#release > 0 )); then
	BUILD_TYPE="release"
else
	BUILD_TYPE=$DEFAULT_BUILD_TYPE
fi

if (( $#target != 0 )); then
	TARGETS=$#target
fi


echo() {
	command echo -e "${COLOR}$@${NC}"
}

ARG=$1

BF="$BUILD_FOLDER/$BUILD_TYPE"

for TARGET in $TARGETS; do
	for (( i=0; i<${#ARG}; i++ )); do
		case ${ARG:$i:1} in
			"c")
				echo "cleaning project"
				rm -rf $BUILD_FOLDER
				;;
			"g" | "b")
				mkdir -p $BF
				;;
			"g")
				echo "generating cmake files"
				CMAKE_BUILD_TYPE=${BUILD_TYPE^}
				cmake -S . -B $BF -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE
				;;
			"b")
				echo "building project"
				cmake --build $BF
				;;
			"r")
				echo "running project"
				if [[ -f "$BF/$TARGET" ]]; then
					./$BF/$TARGET
				fi
				;;
			"s")
				echo "stripping executable"
				strip -s $BF/$TARGET -o "$BF/$TARGET-stripped"
				;;
			"d")
				echo "debug project"
				if [[ $BUILD_TYPE == "release" ]]; then
					echo "WARNING: debugging release build"
				fi
				gdb $BF/$TARGET
				;;
			*)
				echo "unknown action ${1:$i:1}"
				exit 1
				;;
		esac
	done
done
