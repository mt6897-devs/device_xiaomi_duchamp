#!/vendor/bin/sh

########################################################
### init.insmod.cfg format:                          ###
### -----------------------------------------------  ###
### [insmod|setprop|enable/moprobe] [path|prop name] ###
### ...                                              ###
########################################################

if [ $# -eq 1 ]; then
  cfg_file=$1
else
  exit 1
fi

if [ -f $cfg_file ]; then
  while IFS="|" read -r action arg
  do
    case $action in
      "insmod") insmod $arg ;;
      "setprop")
        times=1
        setprop $arg 1
        while [ "$?" -ne 0 ]
        do
          if [ $times -gt 128 ]; then
            break
          fi
          let times++
          setprop $arg 1
        done ;;
      "enable") echo 1 > $arg ;;
      "modprobe")
        insmod_arg=${arg}
        for partition in system_dlkm vendor
        do
          case ${insmod_arg} in
            "-b *" | "-b")
              arg="-b $(cat /${partition}/lib/modules/modules.load)" ;;
            "*" | "")
              arg="$(cat /${partition}/lib/modules/modules.load)" ;;
          esac
          modprobe -a -d /${partition}/lib/modules $arg
        done
    esac
  done < $cfg_file
else
  exit 2
fi

