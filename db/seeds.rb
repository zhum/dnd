
#warn "ok"
Service.import_weapon
Service.import_armor
Service.import_things
Service.create_skills
Service.create_features
a = Service.create_adventure

u = if User.count==0
	User.create(
	  name: 'First Master',
	  email: 'fmaster@dnd.world',
	  password: '123123',
	  active: true,
	  secret: SecureRandom.alphanumeric(32)
	)
else
	User.first
end
u.save

u2 = if User.count==1
	User.create(
	  name: 'First User',
	  email: 'fuser@dnd.world',
	  password: '123123',
	  active: true,
	  secret: SecureRandom.alphanumeric(32)
	)
else
	User.last
end
u2.save

p = if Player.count==0
  Player.create(
	  user: u,
	  name: 'God of Преключениэ',
	  adventure: a,
	  is_master: true
  )
else
	Player.first
end
warn "master=#{p.inspect}"
p.save

p = if Player.count==1
  Player.create(
	  user: u2,
	  name: 'Вассисуалий Пупкинс',
	  adventure: a,
	  is_master: false
  )
else
	Player.last
end
warn "player=#{p.inspect}"
p.save

