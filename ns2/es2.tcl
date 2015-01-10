set ns [new Simulator]
set fd [open "out.nam" "w"]
$ns namtrace-all $fd

proc finish {} {
	global ns fd
	$ns flush-trace
	close $fd
	exec nam out.nam &
	exit 0
} 
proc loss {rate a b} {
	set ns [Simulator info instances]
	set em1 [new ErrorModel]
	$em1  unit EU_PKT
	$em1 set rate_ $rate
	$em1 ranvar  [new RandomVariable/Uniform]
	$em1 drop-target [new Agent/Null]
	$ns lossmodel $em1 $a $b
}
	

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

$ns duplex-link $n0 $n1 5Mb 25ms DropTail
$ns simplex-link $n1 $n2 7Mb 50ms DropTail
$ns duplex-link $n1 $n3 10Mb 75ms DropTail
$ns simplex-link $n2 $n4 20Mb 25ms DropTail
$ns duplex-link $n3 $n4 20Mb 25ms DropTail

set agent0 [new Agent/TCP]
set agent4 [new Agent/TCPSink]

$ns attach-agent $n0 $agent0
$ns attach-agent $n4 $agent4

$ns connect $agent0 $agent4

set ftp [new Application/FTP]

$ftp attach-agent $agent0

$ns at 0.2 "$ftp start"
$ns at 4.2 "finish"

set lossrate 0.1
loss $lossrate $n1 $n2

$ns run


