#!/usr/bin/env ruby

require_relative 'stedman.rb'

comprja = "1.5.6.s9.12.14.15.16.17.18.19 (20) [a]\na"

compallton1 = <<EO1
5.7.8.10.11.s13.15.16 (20)
s1.9.10.s13.15.16.s22
s13.s15.18.s22
1.s7.s9.s13.s15.18.s22
s3.6.7.12
2.s3.s9.12.s15
3.4.12.s17.s19
3.4.12.16.17.18
3.4.s7.s9.s12.s17.18
3.4.s12.17.18 (23) 
EO1

compallton2 = <<EO2
1.5.6.s9.12.14-19 (20)
1.2.5.8.13.14.15.16.18.s21
6, 7, s9, 18
s16 18
s16 18
s16 18 [AAA]
s7, s9, 18
A
(1)
EO2

compallton5100 = <<EOT1
1.s2.3.4.6.8.9.10.11.12.13.14.15.17
2.6.s15.19
EOT1

comppnm2 = <<EOF4
s1.2.s6.15.16.19
19
6 s19
6 19
19
19
5.s14.19
19
19
s6
6, s19
2.s6.s13.s15.s19
19
6
6 19
19
6 19
19
19
3.4.9.10.12.13.s15.16.17.s22.s24 (24) [AAAAAAAAAAAAAAAAAAA]
s1.2.6.s15.19
A
EOF4


coaker1 = <<EOF5
5004 Stedman Cinques

Composed by: Stephen A Coaker


 2314567890E  7  9 18 
 32415768        a
 21435678E90     b   
 1324         s     - |
 3412         s     - |
 4231         s     - |
 2413         s  s  - |A
 4321         s     - |
 3142         s     - |
 1234         s     - |
 123456E9780     c
 1234568709E     d
 2143            A   
 214357869E0     e
 21436578E90     f
 1234            A   
 153246E9780     g
 1234658709E     h
 2143            A   
 13579E24680     i
 2314567890E     j   
a = s1.s4.6.7.9.10.17.s18
b = 1.4.5.7.8.9.10.11.13.14.s16 (20)
c = 3.s8.s12.21
d = 1.2.3.s8.s12.21
e = 2.10.11.s15.20
f = s6.s10.13.s15.s17.s19.s22
g = 3.8.10.11.12.20.s21
h = 1.2.3.8.s9.11.s12.20.s21
i = s1.5.6.7.8.9.s11.14.16.17.18.20 (20)
j = 1.2.6.9.10.s15.17.23 (24)
Contains Queens; Tittums; Whittingtons; Double Whittingtons; all 56s; all 65s; 87 80s; all 5678E90; 6 E9780; 5 near misses;

EOF5
compcoaker1 = <<EOF6
s1.s4.6.7.9.10.17.s18
1.4.5.7.8.9.10.11.13.14.s16 (20)
s7 18
s7 18
s7 18
s7 s9 18
s7 18
s7 18
s7 18 [AAAAAAA]
3.s8.s12.21
1.2.3.s8.s12.21
A
2.10.11.s15.20
s6.s10.13.s15.s17.s19.s22
A 
3.8.10.11.12.20.s21
1.2.3.8.s9.11.s12.20.s21
A 
s1.5.6.7.8.9.s11.14.16.17.18.20 (20)
1.2.6.9.10.s15.17.23 (24)
EOF6

wtouch1 = "2s.5.8s.11s.14.16.17.20 (20)\n1.3s.4.6s.12s.13.14.16s.18" # 231
wtouch2 = "1.3.5s.6.8.10.11.13.14.16.18.19.20 (20)\n2.3.5.6.8.10s.13s.14.17.19.22.25 (27)" # 279
wtouch3 = "1s.3s.4.7s.8.10.12s.13.15.16.20.23 (26)\n2.3.4.5.6.8.11.14.15.16.19.23s (24)" # 303

grimmet1 = "1,5-6,s9,12,14-19 (20)\n5-6,8-9,s11,20-21 (22)" # 252


include Stedman
puts 'Prog'
#touch = Touch.new(11)
touch = Touch.new(11)
##, SLOW, 0)
#m = MusicGen.new(11)
#pp m.named_changes

#touch.set_comp comprja
#touch.set_comp compallton2
#touch.set_comp compcoaker1
touch.set_comp comppnm2
##touch.set_comp("(22)\n(1)")

#touch.set_comp "1.4.5.6.7.s9.s16.18\n4.5.6.7.s10.13.14.s16.17.19.22"

#touch.set_comp "1.5.6.s9.12.14.15.16.17.18.19 (20)\n1.5.6.s9.12.14.15.16.17.18.19 (20)"

#touch.set_comp "s1.s4.6.7.9.10.17.s18\n1.4.5.7.8.9.10.11.13.14.s16 (20)"
#touch.set_comp compallton5100
#touch.set_comp compallton1
#touch.set_comp wtouch2

puts "Starting to ring"
touch.go
puts "Starting to prove"
puts touch.false_rows
#touch.is_true?
#puts "Touch has #{touch.rows.size} rows and is #{touch.is_true?} #{touch.rounds? ? "" : "but does not end in rounds!"}"
#puts "Comp has #{touch.comp.length} sixes"
#puts "(total #{touch.courses.inject(:+)})"
exit

## DISPLAY THE TOUCH IN VARIOUS WAYS:::

puts touch.comp_string
puts touch.courses.length
puts touch.false_rows

offset = 4
six = 0
touch.rows.each do |r|
  if offset == 0
    puts '--------'
    puts "Six #{six}"
  end
  puts touch.stringify r
  offset += 1
  if offset == 6
    offset = 0
    six += 1
  end
end

exit
touch.magic_rows.each do |r|
  puts "(#{touch.stringify r})"
end  

puts "*" * 30
touch.six_ends.each {|r| puts r}
exit

puts "*" * 30
touch.six_ends.each {|i| puts i}


exit

puts
puts "." * 30
puts


touch.courses.length.times do |ci|
  touch.course_rows(ci).each do |r|
    puts touch.stringify r
  end
end


puts "Touch has #{touch.courses.length} courses:"
puts
touch.courses.length.times do |c|
  puts "Course #{c + 1}:  #{touch.course_comp c}"
end


