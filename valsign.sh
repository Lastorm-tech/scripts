#!/bin/bash
##########################################################################
# rt1
##########################################################################
# Program: 
# shell script, linking a gdb to the valgrind synthetic core with massif or memcheck enabled
# when massif tool enabled, it will generate xtmemory file with ms_print
# when memcheck tool enabled, it will generate a leak_check file 
##########################################################################
VERSION="0.0.1"; # <release>.<major change>.<minor change>
MISCINFO="-when massif tool enabled, it will generate xtmemory file with ms_print \n-when memcheck tool enabled, it will generate a leak_check file\n";
PROGNAME="VALSIGN";
AUTHOR="b011wbz";
##########################################################################
## TODO: 
##########################################################################
# XXX: Coloured variables
##########################################################################
red=`echo -e "\033[31m"`
lcyan=`echo -e "\033[36m"`
yellow=`echo -e "\033[33m"`
green=`echo -e "\033[32m"`
blue=`echo -e "\033[34m"`
purple=`echo -e "\033[35m"`
normal=`echo -e "\033[m"`
##########################################################################
# XXX: Configuration
##########################################################################

declare -A PID_TOOLS
PID_TOOLS['valgrind']=0

declare -A EXIT_CODES

EXIT_CODES['unknown']=-1
EXIT_CODES['ok']=0
EXIT_CODES['generic']=1
EXIT_CODES['limit']=3
EXIT_CODES['missing']=5
EXIT_CODES['failure']=10

DEBUG=0
param=""

##########################################################################
# XXX: Help Functions
##########################################################################
show_usage() {
   echo -e """\033[32mScript, linking a gdb to the valgrind synthetic core with massif or memcheck\033[m\n
   Usage: \033[31m $0 \033[m (full gdb inline command without gdb prefix)
   \t-h\t\t\033[36m shows this help menu \033[m
   \t-v\t\t\033[36m shows the version number and other misc info \033[m
   \t-D\t\t\033[36m displays more verbose output for debugging purposes \033[m"""
   
   exit 1
   exit ${EXIT_CODES['ok']};
}

show_version() {
   echo -e "\n\033[36m$PROGNAME version: $VERSION ($AUTHOR)\033[m";
   echo -e "$MISCINFO";
   exit ${EXIT_CODES['ok']};
}

debug() {
   # Only print when in DEBUG mode
   if [[ $DEBUG == 1 ]]; then
      echo $1;
   fi
}

err() {
   echo "$@" 1>&2;
   exit ${EXIT_CODES['generic']};
}
##########################################################################
# XXX: Initialisation and menu
##########################################################################
if [ $# == 0 ] ; then
   show_usage;
fi

while getopts :vhx opt
do
   case $opt in
      v) show_version;;
      h) show_usage;;
      D) debug;;
      *) echo "Option inconnue: -$OPTARG" >&2; exit 1;;
   esac
done
##########################################################################
header() {
   echo -e "\033[36m$PROGNAME version: $VERSION ($AUTHOR)\033[m";
}

main() {
   start_valgrind $1;
   start_gdb $1;
   sleep 2;
   exploit_massif;
   #exploit_stack;
}

start_valgrind() {
   #(valgrind --tool=memcheck --vgdb=yes --vgdb-error=0 --leak-check=full --show-leak-kinds=possible --xtree-leak=yes --xtree-leak-file=xtree_RUN $1) &
   (valgrind --tool=massif --xtree-memory=full --xtree-memory-file=xtmemory.ms.%p --vgdb=yes --vgdb-error=0 $1) &
}

start_gdb() {
   gdb $1;
   target remote | vgdb;
}

exploit_stack() {
   alias bt='echo 0 | gdb -batch-silent -ex "run" -ex "set logging overwrite on" -ex "set logging file gdb.bt" -ex "set logging on" -ex "set pagination off" -ex "handle SIG33 pass nostop noprint" -ex "echo backtrace:\n" -ex "backtrace full" -ex "echo \n\nregisters:\n" -ex "info registers" -ex "echo \n\ncurrent instructions:\n" -ex "x/16i \$pc" -ex "echo \n\nthreads backtrace:\n" -ex "thread apply all backtrace" -ex "set logging off" -ex "quit" --args';
   bt $1 > backtrace_RUN;
   unalias bt;
}

exploit_massif() {
   ms_print massif.out.* > massif_RUN;
   rm massif.out.*;
}

header
main "$@"

debug $param;