require 'rspec'

require 'simplecov'
SimpleCov.start

require 'stedman'

include Stedman

describe Touch do
  context 'Plain course' do 
    before :each do
      @touch = Touch.new(11)
      @touch.go
      @touch.is_true?
    end
  
    it 'should be true' do
      expect(@touch.is_true?()).to eq(true)
    end

    it 'should have 11 bells' do
      expect(@touch.num_bells).to eq(11)
    end
  
    it 'should start with 213547698EO' do
      expect(@touch.stringify(@touch.rows.first)).to eq('213547698E0')
    end
  
    it 'should end with rounds' do
      expect(@touch.stringify(@touch.rows.last)).to eq('1234567890E')
      expect(@touch.rounds?()).to eq(true)
    end
  
    it 'should contain 132 rows' do
      expect(@touch.rows.length).to eq(6 * 11 * 2)
    end

    it 'should contain 1 course (22 sixes)' do
      expect(@touch.courses.length).to eq(1)
      expect(@touch.courses.first).to eq(22)
    end

    it 'should display a nice composition string' do
      expect(@touch.comp_string).to eq(" (22)")
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
      expect(@touch.is_true?()).to eq(true)
    end
 
    it 'should end in rounds' do
      expect(@touch.rounds?()).to eq(true)
    end
 
    it 'should contain 240 rows' do
      expect(@touch.rows.length).to eq(6 * 20 * 2)
    end

    it 'should contain 2 courses (20 sixes)' do
      expect(@touch.courses.length).to eq(2)
      @touch.courses.each do |course|
        expect(course).to eq(20)
       end
    end

    it 'should display a nice composition string' do
      expect(@touch.comp_string).to eq("1.5.6.s9.12.14.15.16.17.18.19 (20)\n1.5.6.s9.12.14.15.16.17.18.19 (20)")
    end

    it 'should have the right composition internally' do
      expect(@touch.comp).to eq([1, 0, 0, 0, 1, 1, 0, 0, 2, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0] * 2)
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
      expect(@touch.is_true?()).to eq(true)
    end
 
    it 'should end in rounds' do
      expect(@touch.rounds?()).to eq(true)
    end
 
    it 'should contain 279 rows' do
      expect(@touch.rows.length).to eq(279)
    end

    it 'should contain 2 courses (20/27 sixes)' do
      expect(@touch.courses).to eq([20, 27])
    end

    it 'should display a nice composition string' do
      expect(@touch.comp_string).to eq("1.3.s5.6.8.10.11.13.14.16.18.19.20 (20)\n2.3.5.6.8.s10.s13.14.17.19.22.25 (27)")
    end

    it 'should have the right composition internally' do
      expect(@touch.comp).to eq([1, 0, 1, 0, 2, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 2, 0, 0, 2, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0])
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
      expect(@touch.is_true?()).to eq(false)
    end

    it 'should be 23 sixes' do
      expect(@touch.courses).to eq([23])
    end

    it 'should have 8 false rows' do
      expect(@touch.false_rows.length).to eq(8)
    end

    it 'should not end in rounds' do
      expect(@touch.rounds?()).to eq(false)
    end

    it 'should display a nice composition string' do
      expect(@touch.comp_string).to eq(" (23)")
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
      expect(@touch.is_true?()).to eq(true)
    end
 
    it 'should end in rounds' do
      expect(@touch.rounds?()).to eq(true)
    end
 
    it 'should contain 264 rows' do
      expect(@touch.rows.length).to eq(264)
    end

    it 'should contain 2 courses (22 sixes)' do
      expect(@touch.courses.length).to eq(2)
      @touch.courses.each do |course|
        expect(course).to eq(22)
       end
    end

    it 'should display a nice composition string' do
      expect(@touch.comp_string).to eq("1.4.5.6.7.s9.s16.18\n4.5.6.7.s10.13.14.s16.17.19.22")
    end

    it 'should handle unknown characters in composition string' do
      @touch.set_comp "1.4.5.6.7.e.s9.s16.18\n4.5.6.7.s10.13.14.s16.17.19.22"
      expect(@touch.comp_string).to eq("1.4.5.6.7.s9.s16.18\n4.5.6.7.s10.13.14.s16.17.19.22")
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
      expect(comp).to eq([PLAIN] * 22)
    end

    it 'should add another course' do
      comp = @touch.comp_string
      @touch.set_comp comp + "\n (22)"
      @touch.go
      expect(@touch.comp).to eq([PLAIN] * 44)
    end

    it 'should add another course native stylee' do
      expect(@touch.comp).to eq([PLAIN] * 22)
      @touch.add_course
      @touch.go
      expect(@touch.comp).to eq([PLAIN] * 44)
    end

    it 'should add several courses' do
      20.times do 
        @touch.add_course
      end
      expect(@touch.comp).to eq([PLAIN] * 462)
    end

    it 'should add and remove courses' do
      @touch.add_course
      expect(@touch.comp).to eq([PLAIN] * 44)
      @touch.remove_course
      expect(@touch.comp).to eq([PLAIN] * 22)
    end

    it 'should add and remove variable length courses' do
      @touch.set_comp @touch.comp_string + "\n1.2.3.4.5 (18)"
      expect(@touch.comp).to eq([PLAIN] * 22 + [BOB] * 5 + [PLAIN] * 13)
      @touch.remove_course
      expect(@touch.comp).to eq([PLAIN] * 22)
    end

    it 'should remove a course from a non-standard composition' do
      @touch.set_comp "5.7.8.10.11.s13.15.16 (20)\ns1.9.10.s13.15.16.s22\ns13.s15.18.s22\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18\n3.4.s12.17.18 (23)"
      @touch.remove_course
      expect(@touch.comp_string).to eq("5.7.8.10.11.s13.15.16 (20)\ns1.9.10.s13.15.16.s22\ns13.s15.18.s22\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18")
    end

    it 'should set a simple course' do
      @touch.set_course(0, [BOB] * 5)
      expect(@touch.comp).to eq([BOB] * 5)
      expect(@touch.comp_string).to eq("1.2.3.4.5 (5)")
    end

    it 'should set a more complex course' do
      @touch.set_comp "5.7.8.10.11.s13.15.16 (20)\ns1.9.10.s13.15.16.s22\ns13.s15.18.s22\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18\n3.4.s12.17.18 (23)"
      @touch.set_course(0, [PLAIN] * 10 + [BOB] * 2 + [PLAIN] * 10)
      expect(@touch.comp_string).to eq("11.12\ns1.9.10.s13.15.16.s22\ns13.s15.18.s22\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18\n3.4.s12.17.18 (23)")
      @touch.set_course(44, [BOB] * 20) # out of bounds, should do nothing
      expect(@touch.comp_string).to eq("11.12\ns1.9.10.s13.15.16.s22\ns13.s15.18.s22\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18\n3.4.s12.17.18 (23)")
      @touch.set_course(2, [PLAIN] * 21 + [SINGLE] + [BOB])
      expect(@touch.comp_string).to eq("11.12\ns1.9.10.s13.15.16.s22\ns22.23 (23)\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18\n3.4.s12.17.18 (23)")
      @touch.set_course(10, [SINGLE] * 22) # again nothing
      expect(@touch.comp_string).to eq("11.12\ns1.9.10.s13.15.16.s22\ns22.23 (23)\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18\n3.4.s12.17.18 (23)")
      @touch.set_course(9, [PLAIN, PLAIN, BOB, PLAIN, BOB] + [PLAIN] * 18)
      expect(@touch.comp_string).to eq("11.12\ns1.9.10.s13.15.16.s22\ns22.23 (23)\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18\n3.5 (23)")
    end

    it 'should construct a touch from the basics' do
      expect(@touch.comp).to eq([PLAIN] * 22)
      reps = 10
      reps.times do |i|
        @touch.set_course(i, [BOB] + [PLAIN] * 21)
	@touch.add_course if i < reps - 1
      end
      @touch.set_course(reps, [BOB] + [PLAIN] * 21)
      @touch.go
      expect(@touch.comp).to eq(([BOB] + [PLAIN] * 21) * reps)
      expect(@touch.comp_string).to eq((["1"] * reps).join("\n"))
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
      expect(rows.length).to eq(132)
      course = @touch.course_rows 0
      expect(course.length).to eq(132)
      expect(course).to eq(rows)
    end

    it 'should select courses for a short touch' do
      @touch.set_comp "1.5.6.s9.12.14.15.16.17.18.19 (20)\n1.5.6.s9.12.14.15.16.17.18.19 (20)"
      @touch.go
      first_course = @touch.course_rows 0
      second_course = @touch.course_rows 1
      expect(first_course.length).to eq(122)
      expect(second_course.length).to eq(118)
      expect(first_course.first).to eq([2, 1, 3, 5, 4, 7, 6, 9, 8, 11, 10])
      expect(first_course.last).to eq([5, 4, 6, 3, 2, 1, 7, 8, 9, 10, 11])
      expect(second_course.first).to eq([4, 5, 3,6, 1, 2, 8, 7, 9, 11, 10])
      expect(second_course.last).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
    end

    it 'should select courses for non-standard starting posisions with plain course' do
      2.times do |six_type|
        6.times do |starting_offset|
          t = Touch.new(11, six_type, starting_offset)
          t.go
          expect(t.courses).to eq([22])
          first_course = t.course_rows 0
          expect(first_course).to eq(t.rows)
        end
      end
    end

    it 'should select courses for non-standard starting posisions with touch' do
      t = Touch.new(11, SLOW, 0)
      t.set_comp "5.18 (21)\ns19\n6.19\ns19\n6\n6 [AAAAA]\n6.19\nA\n2.6.s10.s15.19\ns19\n6.19\ns19\n6\n6\n6.19\nA\n6.19\nA\ns1.2.6.s15.19\ns19\n6.19\ns19\n6.s19\ns19\n6.s19\ns19\n (1)"
      t.go
      expect(t.courses).to eq([21, [22] * 37, 1].flatten)
      first_course = t.course_rows 0
      expect(first_course).to eq(t.rows[0, 131])
      expect(t.course_rows(38).last).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
    end

    it 'should contain the correct calls for a plain course' do
      expect(@touch.courses).to eq([22])
      expect(@touch.course_comp(0)).to eq([PLAIN] * 22)
    end

    it 'should contain the correct calls for a QP composition' do
      @touch.set_comp "5.7.8.10.11.s13.15.16 (20)\ns1.9.10.s13.15.16.s22\ns13.s15.18.s22\n1.s7.s9.s13.s15.18.s22\ns3.6.7.12\n2.s3.s9.12.s15\n3.4.12.s17.s19\n3.4.12.16.17.18\n3.4.s7.s9.s12.s17.18\n3.4.s12.17.18 (23)"
      @touch.go
      expect(@touch.course_comp(0)).to eq([0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 2, 0, 1, 1, 0, 0, 0, 0])
      expect(@touch.course_comp(1)).to eq([2, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 2, 0, 1, 1, 0, 0, 0, 0, 0, 2])
      expect(@touch.course_comp(2)).to eq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 2, 0, 0, 1, 0, 0, 0, 2])
      expect(@touch.course_comp(3)).to eq([1, 0, 0, 0, 0, 0, 2, 0, 2, 0, 0, 0, 2, 0, 2, 0, 0, 1, 0, 0, 0, 2])
      expect(@touch.course_comp(4)).to eq([0, 0, 2, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
      expect(@touch.course_comp(5)).to eq([0, 1, 2, 0, 0, 0, 0, 0, 2, 0, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0])
      expect(@touch.course_comp(6)).to eq([0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 2, 0, 2, 0, 0, 0])
      expect(@touch.course_comp(7)).to eq([0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0])
      expect(@touch.course_comp(8)).to eq([0, 0, 1, 1, 0, 0, 2, 0, 2, 0, 0, 2, 0, 0, 0, 0, 2, 1, 0, 0, 0, 0])
      expect(@touch.course_comp(9)).to eq([0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0])
    end

    it 'should select the correct six ends for a plain course' do
      six_ends = @touch.six_ends()
      expect(six_ends.length).to eq(22)
    end

    it 'should select the correct six ends for any start and type' do
      2.times do |six_type|
        6.times do |offset|
          t = Touch.new(11, six_type, offset)
          t.go
          expect(t.is_true?).to eq(true)
          expect(t.six_ends().length).to eq(22)
          expect(t.six_ends(0)).to eq(t.six_ends())

          ends = []
          previous = nil
          idx = 0
          t.rows.each_with_index do |row, i|
            unless previous.nil?
              if row.last == previous.last
                idx = i - 1
                break
              end
            end
            previous = row
          end
          t.rows.each_with_index do |row, i|
            if i % 6 == idx
              ends << row
            end
          end
          expect(t.six_ends(0)).to eq(ends)
        end
      end

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
      expect(@touch.is_true?()).to eq(true)
      expect(@touch.rows.length).to eq(1313)
      3.times do
        @touch.go
	expect(@touch.rounds?()).to eq(true)
	expect(@touch.is_true?()).to eq(true)
	expect(@touch.rows).to eq(orig_rows)
	expect(@touch.rows.length).to eq(1313)
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
      expect(@touch.rows.length).to eq(279)
      expect(@touch.magic_rows.length).to eq(5)
    end

    it 'has 303 changes' do
      # compositions.wikidot.com/stedman-cinques-touches
      @touch.set_comp "1s.3s.4.7s.8.10.12s.13.15.16.20.23 (26)\n2.3.4.5.6.8.11.14.15.16.19.23s (25)" # 303
      @touch.go
      expect(@touch.rows.length).to eq(303)
      expect(@touch.magic_rows.length).to eq(5)
    end

    it 'has 252 changes' do
      # Grimmet from change-ringers list
      @touch.set_comp "1,5-6,s9,12,14-19 (20)\n5-6,8-9,s11,20-21 (22)" # 252
      @touch.go
      expect(@touch.rows.length).to eq(252)
      expect(@touch.magic_rows.length).to eq(2)
    end

    it 'has 240 changes' do
      # richard j angrave
      @touch.set_comp "1.5.6.s9.12.14.15.16.17.18.19 (20) [a]\na"
      @touch.go
      expect(@touch.rows.length).to eq(240)
      expect(@touch.magic_rows.length).to eq(2)
    end

    it 'has 257 changes' do
      # callingsapp touch
      @touch.set_comp "1.5.s8.10.11.13.14.15.16 (20)\n2.s13.s15 (23)" # 257
      @touch.go
      expect(@touch.rows.length).to eq(257)
      expect(@touch.magic_rows.length).to eq(3)
    end

    it 'has 300 changes' do
      # lucy woodward
      @touch.set_comp "1.s4.6.8.9.11.13.19.21.22.23.24 (24)\n2.3.5.s7.9.10.14.21.25 (26)" # 300 ljw
      @touch.go
      expect(@touch.rows.length).to eq(300)
      expect(@touch.magic_rows.length).to eq(2)
    end

    it 'has 300 changes also' do
      # lucy woodward
      @touch.set_comp "1.s4.5.7.9.10.12.s14.15.18 (18)\n1.2.s5.7.8.10 (10)\n1.s2.s6.s8.10.s12.s14.15.18.s20.s22" # 300 ljw
      @touch.go
      expect(@touch.rows.length).to eq(300)
      expect(@touch.magic_rows.length).to eq(2)
    end
    
    after :each do
      expect(@touch.is_true?()).to eq(true)
      expect(@touch.rounds?()).to eq(true)
    end

  end

  context 'Starting at different offsets within a six' do
    
    it 'should by default start at 4th row of a quick six' do
      t = Touch.new(11)
      expect(t.start_offset).to eq(4 - 1)
      expect(t.start_six).to eq(QUICK)
    end

    it 'can start at nth row of either six type' do
      6.times do |i|
        2.times do |s|
          t = Touch.new(11, s, i)
          t.go
          expect(t.start_offset).to eq(i)
          expect(t.start_six).to eq(s)
          expect(t.is_true?()).to eq(true)
          expect(t.num_bells).to eq(11)
          expect(t.stringify(t.rows.last)).to eq('1234567890E')
          expect(t.rounds?()).to eq(true)
          expect(t.rows.length).to eq(6 * 11 * 2)
          expect(t.courses.length).to eq(1)
          expect(t.courses.first).to eq(22)
          expect(t.comp_string).to eq(" (22)")
        end
      end
    end

  end


  context 'Visual layout' do

    it 'has 1 column and 132 rows for a plain course' do
      t = Touch.new(11)
      t.go
      expect(t.num_columns).to eq(1)
      expect(t.num_rows).to eq(132)
    end

    it 'has 2 columns and 132 rows for a short touch' do
      t = Touch.new(11)
      t.set_comp "1,5-6,s9,12,14-19 (20)\n5-6,8-9,s11,20-21 (22)" # 252
      # first course: 20 * 6 + 2 = 122
      # second course: 22 * 6 - 2 = 130
      t.go
      expect(t.num_columns).to eq(2)
      expect(t.num_rows).to eq(132)
      i = 0
      122.times do |j|
        expect(t.visual_course_row(0, j)).to eq(t.stringify t.rows[i])
        i += 1
      end
      expect(t.visual_course_row(1, 0)).to eq("")
      expect(t.visual_course_row(1, 1)).to eq("")
      130.times do |j|
        expect(t.visual_course_row(1, j + 2)).to eq(t.stringify t.rows[i])
        i += 1
      end

    end

  end


  context 'Bits and pieces' do

    it 'has 11 or 12 bells' do
      t = Touch.new(11)
      expect(t.all_bells).to eq(12)
      t = Touch.new(12)
      expect(t.all_bells).to eq(12)
    end

    it 'can print rows' do
      t = Touch.new(11)
      t.go
      expect(t.bell_to_str 12).to eq('T')
      expect(t.printable(t.rows.length - 1, 10)).to eq('E')
    end

    it 'can print call strings' do
      t = Touch.new(11)
      t.set_comp  "1.s4.5.7.9.10.12.s14.15.18 (18)\n1.2.s5.7.8.10 (10)\n1.s2.s6.s8.10.s12.s14.15.18.s20.s22" # 300 ljw
      expect(t.call_string 0).to eq('-')
      expect(t.call_string 1).to eq('')
      expect(t.call_string 3).to eq('s')
    end

  end

end


