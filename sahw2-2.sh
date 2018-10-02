#!/bin/sh

ch_class_totable() {
	if ! [ -e yourclass_table ];then touch yourclass_table;fi
	local OP=`cat op`
	local len=15

	if [ $OP -eq 2 ] || [ $OP -eq 4 ];then
		local H="N M A B C D X E F G H I J K"
		local D="1 2 3 4 5 6 7"
		local D_len=7
		printf "x .%-${len}s.%-${len}s.%-${len}s.%-${len}s.%-${len}s.%-${len}s.%-${len}s  \n" Mon Tue Wed Thu Fri Sat Sun > yourclass_table
	elif [ $OP -eq 1 ] || [ $OP -eq 3 ];then
		local H="A B C D E F G H I J K"
		local D="1 2 3 4 5"
		local D_len=5
		printf "x .%-${len}s.%-${len}s.%-${len}s.%-${len}s.%-${len}s \n" Mon Tue Wed Thu Fri > yourclass_table
	fi

	for hour in $H;do
		printf "%s" "--" >> yourclass_table
		for i in $D;do
			local j=1
			while [ $j -lt $((len+1)) ];do
				printf "%s" "-" >> yourclass_table
				j=$((j+1))
			done
		done

		printf "\n%s" "$hour " >> yourclass_table

		for day in $D;do
			if [ $OP -eq 1 ] || [ $OP -eq 2 ];then
				local str="`awk "/${day}[A-KNMX]*${hour}/ "'{ gsub(/[1-5][A-KNMX]+[1-5]?[A-KXNM]* /,"",$0); gsub(/[A-Z]+[0-9]+ /,"",$0); gsub(/"/,"",$0); printf("%s.",$0); }' yourclass`"
			elif [ $OP -eq 3 ] || [ $OP -eq 4 ];then
				local str="`awk "/${day}[A-KNMX]*${hour}/ "'{ gsub(/[1-5][A-KNMX]+[1-5]?[A-KXNM]*/,"",$0); gsub(/ ?".*"/,"",$0); printf("%s.",$0); }' yourclass`"
			fi

			if [ $day -eq 1 ];then str1=$str
			elif [ $day -eq 2 ];then str2=$str
			elif [ $day -eq 3 ];then str3=$str
			elif [ $day -eq 4 ];then str4=$str
			elif [ $day -eq 5 ];then str5=$str
			elif [ $day -eq 6 ];then str6=$str
			else  str7=$str
			fi
		done
		
		local sp=0
		while ! [ ${sp} -eq ${D_len} ];do
			sp=0
			for i in $D;do
				str=`eval echo '$'str$i`
				printf "|%-${len}s" "`echo $str | cut -c1-${len}`" >> yourclass_table
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
			printf "\n  " >> yourclass_table
		done
	done
	CH=1	
}

display_widget1() {
	#the option selected last time
	local OP=`cat op`

	dialog --clear --cancel-label "Exit" \
		--menu "Select how to show your class table" 15 80 30 \
		"1" "show course name and no additional time" \
		"2" "show course name and additional time" \
		"3" "show classroom number and no additional time" \
		"4" "show classroom number and additional time" 2>op

	local status=$?
	local NEW_OP=`cat op`
	if [ $status -eq 1 ] || [ $status -eq 255 ];then
		echo 1 > widget
		echo "Exit"
	elif [ $status -eq 0 ] && [ $OP -eq $NEW_OP ];then
		display_widget0
	else
		CH=0
		display_widget0
	fi
}

