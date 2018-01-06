# -*- mode: sh; -*-
safe_bash () { set -o nounset ; set -o errexit ; } ; safe_bash

############################################################################
#functions to use in scripts:
#
#should use this line at the top of every script:
#safe_bash () { set -o nounset ; set -o errexit } ; safe_bash
#

function set-x-on () {
    set -x
}
function set-x-off () {
    set +x
}
function set-DEBUG-echo () {
    export DEBUG=echo
}
function set-DEBUG-off () {
    export DEBUG=""
}

#fix these to test for set/unset so they're ok if vars do not exist or have yes/no instead of 0/1.
debug=0 ; verbose=0
function print_debug () {
    if [[ $debug -eq 1 ]] ; then echo "$1" ; fi
}
function print_verbose () {
    if [[ $verbose -eq 1 ]] ; then echo "$1" ; fi
}
function print_log () {
    echo "$1" >> ${LOG}
}

############################################################################
#Copy, paste, rename, modify thesse example functions: usage, process_args:
example_usage () {
    echo
    echo "Balls."
    echo 
    echo
    echo "Usage > balls.sh [options]"
    echo
    echo "      -h | --help                Lists this usage information."
    echo "      -d | --debug               Echo the commands that will be executed."
    echo
    exit
}
function check_argcount () {
    #call as: check_argcount $# min_args
    argcount=$1 ; min_args=$2
    if [[ "$argcount" < "${min_args}" ]]; then
	echo "Not enough arguments! Wanted ${min_args}, got ${argcount}. Halp!"
	kill -INT $$
    fi
}
function example_process_args () {
    #call like: process_args "$@"

    if [[ "$#" == "0" ]]; then
	echo "No arguments. Halp!"
	usage
    fi

    while (( "$#" )); do
	case ${1} in          #switches for this shell script begin with '--'
            -h | help)        usage;;
            -d | --debug )    export debug=1; export DEBUG=echo ; echo -e "\nDebug mode on.";;
            --arg_with_param) export BALLS="$2"   ; echo "Balls = ${BALLS}" ; shift ;;
	    
            #--balls)         echo "Balls" ;;
            *)            ok=0 ; echo "Unrecognised option." ;  usage ;;
	esac;
	shift
    done
    
    if [ $ok -eq 0 ] ; then echo "Halp. Something isn't right with the command arguments. Exiting." ; usage ; fi
    echo
}

function set_date () {
    export DATE="`date +%Y-%m-%d`"
}
function echo_date () {
    echo "${DATE}"
}
function set_time () {
    export TIME="`date +%H-%M-%S`"
}
function echo_time () {
    echo "${TIME}"
}

############################################################################
#Notes:
#Can paste uncommented notes & text inside the "here docunment" below:

<<'HERE_DOCUMENT_COMMENT'

To perform a syntax check/dry run of your bash script run:
bash -n myscript.sh

To produce a trace of every command executed run:
bash -v myscripts.sh

To produce a trace of the expanded command use:
bash -x myscript.sh

Favor  $() over backticks (`)
Backticks are hard to read and in some fonts easily confused with single quotes.
$()also permits nesting without the quoting headaches.
    # both commands below print out: A-B-C-D
    echo "A-`echo B-\`echo C-\\\`echo D\\\`\``"
    echo "A-$(echo B-$(echo C-$(echo D)))"

Favor [[]] (double brackets) over [] 
[[]] avoids problems like unexpected pathname expansion, offers some syntactical improvements,
and adds new functionality:

Operator        Meaning
||             logical or (double brackets only)
&&           logical and (double brackets only)
<            string comparison (no escaping necessary within double brackets)
-lt          numerical comparison
=             string matching with globbing
==         string matching with globbing (double brackets only, see below)
=~            string matching with regular expressions (double brackets only , see below)
-n            string is non-empty        
-z            string is empty
-eq           numerical equality
-ne           numerical inequality

single bracket
    [ "${name}" \> "a" -o ${name} \< "m" ]

double brackets
     [[ "${name}" > "a" && "${name}" < "m"  ]]

Regular Expressions/Globbing
    t="abc123"
    [[ "$t" == abc* ]]         # true (globbing)
    [[ "$t" == "abc*" ]]       # false (literal matching)
    [[ "$t" =~ [abc]+[123]+ ]] # true (regular expression)
    [[ "$t" =~ "abc*" ]]       # false (literal matching)
Note, that starting with bash version 3.2 the regular or globbing expression
must not be quoted. If your expression contains whitespace you can store it in a variable:
    r="a b+"
    [[ "a bbb" =~ $r ]]        # true

Globbing based string matching  is also available via the case statement:
    case $t in
    abc*)  <action> ;;
    esac

String Manipulation - Bash has a number of (underappreciated) ways to manipulate strings.
Basics
    f="path1/path2/file.ext"  

    len="${#f}" # = 20 (string length) 

    # slicing: ${<var>:<start>} or ${<var>:<start>:<length>}
    slice1="${f:6}" # = "path2/file.ext"
    slice2="${f:6:5}" # = "path2"
    slice3="${f: -8}" # = "file.ext"(Note: space before "-")
    pos=6
    len=5
    slice4="${f:${pos}:${len}}" # = "path2"







#FINAL LINE OF NOTES SECTION FOLLOWS:
HERE_DOCUMENT_COMMENT

####################################
#Normal uncommented shell below here:

