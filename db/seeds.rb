admin = User.find_or_initialize_by(email: "admin@raizes.local")
admin.update!(
  name: "Administrador Raizes",
  password: "password123",
  password_confirmation: "password123",
  role: "admin",
  consent_at: Time.current
)

cliente = User.find_or_initialize_by(email: "cliente@raizes.local")
cliente.update!(
  name: "Cliente Demo",
  password: "password123",
  password_confirmation: "password123",
  role: "cliente",
  consent_at: Time.current
)

unit = Unit.find_or_create_by!(name: "Raizes Centro", city: "Recife", state: "PE")

products = [
  [ "Baiao Burger", "Hamburguer artesanal com inspiracao nordestina.", 2490 ],
  [ "Cuscuz Bowl", "Cuscuz com queijo coalho e carne de sol.", 1990 ],
  [ "Suco de Caja", "Suco natural de caja.", 790 ]
].map do |name, description, price_cents|
  Product.find_or_create_by!(name: name) do |product|
    product.description = description
    product.price_cents = price_cents
    product.active = true
  end
end

products.each do |product|
  Stock.find_or_create_by!(unit: unit, product: product) do |stock|
    stock.quantity = 50
  end
end

puts "Seed concluido:"
puts "- admin@raizes.local / password123"
puts "- cliente@raizes.local / password123"
puts "- unidade #{unit.id}: #{unit.name}"
