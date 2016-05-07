desc 'Make the last user (or a specified user) an admin'
task set_admin_role: :environment do
  u = ENV['EMAIL'] ? User.where(email: ENV['EMAIL']).first : User.last
  puts "Making user #{u} an admin"
  u.role = 'admin'
  u.save
end
