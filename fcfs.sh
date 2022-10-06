#!/bin/bash
border()#Creates Border for table
{
    #Determines Table size
    x=$(($1*20))
    for((i=1;i<=$(($x+$1+1));i++));
    do
      echo -n "-"
    done
    echo
}

grant_chart_border()
{
    for((i=1;i<=$1;i++))
    do
      if [ $i -le 9 ]; then
         echo -n "---"
      else
         echo -n "----"
      fi
    done
    echo "--"
   
}

p_in()#print the input as table
{
    border 3 # 3 because ,20 dash for each attributes
    printf "|%-20s|%-20s|%-20s|\n" "Process ID" "Arrival Time" "Burst Time"
    border 3
    for((i=0;i<$number;i++))
    do
      printf "|%-20s|%-20s|%-20s|" "P${id[$i]}" "${at[$i]}" "${bt[$i]}" 
      echo
    done
    border 3
}

swap(){
   temp=${at[$1]}
   at[$1]=${at[$2]}   #swap arrival time
   at[$2]=$temp

   temp=${bt[$1]}
   bt[$1]=${bt[$2]}    #swap burst time
   bt[$2]=$temp

   temp=${id[$1]}
   id[$1]=${id[$2]}     #swap id
   id[$2]=$temp
}

sort()
{
    #Sorting on the basis of arrival time [FCFS]
  for((i=0;i<$number;i++))
  do
    flag=0;
    for((j=0;j<number-i-1;j++))
    do
      if [ ${at[$j]} -gt ${at[$j+1]} ]; then
         swap j $(($j+1))
         flag=1

      elif [ ${at[$j]} -eq ${at[$j+1]} ]; then #if arrival time is eqal then sort by id
         if [ ${id[$j]} -gt ${id[$j+1]} ]; then
            swap j $(($j+1))
         fi         
      fi
    done

    if [ $flag -eq 0 ]; then
        break
    else 
       flag=0
    fi
  done
}

grant_chart_calc()
{
   start_point=0

   for((i=0;i<$number;i++))
   do
        if [ ${at[$i]} -gt $start_point ]; then
           # idle=$(($at[i]-$start_point))
        #    for((j=$start_point;j<=${at[$i]};j++))
        #    do
        #        grant_chart[$j]=0
        #    done
          idle[$i]=$((${at[i]}-$start_point))
          start_point=${at[$i]}
        else
          idle[$i]=0
          
        fi

        # echo "Current starting point : $start_point , ${bt[i]}"
        completion_time[$i]=$(($start_point+${bt[$i]}))
        # echo "Current completion point * : ${completion_time[$i]}"

        # for((j=$start_point;j<=${completion_time[i]};j++))
        # do
        #   grant_chart[j]=1
        # done
        start_point=${completion_time[$i]}
   done

   
   echo "Completion times "
   for((i=0;i<$number;i++))
   do
     echo -n "${completion_time[$i]} "
   done
   echo
   echo "idles "
   for((i=0;i<$number;i++))
   do
     echo -n "${idle[$i]} "
   done
   echo
   draw_grant #Function For Drawing grant chart 
}

