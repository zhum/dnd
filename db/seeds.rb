

Service.import_weapon
Service.import_armor
Service.import_things
Service.create_skills
a = Service.create_adventure

u = User.create(
  name: 'First Master',
  email: 'fmaster@dnd.world',
  password: '123123',
  active: true,
  secret: SecureRandom.alphanumeric(32)
)
u.save

p = Player.create(
  user: u,
  name: 'God of Преключениэ',
  adventure: a
  )
p.save