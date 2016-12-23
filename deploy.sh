#!/bin/bash
`finclude $0 zsl.sh`

# 邮箱账号设置
acount_cfg_file=$HOME/.mutt.acount
if [ ! -f "$acount_cfg_file" ]; then
	echo "before deploy you have to offer your email settings by modify $acount_cfg_file, there's an example in witch."
	setting_example=("# email setting exmaple"
			"# user_cmd=(\"cmd1\" 			\"cmd2\")"
			"# username=(\"email_user_name1\", 	\"email_user_name2\")"
			"# password=(\"password1\", 		\"password2\")"
			"# receive_server=(\"server1\" 		\"server2\")"
			"# receive_protocol=(\"POP3\", 		\"IMAP\")")
	FindSetLines $acount_cfg_file "${setting_example[0]}" "${setting_example[@]}"
	exit 0
else
	. $acount_cfg_file
fi


curDir=`GetFullPath $0`
curDir=${curDir%/*}

# 脚本文件
scripts=("muttrc" "mutt.alias" "mailcap" "fetchmailrc")
for item in ${scripts[@]} ; do
	cp -f $curDir/$item $HOME/.$item
done


# 配置账号
function AddMailAcount()
{
	# if [ $@ -lt 7 ]; then
		# return 1
	# fi
	local sign=$1
	local user=$2
	local pass=$3
	local recv_svr=$4
	local recv_pro=$5
	local send_svr=$6
	local send_pro=$7

	local mutt_cfg="macro index ,CMD \":set pop_host=\\\\\"pop://USR:PWD@SVR\\\\\"\\\\r <fetch-mail>\""
	mutt_cfg="${mutt_cfg/CMD/$sign}"
	mutt_cfg="${mutt_cfg/USR/$user}"
	mutt_cfg="${mutt_cfg/PWD/$pass}"
	mutt_cfg="${mutt_cfg/SVR/$recv_svr}"
	FindSetLines $HOME/.${scripts[0]} "$mutt_cfg" "$mutt_cfg"

	local recv_cfg="poll SVR && protocol PROTO && user \"USR\" && password \"PWD\""
	recv_cfg=${recv_cfg/SVR/$recv_svr}
	recv_cfg=${recv_cfg/PROTO/$recv_pro}
	recv_cfg=${recv_cfg/USR/$user}
	recv_cfg=${recv_cfg/PWD/$pass}
	FindSetLines $HOME/.${scripts[3]} "$recv_cfg" "$recv_cfg"
}

i=0
total=${#username[@]}
while [ $i -lt $total ]; do
	AddMailAcount ${user_cmd[(i)]} ${username[(i)]} ${password[(i)]} ${receive_server[(i)]} ${receive_protocol[(i)]}
	((i++))
done
