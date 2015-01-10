set ns [new Simulator]

set fd [open out.nam w]
$ns namtrace-all $fd

#Define a 'finish' procedure
proc finish {} {
	global ns fd
	$ns flush-trace 
	close $fd;		#Close the NAM trace file
 	exec nam out.nam &;	#Execute NAM on the trace file
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

$ns duplex-link $n0 $n1 10M 200ms DropTail

set agentS [new Agent/UDP]
set agentR [new Agent/LossMonitor]

$ns attach-agent $n0 $agentS
$ns attach-agent $n1 $agentR

$ns connect $agentS $agentR

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $agentS
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false

#Schedule events for the CBR agent
$ns at 0.1 "$cbr start"
$ns at 3.1 "$cbr stop"
$ns at 3.6 "finish"

set lossrate 0.6
loss $lossrate $n0 $n1

$ns run

set pac_persi [$agentR set nlost_]
set pac_ricevuti [$agentR set npkts_]
 
set perc_perdita [ expr ($pac_persi *100)/($pac_persi+$pac_ricevuti)]

puts "Pacchetti persi: $pac_persi "
puts "Pacchetti ricevuti : $pac_ricevuti"
puts "Percentuale di perdita : $perc_perdita%"
