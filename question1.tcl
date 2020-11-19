##################################################################################################################
#														 #
# This script was created as part of ACN ASSIGNMENT1 for BITS WILP COURSE - Advanced Computer Networks (CS ZG525)#
#														 #
# Author: BASKAR BALASUBRAMANIAN BITS ID: 2019HT66015@wilp.bits-pilani.ac.in 					 #
#														 #
# Code is available in GitHub location: https://github.com/2019HT66015/CN/tree/ACN_ns_assignment_tcp 		 #
#														 #
##################################################################################################################

# nam trace file and ns tracefiles are defined here
set namfile     out.nam
set tracefile   out.tr

set ns [new Simulator]

# Set the TCP Variant details here (For this assignment it was set to either cubic or reno)
set TCP_Variant "Agent/TCP/Linux"
#set TCP_Name "cubic"
set TCP_Name "reno"

set MSS 1448

$ns color 0 red
$ns color 1 blue 
$ns color 2 green

proc monitor {interval} {
    global tcp1 ns tcpsink1
    set nowtime [$ns now]

    set win [open result a]
    set bw1 [$tcpsink1 set bytes_]
    #set tput [expr $bw1/$interval*8/1000000]
    set cwnd [$tcp1 set cwnd_]
    #puts $win "$nowtime $tput $cwnd]"
    puts $win "$nowtime $cwnd"
    $tcpsink1 set bytes_ 0
    close $win
	
    $ns after $interval "monitor $interval"

}

#Usually this procedure is named as finish. For this assignment it has been renamed as plotWindow, since it also performs plotWindow (cwnd vs time) using xgraph. 
#There is also the code that would count the number of dropped packets in the tcp flow. It has been commented in the code. 

proc plotWindow {} {
	global ns nf f namfile
	$ns flush-trace
	close $nf
	close $f

	puts "running nam..."
	#exec nam $namfile

#	Plotting the xgraph with the result file
	exec cp result congestionReno.xg
#	exec cp result congestionCubic.xg

	exec xgraph -bg green -fg blue congestionReno.xg -t "TCP cwnd" -x "time (milli seconds)" -y "cwnd size (bytes)" -geometry 800x400 &
#	exec xgraph -bg green -fg blue congestionCubic.xg -t "TCP cwnd" -x "time (milli seconds)" -y "cwnd size (bytes)" -geometry 800x400 &

# Code to count the number of dropped packets in tcp flow (Commented now)

	#puts "Number of dropped packets for the tcp flow"
	#exec gawk -f get_drop_packets.awk out.tr &

	exit 0
}


# open trace files and enable tracing
set nf [open $namfile w]
$ns namtrace-all $nf
set f [open $tracefile w]
$ns trace-all $f

# create nodes 
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]

# create link (n0-n2)
$ns duplex-link $n0 $n2 1Mb 2ms DropTail

# create link (n1-n2)
$ns duplex-link $n1 $n2 1Mb 2ms DropTail

# create link (n2-n3)
$ns duplex-link $n2 $n3 700Kb 2ms DropTail

# create node and link (n4-n3)
$ns duplex-link $n4 $n3 1Mb 2ms DropTail

# create two nodes (n3-n5)
$ns duplex-link $n3 $n5 700Kb 2ms DropTail

# create two nodes (n5-n6)
$ns duplex-link $n5 $n6 1Mb 2ms DropTail

# create two nodes (n5-n7)
$ns duplex-link $n5 $n7 1Mb 2ms DropTail

# Define Routing policy as Session

$ns rtproto Session

# create FullTcp agents for the nodes (n1 - n6)
# TcpApp needs a two-way implementation of TCP
# TCP variant used is cubic

set tcp1 [new $TCP_Variant]

$ns at 0 "$tcp1 select_ca $TCP_Name"

$tcp1 set packetSize_ $MSS

# Set red color for tcp1 flow
$tcp1 set fid_ 0

$ns attach-agent $n1 $tcp1

set tcpsink1 [new Agent/TCPSink]
$ns attach-agent $n6 $tcpsink1

$ns connect $tcp1 $tcpsink1

#Setup a FTP over TCP connection
set ftp1 [new Application/FTP]

$ftp1 attach-agent $tcp1

#Create UDP Flows between n0 and n7 and n4 and n7

#Create a UDP agent and attach it to node n0
set udp1 [new Agent/UDP]

# Set blue color for udp1 flow
$udp1 set fid_ 1

$ns attach-agent $n0 $udp1

#Create a Null agent (a traffic sink) and attach it to node n7
set udpsink1 [new Agent/Null]
$ns attach-agent $n7 $udpsink1

#Connect the traffic source with the traffic sink
$ns connect $udp1 $udpsink1

#Create a UDP agent and attach it to node n4
set udp2 [new Agent/UDP]

# Set green color for cbr2 flow
$udp2 set fid_ 2

$ns attach-agent $n4 $udp2

#Create a Null agent (a traffic sink) and attach it to node n7
set udpsink2 [new Agent/Null]
$ns attach-agent $n7 $udpsink2

#Connect the traffic source with the traffic sink
$ns connect $udp2 $udpsink2

# Create a CBR traffic source and attach it to udp1
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 500
$cbr1 set interval_ 0.005
$cbr1 attach-agent $udp1


# Create a CBR traffic source and attach it to udp2
set cbr2 [new Application/Traffic/CBR]
$cbr2 set packetSize_ 500
$cbr2 set interval_ 0.005
$cbr2 attach-agent $udp2


#Schedule FTP for TCP agent
$ns at 0 "$ftp1 start"
$ns at 19 "$ftp1 stop"

#Schedule events for the CBR agent
#run1
$ns at 8 "$cbr1 start"
$ns at 13 "$cbr1 stop"

#run2
#$ns at 0 "$cbr1 start"
#$ns at 13 "$cbr1 stop"

#run3
#$ns at 0 "$cbr1 start"
#$ns at 12 "$cbr1 stop"

#Schedule events for the CBR agent
#run1
$ns at 8 "$cbr2 start"
$ns at 13 "$cbr2 stop"

#run2
#$ns at 0 "$cbr2 start"
#$ns at 13 "$cbr2 stop"

#run3
#$ns at 10 "$cbr2 start"
#$ns at 19 "$cbr2 stop"


#call the monitor at the end
$ns at 0 "monitor 0.1"

$ns at 22.0 "plotWindow"


$ns run
