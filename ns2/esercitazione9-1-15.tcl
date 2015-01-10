set ns [new Simulator]

set tf [open traccia.tr w]
set fd [open out.nam w]
$ns namtrace-all $fd
#$ns trace-all $tf

#procedura finish
proc finish {} {
    global ns fd tf
	$ns flush-trace     
    close $fd;									#Close the NAM trace file
	close $tf;        
	exec nam out.nam &;							#Execute NAM on the trace file
    exit 0
}

#procedura loss
proc loss {rate na nb} {
	set ns [Simulator info instances]
	set em1 [new ErrorModel]
	$em1 unit EU_PKT;							# errori a livello di pacchetto
	$em1 set rate_ $rate
	$em1 ranvar [new RandomVariable/Uniform]
	$em1 drop-target [new Agent/Null]
	$ns lossmodel $em1 $na $nb;					#collega il lossmodel al link assegnato

	set em2 [new ErrorModel]
	$em2 unit EU_PKT;							# errori a livello di pacchetto
	$em2 set rate_ $rate
	$em2 ranvar [new RandomVariable/Uniform]
	$em2 drop-target [new Agent/Null]
	$ns lossmodel $em2 $nb $na;					#collega il lossmodel al link assegnato
}

#procedura di controllo
proc control {} {
	global fd tf monCD monBA
	set ns [Simulator instance]
	set tm 0.1;									#tempo di campionamento						
	set packArrivedD [$monCD set parrivals_]
	set packArrivedA [$monBA set parrivals_]
	set byteArrivedD [$monCD set barrivals_]
	set byteArrivedA [$monBA set barrivals_]
	set now [$ns now];							#tempo attuale
	puts $tf "A tempo: $now sono arrivati a D $packArrivedD pacchetti e $byteArrivedD bytes"
	puts $tf "A tempo: $now sono arrivati ad A $packArrivedA pacchetti e $byteArrivedA bytes"
	$ns at [expr $now+$tm] "control"
}


# 4 nodi disposti in fila
set A [$ns node]
set B [$ns node]
set C [$ns node]
set D [$ns node]

$A color black;
$B color red;
$C color red;
$D color green;

$A label "A";
$B label "B";
$C label "C";
$D label "D";

# link A-B e C-D bidirezionali senza errori di trasmissione.
$ns duplex-link $A $B 100Mb 1ms DropTail
$ns duplex-link $C $D 100Mb 1ms DropTail

#link B-C bidirezionale asimmetrico
$ns simplex-link $B $C 7Mb 200ms DropTail
$ns simplex-link $C $B 480Kb 200ms DropTail

set agent_A_send [new Agent/TCP]
set agent_D_rec [new Agent/TCPSink]

set agent_D_send [new Agent/TCP]
set agent_A_rec [new Agent/TCPSink]

$ns attach-agent $A $agent_A_send
$ns attach-agent $A $agent_A_rec

$ns attach-agent $D $agent_D_send
$ns attach-agent $D $agent_D_rec

$ns connect $agent_A_send $agent_D_rec
$ns connect $agent_D_send $agent_A_rec

set ftp_A_D [new Application/FTP]
set ftp_D_A [new Application/FTP]

$ftp_A_D attach-agent $agent_A_send
$ftp_D_A attach-agent $agent_D_send

# punto a dell' esercizio
$ns queue-limit $B $C 20;
$ns queue-limit $C $B 20;

# monitor dei link C-D e B-A
set monCD [$ns monitor-queue $C $D [$ns get-ns-traceall]];
set monBA [$ns monitor-queue $B $A [$ns get-ns-traceall]];

$ns at 0 "control"
$ns at 0.1 "$ftp_A_D send 100000000"
$ns at 0.1 "$ftp_D_A send 20000000"
$ns at 12000.1 "finish"

set lossrate 0.05
loss $lossrate $B $C

$ns run





