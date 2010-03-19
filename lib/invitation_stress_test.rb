class InvitationStressTest
  def self.generateLargeCSVFile(name,size = 1000)
    f = File.new(name, "w")
    f.write "name|email\n"
    size.to_i.times {|i|
      f.write "#{nameRand}|#{emailRand}\n"
    }
    f.close
  end

  def InvitationStressTest.nameRand
    "#{generate_random_string} #{generate_random_string}"
  end

  def InvitationStressTest.emailRand
    "#{generate_random_string}@example.com"
  end

  def InvitationStressTest.generate_random_string(length=6)
    length.times.collect { |n| (65 + rand(25)).chr }.join
  end
end