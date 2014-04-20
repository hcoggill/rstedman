require 'rspec'
require_relative 'stedman'

include Stedman

describe Touch do
  context 'Plain course' do 
    before :each do
      @touch = Touch.new(11)
      @touch.go
      @touch.is_true?
    end
  
    it 'should be true' do
      @touch.is_true?().should == true
    end

    it 'should have 11 bells' do
      @touch.num_bells.should == 11
    end
  
    it 'should start with 213547698EO' do
      @touch.stringify(@touch.rows.first).should == '213547698E0'
    end
  
    it 'should end with rounds' do
      @touch.stringify(@touch.rows.last).should == '1234567890E'
      @touch.rounds?().should == true
    end
  
    it 'should contain 132 rows' do
      @touch.rows.length.should == 6 * 11 * 2
    end

    it 'should contain 1 course (22 sixes)' do
      @touch.courses.length.should == 1
      @touch.courses.first.should == 22
    end

    it 'should display a nice composition string' do
      @touch.comp_string.should == " (22)"
    end

  end
  
  context 'Short touch' do
    before :each do
      @touch = Touch.new(11)
      @touch.set_comp "1.5.6.s9.12.14.15.16.17.18.19 (20) [a]\na"
      @touch.go
      @touch.is_true?
    end
  
    it 'should be true' do
      @touch.is_true?().should == true
    end
 
    it 'should end in rounds' do
      @touch.rounds?().should == true
    end
 
    it 'should contain 240 rows' do
      @touch.rows.length.should == 6 * 20 * 2
    end

    it 'should contain 2 courses (20 sixes)' do
      @touch.courses.length.should == 2
      @touch.courses.each do |course|
        course.should == 20
       end
    end

    it 'should display a nice composition string' do
      @touch.comp_string.should == "1.5.6.s9.12.14.15.16.17.18.19 (20)\n1.5.6.s9.12.14.15.16.17.18.19 (20)"
    end

    it 'should have the right composition internally' do
      @touch.comp.should == [1, 0, 0, 0, 1, 1, 0, 0, 2, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0] * 2
    end

  end

  context 'Another short touch' do
    before :each do
      @touch = Touch.new(11)
      @touch.set_comp "1.3.5s.6.8.10.11.13.14.16.18.19.20 (20)\n2.3.5.6.8.10s.13s.14.17.19.22.25 (27)" # 279
      @touch.go
      @touch.is_true?
    end
  
    it 'should be true' do
      @touch.is_true?().should == true
    end
 
    it 'should end in rounds' do
      @touch.rounds?().should == true
    end
 
    it 'should contain 279 rows' do
      @touch.rows.length.should == 279
    end

    it 'should contain 2 courses (20/27 sixes)' do
      @touch.courses.should == [20, 27]
    end

    it 'should display a nice composition string' do
      @touch.comp_string.should == "1.3.s5.6.8.10.11.13.14.16.18.19.20 (20)\n2.3.5.6.8.s10.s13.14.17.19.22.25 (27)"
    end

    it 'should have the right composition internally' do
      @touch.comp.should == [1, 0, 1, 0, 2, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 2, 0, 0, 2, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0]
    end

  end

  context 'False touch (plain)' do
    before :each do
      @touch = Touch.new(11)
      @touch.set_comp '(23)'
      @touch.go
      @touch.is_true?
    end

    it 'should be false' do
      @touch.is_true?().should == false
    end

    it 'should be 23 sixes' do
      @touch.courses.should == [23]
    end

    it 'should have 8 false rows' do
      @touch.false_rows.length.should == 8
    end

    it 'should not end in rounds' do
      @touch.rounds?().should == false
    end

    it 'should display a nice composition string' do
      @touch.comp_string.should == " (23)"
    end

  end

  context 'Another short touch' do
    before :each do
      @touch = Touch.new(11)
      @touch.set_comp "1.4.5.6.7.s9.s16.18\n4.5.6.7.s10.13.14.s16.17.19.22"
      @touch.go
      @touch.is_true?
    end
  
    it 'should be true' do
      @touch.is_true?().should == true
    end
 
    it 'should end in rounds' do
      @touch.rounds?().should == true
    end
 
    it 'should contain 264 rows' do
      @touch.rows.length.should == 264
    end

    it 'should contain 2 courses (22 sixes)' do
      @touch.courses.length.should == 2
      @touch.courses.each do |course|
        course.should == 22
       end
    end

    it 'should display a nice composition string' do
      @touch.comp_string.should == "1.4.5.6.7.s9.s16.18\n4.5.6.7.s10.13.14.s16.17.19.22"
    end

  end

  context 'Changing touches' do
    before :each do
      @touch = Touch.new(11)
      @touch.go
      @touch.is_true?
    end

    it 'should have a plain course' do
      comp = @touch.comp
      comp.should == [PLAIN] * 22
    end

    it 'should add another course' do
      comp = @touch.comp_string
      @touch.set_comp comp + "\n (22)"
      @touch.go
      @touch.comp.should == [PLAIN] * 44
    end

    it 'should add another course native stylee' do
      @touch.comp.should == [PLAIN] * 22
      @touch.add_course
      @touch.go
      @touch.comp.should == [PLAIN] * 44
    end

    it 'should add several courses' do
      20.times do 
        @touch.add_course
      end
      @touch.comp.should == [PLAIN] * 462
    end

    it 'should add and remove courses' do
      @touch.add_course
      @touch.comp.should == [PLAIN] * 44
      @touch.remove_course
      @touch.comp.should == [PLAIN] * 22
    end

    it 'should add and remove variable length courses' do
      @touch.set_comp @touch.comp_string + "\n1.2.3.4.5 (18)"
      @touch.comp.should == [PLAIN] * 22 + [BOB] * 5 + [PLAIN] * 13
      @touch.remove_course
      @touch.comp.should == [PLAIN] * 22
    end

    it 'should remove a course from a non-standard composition' do
      @touch.set_comp "5.7.8.10.11.s13.15.16 (20)\ns1.9.10.s13.15.16.s22\ns13.s15.18.s22\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18\n3.4.s12.17.18 (23)"
      @touch.remove_course
      @touch.comp_string.should == "5.7.8.10.11.s13.15.16 (20)\ns1.9.10.s13.15.16.s22\ns13.s15.18.s22\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18"
    end

    it 'should set a simple course' do
      @touch.set_course(0, [BOB] * 5)
      @touch.comp.should == [BOB] * 5
      @touch.comp_string.should == "1.2.3.4.5 (5)"
    end

    it 'should set a more complex course' do
      @touch.set_comp "5.7.8.10.11.s13.15.16 (20)\ns1.9.10.s13.15.16.s22\ns13.s15.18.s22\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18\n3.4.s12.17.18 (23)"
      @touch.set_course(0, [PLAIN] * 10 + [BOB] * 2 + [PLAIN] * 10)
      @touch.comp_string.should == "11.12\ns1.9.10.s13.15.16.s22\ns13.s15.18.s22\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18\n3.4.s12.17.18 (23)"
      @touch.set_course(44, [BOB] * 20) # out of bounds, should do nothing
      @touch.comp_string.should == "11.12\ns1.9.10.s13.15.16.s22\ns13.s15.18.s22\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18\n3.4.s12.17.18 (23)"
      @touch.set_course(2, [PLAIN] * 21 + [SINGLE] + [BOB])
      @touch.comp_string.should == "11.12\ns1.9.10.s13.15.16.s22\ns22.23 (23)\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18\n3.4.s12.17.18 (23)"
      @touch.set_course(10, [SINGLE] * 22) # again nothing
      @touch.comp_string.should == "11.12\ns1.9.10.s13.15.16.s22\ns22.23 (23)\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18\n3.4.s12.17.18 (23)"
      @touch.set_course(9, [PLAIN, PLAIN, BOB, PLAIN, BOB] + [PLAIN] * 18)
      @touch.comp_string.should == "11.12\ns1.9.10.s13.15.16.s22\ns22.23 (23)\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18\n3.5 (23)"
    end

    it 'should construct a touch from the basics' do
      @touch.comp.should == [PLAIN] * 22
      reps = 10
      reps.times do |i|
        @touch.set_course(i, [BOB] + [PLAIN] * 21)
	@touch.add_course if i < reps - 1
      end
      @touch.set_course(reps, [BOB] + [PLAIN] * 21)
      @touch.go
      @touch.comp.should == ([BOB] + [PLAIN] * 21) * reps
      @touch.comp_string.should == (["1"] * reps).join("\n")
    end

  end
  
  context 'Selecting courses' do
    before :each do
      @touch = Touch.new(11)
      @touch.go
      @touch.is_true?
    end

    it 'should select the plain course' do
      rows = @touch.rows
      rows.length.should == 132
      course = @touch.course_rows 0
      course.length.should == 132
      course.should == rows
    end

    it 'should select courses for a short touch' do
      @touch.set_comp "1.5.6.s9.12.14.15.16.17.18.19 (20)\n1.5.6.s9.12.14.15.16.17.18.19 (20)"
      @touch.go
      first_course = @touch.course_rows 0
      second_course = @touch.course_rows 1
      first_course.length.should == 122
      second_course.length.should == 118
      first_course.first.should == [2, 1, 3, 5, 4, 7, 6, 9, 8, 11, 10]
      first_course.last.should == [5, 4, 6, 3, 2, 1, 7, 8, 9, 10, 11]
      second_course.first.should == [4, 5, 3,6, 1, 2, 8, 7, 9, 11, 10]
      second_course.last.should == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
      
    end

    it 'should contain the correct calls for a plain course' do
      @touch.courses.should == [22]
      @touch.course_comp(0).should == [PLAIN] * 22
    end

    it 'should contain the correct calls for a QP composition' do
      @touch.set_comp "5.7.8.10.11.s13.15.16 (20)\ns1.9.10.s13.15.16.s22\ns13.s15.18.s22\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18\n3.4.s12.17.18 (23)"
      @touch.go
      @touch.course_comp(0).should == [0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 2, 0, 1, 1, 0, 0, 0, 0]
      @touch.course_comp(1).should == [2, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 2, 0, 1, 1, 0, 0, 0, 0, 0, 2]
      @touch.course_comp(2).should == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 2, 0, 0, 1, 0, 0, 0, 2]
      @touch.course_comp(3).should == [1, 0, 0, 0, 0, 0, 2, 0, 2, 0, 0, 0, 2, 0, 2, 0, 0, 1, 0, 0, 0, 2]
      @touch.course_comp(4).should == [0, 0, 2, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      @touch.course_comp(5).should == [0, 1, 2, 0, 0, 0, 0, 0, 2, 0, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0]
      @touch.course_comp(6).should == [0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 2, 0, 2, 0, 0, 0]
      @touch.course_comp(7).should == [0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0]
      @touch.course_comp(8).should == [0, 0, 1, 1, 0, 0, 2, 0, 2, 0, 0, 2, 0, 0, 0, 0, 2, 1, 0, 0, 0, 0]
      @touch.course_comp(9).should == [0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0]
    end

  end

  context 'Repeated operations' do

    before :each do
      @touch = Touch.new(11)
      @touch.go
      @touch.is_true?
    end

    it 'should go again and again' do
      @touch.set_comp "5.7.8.10.11.s13.15.16 (20)\ns1.9.10.s13.15.16.s22\ns13.s15.18.s22\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18\n3.4.s12.17.18 (23)"
      @touch.go
      orig_rows = @touch.rows
      @touch.is_true?().should == true
      @touch.rows.length.should == 1313
      3.times do
        @touch.go
	@touch.rounds?().should == true
	@touch.is_true?().should == true
	@touch.rows.should == orig_rows
	@touch.rows.length.should == 1313
      end
    end

  end     

  context 'A selection of short touches' do

    before :each do
      @touch = Touch.new(11)
    end
    
    it 'has 279 changes' do
      # compositions.wikidot.com/stedman-cinques-touches
      @touch.set_comp "1.3.5s.6.8.10.11.13.14.16.18.19.20 (20)\n2.3.5.6.8.10s.13s.14.17.19.22.25 (27)" # 279
      @touch.go
      @touch.rows.length.should == 279
      @touch.magic_rows.length.should == 5
    end

    it 'has 303 changes' do
      # compositions.wikidot.com/stedman-cinques-touches
      @touch.set_comp "1s.3s.4.7s.8.10.12s.13.15.16.20.23 (26)\n2.3.4.5.6.8.11.14.15.16.19.23s (25)" # 303
      @touch.go
      @touch.rows.length.should == 303
      @touch.magic_rows.length.should == 5
    end

    it 'has 252 changes' do
      # Grimmet from change-ringers list
      @touch.set_comp "1,5-6,s9,12,14-19 (20)\n5-6,8-9,s11,20-21 (22)" # 252
      @touch.go
      @touch.rows.length.should == 252
      @touch.magic_rows.length.should == 2
    end

    it 'has 240 changes' do
      # richard j angrave
      @touch.set_comp "1.5.6.s9.12.14.15.16.17.18.19 (20) [a]\na"
      @touch.go
      @touch.rows.length.should == 240
      @touch.magic_rows.length.should == 2
    end

    it 'has 257 changes' do
      # callingsapp touch
      @touch.set_comp "1.5.s8.10.11.13.14.15.16 (20)\n2.s13.s15 (23)" # 257
      @touch.go
      @touch.rows.length.should == 257
      @touch.magic_rows.length.should == 3
    end

    it 'has 300 changes' do
      # lucy woodward
      @touch.set_comp "1.s4.6.8.9.11.13.19.21.22.23.24 (24)\n2.3.5.s7.9.10.14.21.25 (26)" # 300 ljw
      @touch.go
      @touch.rows.length.should == 300
      @touch.magic_rows.length.should == 2
    end

    it 'has 300 changes also' do
      # lucy woodward
      @touch.set_comp "1.s4.5.7.9.10.12.s14.15.18 (18)\n1.2.s5.7.8.10 (10)\n1.s2.s6.s8.10.s12.s14.15.18.s20.s22" # 300 ljw
      @touch.go
      @touch.rows.length.should == 300
      @touch.magic_rows.length.should == 2
    end
    
    after :each do
      @touch.is_true?().should == true
      @touch.rounds?().should == true
    end

  end
 
end


