#!/bin/sh

#classlist()
#{
#}


#test if timetable exist; if not, download it and save in a new file "timetable"
if ! [ -e timetable ];then
	curl 'https://timetable.nctu.edu.tw/?r=main/get_cos_list' --data 'm_acy=107&m_sem=1&m_degree=3&m_dep_id=17&m_group=**&m_grade=**&m_class=**&m_option=**&m_crsname=**&m_teaname=**&m_cos_id=**&m_cos_code=**&m_crstime=**&m_crsoutline=**&m_costype=**' > timetable
fi

TEMPTABLE="./timetable"

#make a temp file to save timetable
TEMPTABLE_SPLIT=`mktemp /tmp/tmp.XXXXXX`
if [ $? ];then
	echo "${TEMPTABLE_SPLIT}"
else
	echo "error:cannot create temp file"
fi

#split the class timetable with json format by [{},] and delete the information which is not neccesarry
awk '{split($0,a,"[{},]")} END {for(i=1;i in a;i++) printf("%s\n", a[i])}' timetable | \
awk 'BEGIN {DEP=""} 
     /"dep_ename"*/ {if(DEP==""){DEP=$0;gsub(/"/,"",$0);gsub(/:/," ",$0);printf("%s\n\n",$0)}} 
     /"cos_time"*/ {gsub(/"/,"",$0);gsub(/:/," ",$0);printf("%s\n",$0)} 
     /"cos_ename"*/ {gsub(/"/,"",$0);gsub(/:/," ",$0);printf("%s\n\n",$0)}' > ${TEMPTABLE_SPLIT}




