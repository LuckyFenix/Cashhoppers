# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Role.all.each do |role|
  role.destroy
end

User.where(:email => 'admin@cash.com').first.destroy

Role.create(:name => :admin)
Role.create(:name => :user)

admin = User.create(:email => 'admin@cash.com', :password => 'qwerty11', :password_confirmation => 'qwerty11')
admin.roles = [Role.find_by_name(:admin)]