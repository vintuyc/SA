#!/bin/sh

ch_class_totable() {
	local len=15
	local sp
	local str=""
	local H="A B C D X E F G H I J K"
	local D="1 2 3 4 5 6 7"
	local D_len=7
	#printf "x .%-${len}s.%-${len}s.%-${len}s.%-${len}s.%-${len}s \n" Mon Tue Wed Thu Fri > test
	printf "x .%-${len}s.%-${len}s.%-${len}s.%-${len}s.%-${len}s.%-${len}s.%-${len}s  \n" Mon Tue Wed Thu Fri Sat Sun> test
	for hour in $H;do

		printf "%s" "--" >> test
		for i in $D;do
			local j=1
			while [ $j -lt $((len+1)) ];do
				printf "%s" "-" >> test
				j=$((j+1))
			done
		done

		printf "\n%s" "$hour " >> test
		for day in $D;do
			str="`awk "/${day}[A-K]*${hour}/ "'{ gsub(/[1-5][A-KX]+[1-5]?[A-KX]* /,"",$0); gsub(/[A-Z]+[0-9]+ /,"",$0); printf("%s.",$0); }' yourclass`"
			if [ $day -eq 1 ];then str1=$str
			elif [ $day -eq 2 ];then str2=$str
			elif [ $day -eq 3 ];then str3=$str
			elif [ $day -eq 4 ];then str4=$str
			elif [ $day -eq 5 ];then str5=$str
			elif [ $day -eq 6 ];then str6=$str
			else  str7=$str
			fi
		done
		
		sp=0
		while ! [ ${sp} -eq ${D_len} ];do
			sp=0
			for i in $D;do
				str=`eval echo '$'str$i`
				printf "|%-${len}s" "`echo $str | cut -c1-${len}`" >> test
				str="`echo $str | cut -c$((len+1))-`"
				if [ ${#str} -eq 0 ];then sp=$((sp+1));fi

				if [ $i -eq 1 ];then str1=$str
				elif [ $i -eq 2 ];then str2=$str
				elif [ $i -eq 3 ];then str3=$str
				elif [ $i -eq 4 ];then str4=$str
				elif [ $i -eq 5 ];then str5=$str
				elif [ $i -eq 6 ];then str6=$str
				else  str7=$str
				fi
			done
			printf "\n  " >> test
		done
	done 
	
}


#test if timetable exist; if not, download it and save in a new file "timetable"
if ! [ -e timetable ];then
	curl 'https://timetable.nctu.edu.tw/?r=main/get_cos_list' --data 'm_acy=107&m_sem=1&m_degree=3&m_dep_id=17&m_group=**&m_grade=**&m_class=**&m_option=**&m_crsname=**&m_teaname=**&m_cos_id=**&m_cos_code=**&m_crstime=**&m_crsoutline=**&m_costype=**' > timetable
fi

if ! [ -e op ];then touch op ;fi
if ! [ -e yourclass ];then touch yourclass ;fi

TEMPTABLE="./timetable"
OPTION="./op"

#make a temp file to save timetable splitted
TEMPTABLE_SPLIT=`mktemp /tmp/tmp.XXXXXX`
if [ $? ];then
	echo "${TEMPTABLE_SPLIT}"
else
	echo "error:cannot create temp file"
fi

#split the class timetable with json format by [{},] and delete the information which is not neccesarry
awk '{split($0,a,"[{},]")} END {for(i=1;i in a;i++) printf("%s\n", a[i])}' timetable | \
awk 'BEGIN {count = 1}
/"cos_time"*/ {gsub(/"cos_time":/,"",$0); gsub(/"/,"",$0); printf("%d \"%s-",count,$0); count++} 
     /"cos_ename"*/ {gsub(/"cos_ename":/,"",$0);gsub(/"/,"",$0);printf("%s\"\n",$0)}' > ${TEMPTABLE_SPLIT}

ch_class_totable

