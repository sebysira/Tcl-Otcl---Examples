set ns [new Simulator]

set fd [open out.nam w]
set ft [open result.txt w]
$ns namtrace-all $fd

#procedura finish
proc finish {} {
    global ns fd ft
	$ns flush-trace     
    close $fd;									#Close the NAM trace file
	close $ft;        
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

#procedura simulation
proc simulation {} {
	global fd ft times timeTotal timeTest timeSlice nTest totTest maxAck_D_A maxAck_A_D agent_A_send agent_D_send ftp_A_D ftp_D_A bytes_A_D bytes_D_A
	set ns [Simulator info instances]
	
	#setting dei timer
    set timeTotal [expr $timeTotal+$timeSlice]
    set timeTest [expr $timeTest+$timeSlice]
    
    #numero di ack ricevuti
    set ackRic_A_D [$agent_A_send set ack_]
    set ackRic_D_A [$agent_D_send set ack_]

	if {$ackRic_A_D >= $maxAck_A_D && $ackRic_D_A >= $maxAck_D_A} {
	    
	    puts $ft "Il test $nTest ha impiegato $timeTest secondi"
	    
	    set times($nTest) $timeTest
	  
	    #controllo se tutti i test sono stati fatti
	    if {$nTest == $totTest} {
	        puts "Ho finito tutti i test !"
	        
	        set z 1.644854
	        set sum 0
	        for {set i 1} {$i<=$totTest} {incr i} {
		    set sum [expr $sum + $times($i)]
		    
	        }
	        set average [expr $sum/ $totTest]
	        
	        set var 0
	        for {set i 1} {$i<=$totTest} {incr i} {
		    set temp [expr $times($i) - $average]
		    set temp [expr $temp * $temp]
		    set var [expr $var + $temp]
	        }
	        set var [expr $var / $totTest]
	        set devStd [expr sqrt ($var)]
	        
			puts $ft ""
	        puts $ft "Media dei tempi $average"
	        puts $ft "Varianza dei tempi $var"
	        puts $ft "Dev std dei tempi $devStd"
	        
	        set estremo1 [expr $average - [expr $z * [expr $devStd / [expr sqrt($totTest)]]]]
	        
	        set estremo2 [expr $average + [expr $z * [expr $devStd / [expr sqrt($totTest)]]]]
	        
	        puts $ft "Intervallo si confidenza $estremo1 - $estremo2"
	        
		$ns at $timeTotal "finish"
	    
	    } else {	   
	    
		incr nTest 
		set timeTest 0
		set time_A_D 0
		set time_D_A 0
		puts "Inizio del test $nTest..."
		$ns at $timeTotal "$ftp_A_D send $bytes_A_D"
		$ns at $timeTotal "$ftp_D_A send $bytes_D_A"
		$ns at $timeTotal "simulation"
		$ns run
	    }
	   
	
    } else {

	#richiamo simulation
	$ns at $timeTotal "simulation"
    }	
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

#dimensioni dei dati da trasferire via FTP
set bytes_A_D [expr 100 * 1024 * 1024]
set bytes_D_A [expr 20  * 1024 * 1024]

#numero di ack da ricevere
set maxAck_A_D [expr $bytes_A_D / [$agent_A_send set packetSize_]]
set maxAck_D_A [expr $bytes_D_A / [$agent_D_send set packetSize_]]

#variabili per il test
set times(1) 0
set time_A_D 0
set time_D_A 0
set timeTotal 0
set timeSlice 0.1
set timeTest 0
set nTest 1
set totTest 20

set lossrate 0.005
loss $lossrate $B $C

puts "Inizio del test $nTest..."
$ns at 0 "$ftp_A_D send $bytes_A_D"
$ns at 0 "$ftp_D_A send $bytes_D_A"
$ns at 0 "simulation"

$ns run





