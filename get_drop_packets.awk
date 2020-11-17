
BEGIN {

droppedPackets = 0;

}

{

#packet delivery ratio

if ($1 == "d" && $5 == "tcp"){

droppedPackets++; 

}
 
}

END { 


print "\n";


print "Total Dropped Packets for tcp flow = " droppedPackets;


print "\n";

}
