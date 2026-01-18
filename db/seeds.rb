categories = [
  "Zupy",
  "Dania główne",
  "Sałatki",
  "Desery",
  "Śniadania",
  "Przekąski",
  "Napoje"
]

categories.each do |name|
  Category.find_or_create_by!(
    name: name,
    slug: name.parameterize
  )
end

admin_email = "admin@kuchnia.com"
admin_password = "adminadmin"

admin = User.find_or_initialize_by(email: admin_email)
admin.username = "admin"
admin.password = admin_password
admin.password_confirmation = admin_password
admin.role = 1
admin.save!
puts "Admin stworzony/aktualizowany: #{admin.username} / #{admin.email}"

puts "Seed zakończony: #{User.count} użytkowników, #{Category.count} kategorii"
