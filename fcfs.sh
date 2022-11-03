border()
{
   d=$1
   for((i=0;i<$(($(($d * 16))+$(($d+1))));i++)) #Turn Around time is the max string.It have a length of 16.
   do
      echo -n "-"
   done
   echo
}

print_input()
{
  border 3 
  printf "|%-16s|%-16s|%-16s|\n" "Process ID" "Arrival Time" "Burst Time"
  border 3
  for((i=0;i<$number;i++))
  do
    printf "|%-16s|%-16s|%-16s|\n" "${pid[$i]}" "${at[$i]}" "${bt[$i]}" 
  done
  border 3
}

swap()
{
   temp=${at[$1]}
   at[$1]=${at[$2]}   #swap arrival time
   at[$2]=$temp

   temp=${bt[$1]}
   bt[$1]=${bt[$2]}    #swap burst time
   bt[$2]=$temp

   temp=${pid[$1]}
   pid[$1]=${pid[$2]}     #swap id
   pid[$2]=$temp
}


sort()#bubble sort
{
   for((i=0;i<$number;i++))
   do
      flag=0;
      for((j=0; j<$(($(($number-$i))-1)); j++))
      do
        if [ ${at[$j]} -gt ${at[$(($j+1))]} ]; then
              swap $j $(($j+1))
               flag=1;
        elif [ ${at[$j]} -eq ${at[$(($j+1))]} -a  ${pid[$j]} -gt ${pid[$(($j+1))]} ]; then
               swap $j $(($j+1))
               flag=1;
        fi
      done   
      if [ $flag -ne 1 ]; then
         break;
      fi
   done
}

calc_times()
{
    start=0;
    for((i=0;i<$number;i++))
    do
      idle[$i]=$((${at[$i]}-start));
      if [ ${idle[$i]} -lt 0 ]; then
        idle[$i]=0;
      fi
      st[$i]=$((start+${idle[$i]}));
      ct[$i]=$((${st[$i]}+${bt[$i]}));
      start=${ct[$i]};
    done

    for((i=0;i<$number;i++))
    do
      wt[$i]=$((st[$i]-at[$i])); #waiting time=startingtime - arrival time;
    done

    for((i=0;i<$number;i++))
    do
      tat[$i]=$((wt[$i]+bt[$i]));
    done

    for((i=0;i<$number;i++))
    do
       rt[$i]=$((st[$i]-at[$i]));
    done
}

print_output()
{
  border 7
  printf "|%-16s|%-16s|%-16s|%-16s|%-16s|%-16s|%-16s|\n" "Process ID" "Arrival Time" "Burst Time" "completion time" "waiting time" "Turn around time" "Responce time"
  border 7
  for((i=0;i<$number;i++))
  do
    printf "|%-16s|%-16s|%-16s|%-16s|%-16s|%-16s|%-16s|\n" "${pid[$i]}" "${at[$i]}" "${bt[$i]}" "${ct[$i]}" "${wt[$i]}" "${tat[$i]}" "${rt[$i]}" 
  done
  border 7

  avg_tat=0
  
  for((i=0;i<$number;i++))
  do 
      avg_tat=$(($avg_tat+${tat[$i]}));
  done

  avg_tat=$(($avg_tat / $number))

  echo "Total avg turn around time = $avg_tat"
   
   avg_ct=0;

  for((i=0;i<$number;i++))
  do 
      avg_ct=$(($avg_ct+${ct[$i]}));
  done
   avg_ct=$(($avg_ct / $number))

  echo "Total avg completion time = $avg_ct"
   




}

fcfs() #main function
{
       echo -n "Enter Number of processes: ";
       read number;
     
       echo "------Now enter process id,arrival time,burst time for all $number processes-------"
       for((i=0;i<$number;i++))
       do
        read -p "Enter process id,arrival time,burst time for process $((i+1)) : " pid[$i] at[$i] bt[$i];
       done

       print_input

       sort #now we need to sort on the basis of arriving time
      #  echo "Print sorted table : "
      #  print_input
       #Now I need to calculate completion time so that i can find waiting time;I will also keep the track of idle state
        calc_times

       print_output
}
fcfs
