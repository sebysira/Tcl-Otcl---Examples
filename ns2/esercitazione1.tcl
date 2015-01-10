set ns [new Simulator]

set fd [open out.nam w]
$ns namtrace-all $fd

#Define a 'finish' procedure
proc finish {} {
        global ns fd
        $ns flush-trace     
        close $fd 		;#Close the NAM trace file
        exec nam out.nam &	;#Execute NAM on the trace file
        #exit 0
}

#perdite di pacchetti: na, nb identificano il link 
proc loss {rate na nb} {
	set ns [Simulator info instances]
	set em1 [new ErrorModel]
	$em1 unit EU_PKT		;# errori a livello di pacchetto
	$em1 set rate_ $rate
	$em1 ranvar [new RandomVariable/Uniform]
	$em1 drop-target [new Agent/Null]
	$ns lossmodel $em1 $na $nb	;#collega il lossmodel al link assegnato
	
	set em2 [new ErrorModel]
	$em2 unit EU_PKT		;# errori a livello di pacchetto
	$em2 set rate_ $rate
	$em2 ranvar [new RandomVariable/Uniform]
	$em2 drop-target [new Agent/Null]
	$ns lossmodel $em2 $nb $na	;#collega il lossmodel al link assegnato
}

set n0 [$ns node]
set n1 [$ns node]

$ns duplex-link $n0 $n1 5Mb 100ms DropTail

set agent0 [new Agent/UDP]
set agent1 [new Agent/LossMonitor]

$ns attach-agent $n0 $agent0
$ns attach-agent $n1 $agent1

$ns connect $agent0 $agent1

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $agent0
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false

#Schedule events for the CBR agent
$ns at 0.1 "$cbr start"
$ns at 2.1 "$cbr stop"
$ns at 2.2 "finish"

set lossrate 0.2
loss $lossrate $n0 $n1

$ns run

set nlost [$agent1 set nlost_]

set npkts [$agent1 set npkts_]

set lost_percentage [expr ($nlost * 100 /($npkts+$nlost))]
set received_percentage [expr 100 - $lost_percentage]
set bytes [$agent1 set bytes_]

puts "Loss rate: $lossrate"
puts "Packets lost: $nlost ($lost_percentage%)"
puts "Packets received: $npkts ($received_percentage%)"
puts "Bytes received: $bytes"

#con delaybox posso simulare il traffico internet