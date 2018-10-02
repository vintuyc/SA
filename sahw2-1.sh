#!/bin/sh

ls -ARl | grep -e '^[-d]' | awk 'BEGIN {total_size=0; count_file=0; count_dir=0; for(i=1;i<=5;i++) {maxf[i]=0;name[i]=""}} /^d/ {count_dir++} /^-/ {count_file++; total_size+=$5;
if($5>=maxf[5]){
   maxf[5]=$5; name[5]=$9;
   for(i=5;i>=2;i--){
	if(maxf[i]>=maxf[i-1]){
		t1 = maxf[i-1]; t2=name[i-1];
		maxf[i-1]=maxf[i]; name[i-1]=name[i];
		maxf[i]=t1; name[i]=t2;
	}
    }
}}
 END {for(i=1;i<=5;i++)if(name[i]!="")print i":"maxf[i]" "name[i]; print "Dir num: "count_dir; print "File num: "count_file; print "Total: "total_size}'