display_widget2() {
	local str=`cat $TEMPSEARCH`
	local is_NULL=1
	if [ $search_type -eq 1 ] || [ $search_type -eq 255 ] || [ ${#str} -eq 0 ];then
		dialog --clear --extra-button --extra-label "show yourclass" --help-button --help-label "Search" \
			--cancel-label "Exit" --ok-label "Select" \
			--menu "Select courses" 50 80 50 \
	       		--file ${TEMPTABLE_SPLIT} 2>${TEMPOP}
	elif [ $search_type -eq 0 ];then 
		#search by time
		local T="`awk "/^[1-7]/ "'{
			for(i=1;i<=length($0);i++){
				c=substr($0,i,1);
				if(c~/[1-7]/){ num=c; }
				if(c~/[A-KXNM]/){ printf("%c%c ",num,c);}
			}
		}' $TEMPSEARCH`"

		cat $TEMPTABLE_SPLIT  > $TEMPSEARCH
		TEMPIN=`mktemp /tmp/tmp.XXXXXX`
		for t in $T;do
			cat $TEMPSEARCH > $TEMPIN
			local d=`echo $t | cut -c1`
			local h=`echo $t | cut -c2`
			grep -e "$d[A-KNMX]*$h" $TEMPIN > $TEMPSEARCH 
		done
		
		rm $TEMPIN	
		str=`cat $TEMPSEARCH`
		if [ ${#str} -ne 0 ];then
			dialog --clear --extra-button --extra-label "show yourclass" --help-button --help-label "Search" \
			--cancel-label "Exit" --ok-label "Select" \
			--menu "Select courses" 50 80 50 --file ${TEMPSEARCH} 2>${TEMPOP}
		else
			is_NULL=0
			dialog --clear --extra-button --extra-label "show yourclass" --help-button --help-label "Search" \
			--cancel-label "Exit" --ok-label "Return to timetable" \
			--yesno "NULL" 5 100
		fi	
	elif [ $search_type -eq 3 ];then
		#search by course name
		grep -e ".*-.*-$str.*" $TEMPTABLE_SPLIT > $TEMPSEARCH
		str=`cat $TEMPSEARCH`
		if [ ${#str} -ne 0 ];then
			dialog --clear --extra-button --extra-label "show yourclass" --help-button --help-label "Search" \
			--cancel-label "Exit" --ok-label "Select" \
			--menu "Select courses" 50 80 50 --file ${TEMPSEARCH} 2>${TEMPOP}
		else
			is_NULL=0
			dialog --clear --extra-button --extra-label "show yourclass" --help-button --help-label "Search" \
			--cancel-label "Exit" --ok-label "Return to timetable" \
			--yesno "NULL" 5 100
		fi

	fi
 
	local OP=$?
	if [ $OP -eq 1 ] || [ $OP -eq 255 ];then
		echo $CH > ch
		echo 2 > widget
		echo "Exit"
	elif [ $OP -eq 0 ] && [ $is_NULL -ne 0 ];then
		display_widget3
	elif [ $OP -eq 0 ] && [ $is_NULL -eq 0 ];then
		display_widget2
	elif [ $OP -eq 3 ];then
		display_widget0
	elif [ $OP -eq 2 ];then
		display_widget4
	fi
}

#test whether the class make collision
display_widget3() {
	if [ $load3 -eq 1 ];then
		if [ -e w3content ];then touch w3content;fi
		local OP=`cat ${TEMPOP}`
		local T="`awk "/^${OP} ".*"/ "'{ 
			gsub(/"/,"",$2); gsub(/-.+/,"",$2);
			for(i=1;i<=length($2);i++){
				c=substr($2,i,1);
				if(c~/[1-7]/){ num=c; }
				if(c~/[A-KXNM]/){ printf("%c%c ",num,c);}
			}
		 }' ${TEMPTABLE_SPLIT}`"

		printf "Collisions occur:" > w3content
		local success=0
		for t in $T;do 
			local d=`echo $t | cut -c1`
			local h=`echo $t | cut -c2`
			local is_collision="`awk "BEGIN "'{same=1} '"/$d[A-KNMX]*$h/ "'{same=0;} '"END "'{printf("%d",same);} ' yourclass`"
			if [ $is_collision -eq 0 ];then
				printf "$t " >> w3content
				success=1
			fi
		done

		if [ $success -eq 0 ];then
			echo "successfully select" > w3content
			awk "/^${OP} ".*"/ "'{sub(/[0-9]+ /,"",$0);sub(/"/,"",$0);sub(/-/," ",$0);sub(/-/," \"");printf("%s\n",$0)} ' ${TEMPTABLE_SPLIT} >> yourclass 
			CH=0
		else
			printf "\nPlease reselect" >> w3content
		fi
	fi
	
	dialog --clear --no-label "Exit" --yes-label "ok" \
		--yesno "`cat w3content`" 15 40

	OP=$?
	if [ $OP -eq 0 ];then
		if [ $load3 -eq 0 ];then load3=1;fi
		search_type=1
		display_widget2
	elif [ $OP -eq 1 ];then
		echo 3 > widget
		echo $CH > ch
		echo "Exit"
	fi
}

display_widget4() {

	dialog --ok-label "Search by free time" --no-label "Exit" --extra-button --extra-label "Search by course name" \
		--inputbox "the part of course name or the time you want to serach" 15 45 2>$TEMPSEARCH

	search_type=$?
	if [ $search_type -eq 1 ] || [ $search_type -eq 255 ];then
		echo 4 > widget
		echo $CH > ch
		echo "Exit"
	elif [ $search_type -eq 0 ] || [ $search_type -eq 3 ];then
		display_widget2
	fi

}

display_widget0() {
	if  [ -e yourclass_table ] || [ $CH -eq 0 ];then ch_class_totable;fi

	#Options:3 Exit:2 Add Class:0
	dialog --clear --extra-button --extra-label "Options" \
       			--help-button --help-label "Exit" \
			--ok-label "Add Class" \
			--textbox yourclass_table 100 100

	local status=$?
	if [ $status -eq 3 ];then
		display_widget1
	elif [ $status -eq 0 ];then
		#search_type=1
		display_widget2
	else
		echo $CH > ch		
	        echo 0 > widget	
		echo "Exit"
	fi
}


#test if timetable exist; if not, download it and save it in a new file "timetable"
if ! [ -e timetable ];then
	curl 'https://timetable.nctu.edu.tw/?r=main/get_cos_list' --data 'm_acy=107&m_sem=1&m_degree=3&m_dep_id=17&m_group=**&m_grade=**&m_class=**&m_option=**&m_crsname=**&m_teaname=**&m_cos_id=**&m_cos_code=**&m_crstime=**&m_crsoutline=**&m_costype=**' > timetable
fi

#ch - show that if add class or change show Option of widget 0
#op - the number in the file op records the newest option you chooseto show at widget0
#widget - the number in the file widget records what widget you stay in the last time 
#yourclass - it is your selected class record
if ! [ -e ch ];then touch ch; echo 0 > ch;fi
if ! [ -e op ];then touch op; echo 1 > op;fi
if ! [ -e widget ];then touch widget; echo 0 > widget;fi
if ! [ -e yourclass ];then touch yourclass;fi

#make a temp file to save timetable splitted
TEMPTABLE_SPLIT=`mktemp /tmp/tmp.XXXXXX`
if [ $? ];then echo "${TEMPTABLE_SPLIT}";else echo "error:cannot create temp file";fi
TEMPOP=`mktemp /tmp/tmp.XXXXXX`
if [ $? ];then echo "${TEMPOP}";else echo "error:cannot create temp file";fi
TEMPSEARCH=`mktemp /tmp/tmp.XXXXXX`
if [ $? ];then echo "${TEMPSEARCH}";else echo "error:cannot create temp file";fi

#split the class timetable with json format by [{},] and delete the information which is not neccesarry
awk '{split($0,a,"[{},]")} END {for(i=1;i in a;i++) printf("%s\n", a[i])}' timetable | \
awk 'BEGIN {count = 1}
/"cos_time"*/ {gsub(/"cos_time":/,"",$0); gsub(/"/,"",$0); printf("%d \"%s-",count,$0); count++} 
     /"cos_ename"*/ {gsub(/"cos_ename":/,"",$0);gsub(/"/,"",$0);printf("%s\"\n",$0)}' > ${TEMPTABLE_SPLIT}

#define the variable needed:
#load3 - whether the exit widget is widget3
#CH - whether added class or change different way to show
#search_type - for widget4
#W - the exit widget
load3=1
search_type=1
CH=`cat ch`
W=`cat widget`
if [ $W -eq 3 ];then load3=0;fi

#start display
display_widget$W
