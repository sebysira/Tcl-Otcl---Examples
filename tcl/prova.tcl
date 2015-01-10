# esempio 2
proc leggi {file} {
	set f [open $file "r+"]
	set l {}
	while { ! [eof $f] } {
		gets $f str
		if { $str != {} } { lappend l $str }
	} 
	close $f
	return $l
}

set mylist [leggi "lista.txt" ]
puts $mylist



# esempio 1
# set l {}
# 
# puts "Inserisci il numero di elementi :"
# gets stdin n
# for {set i 1} {$i<=$n} {incr i} {
# 	puts "Inserisci il $i : "
# 	gets stdin x
# 	lappend l $x
# }
# puts "La lista creata e' : $l !"


# esercizio su file
# set f [open "myfile.txt" "w+"]
# puts $f "Ciao, mi chiamo sebastiano siragusa!"
# close $f
# set f [open "myfile.txt" "r+"]
# seek $f 7
# set x [read $f 27]
# puts $x
# close $f



# esercizio su global
# set outside "Sono globale!"
# set inside "Non sono globale!"
# 
# proc main {inside} {
# 	global outside
# 	puts $inside
# 	puts $outside
# }
# 
# main $inside



# esercizio su fibonacci
# proc fib {n} {
#
# 	if { $n <= 2} {return 1}
#
# 	return [ expr [fib [ expr $n -1] ] + [fib [ expr $n -2] ] ]
# }
#
# for {set i 1 } { $i < 20 } {incr i} {
# 	puts " Fib($i) = [fib $i]"
# }



# esercizio sulle liste 	
# set A { a b c d e f g h }
# set i [llength $A]
# set B ""
#
# while { $i > 0 } {
# 	lappend B [lindex $A $i]
#	incr i -1
# }
# puts $A
# puts $B
	
