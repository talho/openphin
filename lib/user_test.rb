class UserTest
  def self.validate_all
    User.all.each do |user|
      UserTest.validate(user)
    end
    ""
  end

  def self.validate(user)
    unless user.valid?
      puts "##{user.id}: #{user.display_name} - #{user.email}"
      user.errors.full_messages.each do |msg|
        puts msg
      end
      puts ""
    end
  end

  def self.validate_role_requests(user = nil)
    if user
      user.role_requests.each do |role_request|
        unless role_request.valid?
          puts "#{role_request.id}: #{role_request.jurisdiction} - #{role_request.role}"
          role_request.errors.full_messages.each do |msg|
            puts msg
          end
        end
      end
    end
    puts ""
  end
end