draw_grant()
{ 

    echo "_______________________________Drawing Grant chart______________________________"

    echo "Every # represents idle state,R is a Running_proceess "
    
    echo

   start=0
   grant_chart_border ${completion_time[$(($number-1))]}

   for((i=0;i<$number;i++))
   do
     avgdif=$(($((${completion_time[$i]}-$start))/2))

      for((j=$start;j<=${completion_time[$i]};j++))
      do
         if [ $j -eq $(($start+$avgdif)) ]; then
            echo -n " p${id[$i]}  "
         else
            echo -n "   "
         fi
      done
      start=$((${completion_time[$i]}+1))
   done
   echo
    
   start=0
   grant_chart_border ${completion_time[$(($number-1))]}
    
    for((i=0;i<$number;i++))
    do
         # echo "${idle[$i]} "
         # echo -n "p${id[$i]}"
         for((j=$start;j<=${completion_time[$i]};j++))
         do
            # echo "$j"
         

         if [ $j -gt 9 ]; then
          
           if [ $j -eq ${completion_time[$i]} ]; then
              echo -n " |  "
              break 
           fi

           if [ $j -lt $(($start+${idle[$i]})) ]; then
              echo -n "    "
           elif [ $j -ge ${idle[$i]} ]; then
              echo -n "    "
           fi
           
         else
           if [ $j -eq ${completion_time[$i]} ]; then
              echo -n "|  "
              break 
           fi

           if [ $j -lt $(($start+${idle[$i]})) ]; then
              echo -n "   "
           elif [ $j -ge ${idle[$i]} ]; then
              echo -n "   "
           fi
         fi        
         done
         start=$((${completion_time[$i]}+1));  
         # j=${completion_time[i]}
         # echo "value of j is $j , ${idle[i]}"
         # echo "$j"
    done
    echo
   grant_chart_border ${completion_time[$(($number-1))]}
 
    start=0

    for((i=0;i<$number;i++))
    do
         # echo "${idle[$i]} "
         for((j=$start;j<=${completion_time[$i]};j++))
         do
            # echo "$j"
         

         if [ $j -gt 9 ]; then
          
           if [ $j -eq ${completion_time[$i]} ]; then
              echo -n " R  "
              break 
           fi

           if [ $j -lt $(($start+${idle[$i]})) ]; then
              echo -n " #  "
           elif [ $j -ge ${idle[$i]} ]; then
              echo -n " R  "
           fi
           
         else
           if [ $j -eq ${completion_time[$i]} ]; then
              echo -n "R  "
              break 
           fi

           if [ $j -lt $(($start+${idle[$i]})) ]; then
              echo -n "#  "
           elif [ $j -ge ${idle[$i]} ]; then
              echo -n "R  "
           fi
         fi        
         done
         start=$((${completion_time[$i]}+1));  
         # j=${completion_time[i]}
         # echo "value of j is $j , ${idle[i]}"
         # echo "$j"
    done

    echo

    grant_chart_border ${completion_time[$(($number-1))]}
   
    start=0
    for((i=0;i<$number;i++))
    do
      for((j=$start;j<=${completion_time[$i]};j++))
      do 
         # if [ $j -eq $start ]; then
         #    echo -n "$j "
         # elif [ $j -eq ${completion_time[$i]} ]; then
         #    echo -n "$j "
         # elif [ $j -eq $((${idle[$i]}-1)) ]; then
         #      echo -n "$j "
         # else
         #    echo -n "  "
         # fi
         echo -n "$j  "
      done

      start=$((${completion_time[$i]}+1)) 
    done
    echo
}

avgtat=0

turn_around_time()
{
   for((i=0;i<$number;i++))
   do
     ta[$i]=$((${completion_time[$i]}-${at[$i]}))
     avgtat=$(($avgtat+${ta[$i]}))
   done
}
avgwt=0
waiting_time()
{
  
   for((i=0;i<$number;i++))
   do
     wt[$i]=$((${ta[$i]}-${bt[$i]}))
     avgwt=$(($avgwt+${wt[$i]}))
   done

}

response_time()
{
   start=0;

   for((i=0;i<$number;i++))
   do
      rt[$i]=$(($((${completion_time[$i]}-${bt[$i]}))-${at[$i]}))
   done
}

draw_final_chart()
{
   border 7
   printf "|%-20s|%-20s|%-20s|%-20s|%-20s|%-20s|%-20s|\n" "Process ID" "Arrival Time" "Burst Time" "Completion_time" "Turn around time" "Waiting time" "Response time"
   border 7

   for((i=0;i<$number;i++))
    do
      printf "|%-20s|%-20s|%-20s|%-20s|%-20s|%-20s|%-20s|" "P${id[$i]}" "${at[$i]}" "${bt[$i]}" "${completion_time[$i]}" "${ta[$i]}" "${wt[$i]}" "${rt[$i]}"
      echo
    done

   border 7
}

findavg()
{
   printf "Average waiting time : %.3f\n" "$(($avgwt/$number))"
   printf "Average turn around time : %.3f\n" "$(($avgtat/$number))"
}

fcfs()
{
    echo -n "How many processes are there? : " # Variable : number
    read number 
    #Take input of specific Attributes
    for((i=0;i<$number;i++))
    do
      echo -n "Enter Process ID: "
      read id[$i]
      echo -n "Enter Arrival Time: "
      read at[$i]
      echo -n "Enter Burst Time: "
      read bt[$i]
    done
    echo "___input table___"
    p_in #Print input table
    sort #Now we will sort the Processes based on their arriving time
    echo "___After sorting we get___"
    p_in

    #Now I will draw the grant chart
    grant_chart_calc #completion time will be calculated for drawing grant chart inside grant function
    
    #Now find Turn around time
    turn_around_time

    #Now find waiting time
    waiting_time

    response_time
    
    echo
    echo "**Drawing Final chart**"
    draw_final_chart
    findavg

    #
}
fcfs #Main function