# frozen_string_literal: true

# =============================================================================
# CheckIn Booking — Seeds
# =============================================================================
# Создаёт полный набор демонстрационных данных:
#   • 1 администратор, 3 супервайзора (закрепленных за городами), 5 клиентов
#   • 19 отелей, хостелов и апартаментов в 5 городах с номерами
#   • Бронирования разных статусов
#   • Отзывы с реалистичными текстами
#   • Избранное
# =============================================================================

puts "🌱 Очистка базы данных..."
[Notification, Review, Booking, Favorite, Room, Hotel, Property, User].each(&:delete_all)

# ---------------------------------------------------------------------------
# 1. Пользователи
# ---------------------------------------------------------------------------
puts "👤 Создание пользователей..."

admin = User.create!(
  email: 'admin@checqin.ru',
  password: 'password123',
  password_confirmation: 'password123',
  role: 'admin',
  first_name: 'Админ',
  last_name: 'Системный',
  phone: '+7 900 000-00-01'
)

supervisors = []
[
  { email: 'manager1@checqin.ru', first: 'Алексей', last: 'Петров', phone: '+7 901 111-11-11', city: 'Москва' },
  { email: 'manager2@checqin.ru', first: 'Мария',  last: 'Иванова', phone: '+7 902 222-22-22', city: 'Санкт-Петербург' },
  { email: 'manager3@checqin.ru', first: 'Дмитрий', last: 'Козлов', phone: '+7 903 333-33-33', city: 'Сочи' }
].each do |s|
  supervisors << User.create!(
    email: s[:email], password: 'password123', password_confirmation: 'password123',
    role: 'supervisor', first_name: s[:first], last_name: s[:last], phone: s[:phone], city: s[:city]
  )
end

clients = []
[
  { email: 'user1@mail.ru',  first: 'Иван',    last: 'Сидоров',   phone: '+7 910 100-10-01' },
  { email: 'user2@mail.ru',  first: 'Елена',   last: 'Кузнецова', phone: '+7 910 200-20-02' },
  { email: 'user3@mail.ru',  first: 'Артём',   last: 'Новиков',   phone: '+7 910 300-30-03' },
  { email: 'user4@mail.ru',  first: 'Ольга',   last: 'Морозова',  phone: '+7 910 400-40-04' },
  { email: 'user5@gmail.com', first: 'Николай', last: 'Волков',    phone: '+7 910 500-50-05' }
].each do |c|
  clients << User.create!(
    email: c[:email], password: 'password123', password_confirmation: 'password123',
    role: 'user', first_name: c[:first], last_name: c[:last], phone: c[:phone]
  )
end

puts "   ✅ #{User.count} пользователей создано"

# ---------------------------------------------------------------------------
# 2. Отели и Хостелы
# ---------------------------------------------------------------------------
puts "🏨 Создание отелей и хостелов..."

hotel_data = [
  # Москва
  {
    name: 'Grand Palace Moscow', hotel_type: 'Отель', city: 'Москва',
    address: 'ул. Тверская, 15', description: 'Роскошный пятизвёздочный отель в самом сердце столицы. Идеальное расположение для деловых и туристических поездок.',
    rating: 4.8, chain: 'Grand Palace', user: supervisors[0],
    base_price_per_night: 8500, available_from: Date.today, available_to: Date.today + 6.months,
    image_url: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=1200&q=80',
    rooms: [
      { name: 'Стандарт 101', room_type: 'Стандарт', capacity: 2, area: 22, price: 5500, image_url: 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=800&q=80' },
      { name: 'Люкс 201', room_type: 'Люкс', capacity: 2, area: 45, price: 12000, image_url: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=800&q=80' }
    ]
  },
  {
    name: 'Апарт-отель Центральный', hotel_type: 'Апарт-отель', city: 'Москва',
    address: 'ул. Арбат, 25', description: 'Стильные апартаменты в историческом центре Москвы с полностью оборудованной кухней.',
    rating: 4.2, chain: nil, user: supervisors[0],
    base_price_per_night: 4000, available_from: Date.today, available_to: Date.today + 6.months,
    image_url: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=1200&q=80',
    rooms: [
      { name: 'Студия A1', room_type: 'Студия', capacity: 2, area: 28, price: 3500, image_url: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=800&q=80' },
      { name: 'Апартаменты B1', room_type: 'Люкс', capacity: 3, area: 50, price: 6500, image_url: 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=800&q=80' }
    ]
  },
  {
    name: 'Boutique Hotel Arbat', hotel_type: 'Отель', city: 'Москва',
    address: 'ул. Новый Арбат, 12', description: 'Бутик-отель с уникальным дизайнерским оформлением номеров и высоким уровнем сервиса.',
    rating: 4.7, chain: nil, user: supervisors[0],
    base_price_per_night: 7500, available_from: Date.today, available_to: Date.today + 6.months,
    image_url: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80',
    rooms: [
      { name: 'Дизайнерский люкс', room_type: 'Люкс', capacity: 2, area: 38, price: 9000, image_url: 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=800&q=80' },
      { name: 'Стандарт Арт', room_type: 'Стандарт', capacity: 2, area: 22, price: 6000, image_url: 'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=800&q=80' }
    ]
  },
  {
    name: 'Hostel Moscow Kremlin', hotel_type: 'Хостел', city: 'Москва',
    address: 'пер. Газетный, 4', description: 'Недорогой и чистый хостел прямо возле Кремля. Бесплатный чай, кофе и Wi-Fi.',
    rating: 4.4, chain: nil, user: supervisors[0],
    base_price_per_night: 1200, available_from: Date.today, available_to: Date.today + 6.months,
    image_url: 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=1200&q=80',
    rooms: [
      { name: 'Койка в общем номере', room_type: 'Эконом', capacity: 1, area: 6, price: 1200, image_url: 'https://images.unsplash.com/photo-1564507592333-c60657eea523?auto=format&fit=crop&w=800&q=80' },
      { name: 'Приватный дабл', room_type: 'Стандарт', capacity: 2, area: 15, price: 2800, image_url: 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=800&q=80' }
    ]
  },

  # Санкт-Петербург
  {
    name: 'Невский Палас', hotel_type: 'Отель', city: 'Санкт-Петербург',
    address: 'Невский пр-т, 57', description: 'Элегантный отель на главной улице Петербурга с видом на исторические фасады.',
    rating: 4.6, chain: nil, user: supervisors[1],
    base_price_per_night: 7000, available_from: Date.today, available_to: Date.today + 6.months,
    image_url: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=1200&q=80',
    rooms: [
      { name: 'Классик 101', room_type: 'Стандарт', capacity: 2, area: 20, price: 4500, image_url: 'https://images.unsplash.com/photo-1595576508898-0ad5c879a061?auto=format&fit=crop&w=800&q=80' },
      { name: 'Панорама 201', room_type: 'Люкс', capacity: 2, area: 40, price: 9500, image_url: 'https://images.unsplash.com/photo-1591088398332-8a7791972843?auto=format&fit=crop&w=800&q=80' }
    ]
  },
  {
    name: 'Хостел Путешественник', hotel_type: 'Хостел', city: 'Санкт-Петербург',
    address: 'Лиговский пр-т, 44', description: 'Бюджетный хостел для молодых путешественников рядом с Московским вокзалом.',
    rating: 3.9, chain: nil, user: supervisors[1],
    base_price_per_night: 900, available_from: Date.today, available_to: Date.today + 6.months,
    image_url: 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=1200&q=80',
    rooms: [
      { name: 'Койко-место 6-мест', room_type: 'Эконом', capacity: 1, area: 5, price: 900, image_url: 'https://images.unsplash.com/photo-1520277739336-7bf67edfa768?auto=format&fit=crop&w=800&q=80' },
      { name: 'Приватная комната', room_type: 'Стандарт', capacity: 2, area: 14, price: 2500, image_url: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80' }
    ]
  },
  {
    name: 'Grand Hotel Europe', hotel_type: 'Отель', city: 'Санкт-Петербург',
    address: 'ул. Михайловская, 1', description: 'Культовый исторический отель с вековыми традициями гостеприимства и роскоши.',
    rating: 4.9, chain: 'Belmond', user: supervisors[1],
    base_price_per_night: 15000, available_from: Date.today, available_to: Date.today + 12.months,
    image_url: 'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?auto=format&fit=crop&w=1200&q=80',
    rooms: [
      { name: 'Исторический номер', room_type: 'Люкс', capacity: 2, area: 45, price: 18000, image_url: 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=800&q=80' },
      { name: 'Делюкс кинг', room_type: 'Стандарт', capacity: 2, area: 30, price: 13000, image_url: 'https://images.unsplash.com/photo-1611891487122-2075b9624448?auto=format&fit=crop&w=800&q=80' }
    ]
  },

  # Сочи
  {
    name: 'Сочи Бриз Резорт', hotel_type: 'База отдыха', city: 'Сочи',
    address: 'ул. Приморская, 88', description: 'Курортный комплекс на первой береговой линии. Открытый бассейн, спа-центр и собственный пляж.',
    rating: 4.5, chain: nil, user: supervisors[2],
    base_price_per_night: 6000, available_from: Date.today, available_to: Date.today + 8.months,
    image_url: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=1200&q=80',
    rooms: [
      { name: 'Морской 101', room_type: 'Стандарт', capacity: 2, area: 25, price: 4200, image_url: 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=800&q=80' },
      { name: 'Бриз Люкс 201', room_type: 'Люкс', capacity: 2, area: 42, price: 8500, image_url: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=800&q=80' }
    ]
  },
  {
    name: 'Гостевой дом У моря', hotel_type: 'Гостевой дом', city: 'Сочи',
    address: 'ул. Навагинская, 5', description: 'Уютный гостевой дом в 5 минутах от моря. Домашняя атмосфера и завтраки.',
    rating: 4.4, chain: nil, user: supervisors[2],
    base_price_per_night: 2800, available_from: Date.today, available_to: Date.today + 7.months,
    image_url: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=1200&q=80',
    rooms: [
      { name: 'Комната 2', room_type: 'Стандарт', capacity: 2, area: 20, price: 2500, image_url: 'https://images.unsplash.com/photo-1605371924599-2d0365da1ae0?auto=format&fit=crop&w=800&q=80' },
      { name: 'Комната 3', room_type: 'Стандарт', capacity: 3, area: 25, price: 3200, image_url: 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?auto=format&fit=crop&w=800&q=80' }
    ]
  },
  {
    name: 'Sochi Plaza Hotel', hotel_type: 'Отель', city: 'Сочи',
    address: 'ул. Виноградная, 20', description: 'Современный высотный отель с панорамным бассейном на крыше и фитнес-центром.',
    rating: 4.6, chain: nil, user: supervisors[2],
    base_price_per_night: 8000, available_from: Date.today, available_to: Date.today + 6.months,
    image_url: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1200&q=80',
    rooms: [
      { name: 'Панорамный Стандарт', room_type: 'Стандарт', capacity: 2, area: 28, price: 7500, image_url: 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?auto=format&fit=crop&w=800&q=80' },
      { name: 'Люкс с джакузи', room_type: 'Люкс', capacity: 2, area: 55, price: 15000, image_url: 'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?auto=format&fit=crop&w=800&q=80' }
    ]
  },

  # Казань
  {
    name: 'Казань Сити Отель', hotel_type: 'Отель', city: 'Казань',
    address: 'ул. Баумана, 33', description: 'Современный отель в пешей доступности от Кремля и главных достопримечательностей Казани.',
    rating: 4.3, chain: nil, user: supervisors[1],
    base_price_per_night: 4500, available_from: Date.today, available_to: Date.today + 5.months,
    image_url: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1200&q=80',
    rooms: [
      { name: 'Стандарт 201', room_type: 'Стандарт', capacity: 2, area: 24, price: 3800, image_url: 'https://images.unsplash.com/photo-1611891487122-2075b9624448?auto=format&fit=crop&w=800&q=80' },
      { name: 'Студия 301', room_type: 'Студия', capacity: 2, area: 35, price: 5200, image_url: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=800&q=80' }
    ]
  },
  {
    name: 'Kachan Hostel Green', hotel_type: 'Хостел', city: 'Казань',
    address: 'ул. Пушкина, 10', description: 'Яркий экологичный хостел в центре Казани. Чистые ортопедические матрасы, дружная атмосфера.',
    rating: 4.5, chain: nil, user: supervisors[1],
    base_price_per_night: 1000, available_from: Date.today, available_to: Date.today + 6.months,
    image_url: 'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?auto=format&fit=crop&w=1200&q=80',
    rooms: [
      { name: 'Место в мужском номере', room_type: 'Эконом', capacity: 1, area: 6, price: 950, image_url: 'https://images.unsplash.com/photo-1520277739336-7bf67edfa768?auto=format&fit=crop&w=800&q=80' },
      { name: 'Место в женском номере', room_type: 'Эконом', capacity: 1, area: 6, price: 950, image_url: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80' }
    ]
  },

  # Ялта
  {
    name: 'Ялта Резорт & СПА', hotel_type: 'Отель', city: 'Ялта',
    address: 'ул. Дражинского, 50', description: 'Прекрасный пятизвездный курортный отель на побережье Черного моря в Ялте с бассейнами и спа.',
    rating: 4.9, chain: nil, user: supervisors[2],
    base_price_per_night: 9500, available_from: Date.today, available_to: Date.today + 6.months,
    image_url: 'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=1200&q=80',
    rooms: [
      { name: 'Стандарт с видом на море', room_type: 'Стандарт', capacity: 2, area: 28, price: 9500, image_url: 'https://images.unsplash.com/photo-1507652313519-d4e9174996dd?auto=format&fit=crop&w=800&q=80' },
      { name: 'Полулюкс Семейный', room_type: 'Люкс', capacity: 4, area: 48, price: 16000, image_url: 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=800&q=80' }
    ]
  },
  {
    name: 'Yalta View Hostel', hotel_type: 'Хостел', city: 'Ялта',
    address: 'ул. Чехова, 12', description: 'Уютный хостел на холмах Ялты с великолепным общим балконом и видом на всю ялтинскую бухту.',
    rating: 4.1, chain: nil, user: supervisors[2],
    base_price_per_night: 1100, available_from: Date.today, available_to: Date.today + 6.months,
    image_url: 'https://images.unsplash.com/photo-1568495248636-6432b97bd949?auto=format&fit=crop&w=1200&q=80',
    rooms: [
      { name: 'Место в общем дорме', room_type: 'Эконом', capacity: 1, area: 5, price: 1100, image_url: 'https://images.unsplash.com/photo-1564507592333-c60657eea523?auto=format&fit=crop&w=800&q=80' }
    ]
  }
]

hotels = []
hotel_data.each do |hd|
  hotel = Hotel.create!(
    name: hd[:name], hotel_type: hd[:hotel_type], city: hd[:city],
    address: hd[:address], description: hd[:description], rating: hd[:rating],
    chain: hd[:chain], user: hd[:user], status: 'active',
    base_price_per_night: hd[:base_price_per_night],
    available_from: hd[:available_from], available_to: hd[:available_to],
    image_url: hd[:image_url]
  )
  hd[:rooms].each do |r|
    hotel.rooms.create!(
      name: r[:name], room_type: r[:room_type], capacity: r[:capacity],
      area: r[:area], price_per_night: r[:price], available: true,
      description: "#{r[:room_type]} номер, площадь #{r[:area]} м², до #{r[:capacity]} гостей",
      image_url: r[:image_url]
    )
  end
  hotels << hotel
end

puts "   ✅ #{Hotel.count} отелей, #{Room.count} номеров создано"

# ---------------------------------------------------------------------------
# 3. Properties (частные квартиры / апартаменты)
# ---------------------------------------------------------------------------
puts "🏠 Создание объектов недвижимости (Properties)..."

property_data = [
  {
    name: 'Квартира в центре Сочи', property_type: 'Квартира', city: 'Сочи',
    address: 'ул. Курортный пр-т, 92', rooms_count: 2, area: 55, guests_capacity: 4,
    description: 'Светлая двухкомнатная квартира с видом на море. Полностью оборудована для комфортного отдыха.',
    user: supervisors[2], status: 'active', base_price_per_night: 3500,
    available_from: Date.today, available_to: Date.today + 6.months,
    image_url: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1200&q=80'
  },
  {
    name: 'Студия на Невском', property_type: 'Квартира', city: 'Санкт-Петербург',
    address: 'Невский пр-т, 120', rooms_count: 1, area: 32, guests_capacity: 2,
    description: 'Стильная студия в самом центре Петербурга. Рядом метро и все достопримечательности.',
    user: supervisors[1], status: 'active', base_price_per_night: 2800,
    available_from: Date.today, available_to: Date.today + 6.months,
    image_url: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1200&q=80'
  },
  {
    name: 'Квартира на Тверской', property_type: 'Квартира', city: 'Москва',
    address: 'ул. Тверская, 8', rooms_count: 3, area: 78, guests_capacity: 6,
    description: 'Роскошная просторная трехкомнатная квартира в сталинском доме прямо на Тверской улице.',
    user: supervisors[0], status: 'active', base_price_per_night: 8900,
    available_from: Date.today, available_to: Date.today + 6.months,
    image_url: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=1200&q=80'
  },
  {
    name: 'Hermitage View Apartment', property_type: 'Апартаменты', city: 'Санкт-Петербург',
    address: 'наб. реки Мойки, 14', rooms_count: 2, area: 60, guests_capacity: 4,
    description: 'Апартаменты бизнес-класса с видом на Дворцовую площадь и Эрмитаж. Исторический дизайн.',
    user: supervisors[1], status: 'active', base_price_per_night: 7500,
    available_from: Date.today, available_to: Date.today + 6.months,
    image_url: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1200&q=80'
  },
  {
    name: 'Sea Breeze Apartment Sochi', property_type: 'Апартаменты', city: 'Сочи',
    address: 'ул. Черноморская, 3', rooms_count: 1, area: 40, guests_capacity: 3,
    description: 'Уютные апартаменты в элитном жилом комплексе у парка Фрунзе. До пляжа 100 метров.',
    user: supervisors[2], status: 'active', base_price_per_night: 5200,
    available_from: Date.today, available_to: Date.today + 6.months,
    image_url: 'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=1200&q=80'
  },
  {
    name: 'Апартаменты Кремль Казань', property_type: 'Апартаменты', city: 'Казань',
    address: 'ул. Право-Булачная, 19', rooms_count: 2, area: 50, guests_capacity: 4,
    description: 'Комфортабельные современные апартаменты с великолепным видом на Казанку и Кремль.',
    user: supervisors[1], status: 'active', base_price_per_night: 4200,
    available_from: Date.today, available_to: Date.today + 6.months,
    image_url: 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=1200&q=80'
  },
  {
    name: 'Коттедж у моря Ялта', property_type: 'Дом', city: 'Ялта',
    address: 'Севастопольское шоссе, 42', rooms_count: 4, area: 130, guests_capacity: 8,
    description: 'Двухэтажный коттедж с собственной зеленой террасой, зоной барбекю и шикарным видом на горы и море.',
    user: supervisors[2], status: 'active', base_price_per_night: 12000,
    available_from: Date.today, available_to: Date.today + 6.months,
    image_url: 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&w=1200&q=80'
  }
]

property_data.each do |p|
  Property.create!(p)
end

puts "   ✅ #{Property.count} объектов недвижимости создано"

# ---------------------------------------------------------------------------
# 4. Бронирования
# ---------------------------------------------------------------------------
puts "📅 Создание бронирований..."

# Прошлые (completed) - сохраняем в обход валидации дат
b1 = Booking.new(
  user: clients[0], room: hotels[0].rooms.first,
  check_in: 1.month.ago.to_date, check_out: 1.month.ago.to_date + 3.days,
  guests_count: 2, total_price: 16500, status: 'completed'
)
b1.save!(validate: false)

b2 = Booking.new(
  user: clients[1], room: hotels[4].rooms.first,
  check_in: 3.weeks.ago.to_date, check_out: 3.weeks.ago.to_date + 5.days,
  guests_count: 1, total_price: 22500, status: 'completed'
)
b2.save!(validate: false)

b3 = Booking.new(
  user: clients[2], room: hotels[7].rooms.first,
  check_in: 2.weeks.ago.to_date, check_out: 2.weeks.ago.to_date + 4.days,
  guests_count: 2, total_price: 16800, status: 'completed'
)
b3.save!(validate: false)

# Будущие (pending / confirmed)
Booking.create!(
  user: clients[0], room: hotels[0].rooms.second,
  check_in: 2.weeks.from_now.to_date, check_out: 2.weeks.from_now.to_date + 4.days,
  guests_count: 2, total_price: 48000, status: 'confirmed'
)
Booking.create!(
  user: clients[1], room: hotels[4].rooms.second,
  check_in: 3.weeks.from_now.to_date, check_out: 3.weeks.from_now.to_date + 7.days,
  guests_count: 2, total_price: 57000, status: 'pending'
)
Booking.create!(
  user: clients[2], room: hotels[10].rooms.first,
  check_in: 1.month.from_now.to_date, check_out: 1.month.from_now.to_date + 3.days,
  guests_count: 2, total_price: 7600, status: 'confirmed'
)

# Отменённые
Booking.create!(
  user: clients[4], room: hotels[0].rooms.first,
  check_in: 1.week.from_now.to_date, check_out: 1.week.from_now.to_date + 2.days,
  guests_count: 1, total_price: 11000, status: 'cancelled'
)

puts "   ✅ #{Booking.count} бронирований создано"

# ---------------------------------------------------------------------------
# 5. Отзывы (только на completed бронирования)
# ---------------------------------------------------------------------------
puts "⭐ Создание отзывов..."

review_texts = [
  'Прекрасный отель! Чистые номера, вежливый персонал, отличный завтрак. Обязательно вернёмся.',
  'Хорошее расположение, но звукоизоляция могла бы быть лучше. В целом — достойный вариант за свои деньги.',
  'Великолепный вид из окна! Номер просторный и уютный. Рекомендую для романтических поездок.',
  'Всё было на высшем уровне. Особенно порадовал спа-центр и ресторан при отеле.',
  'Неплохо для бюджетного варианта. Чисто, тепло, Wi-Fi работает. Для ночёвки — отлично.',
  'Отличный сервис! Персонал помог с экскурсиями и трансфером. Очень благодарны.',
  'Расположение — 10 из 10. До центра 5 минут пешком. Номер компактный, но уютный.',
  'Тихое место, красивая территория. Идеально для семейного отдыха с детьми.'
]

completed_bookings = [b1, b2, b3]
completed_bookings.each_with_index do |booking, i|
  Review.create!(
    user: booking.user, hotel: booking.room.hotel, booking: booking,
    rating: [5, 4, 5][i],
    body: review_texts[i]
  )
end

# Дополнительные отзывы (сначала создаем completed бронирования, чтобы пройти валидацию)
extra_bookings = []
hotels.first(3).each_with_index do |hotel, i|
  client = clients[(i + 2) % clients.size]
  eb = Booking.new(
    user: client, room: hotel.rooms.first,
    check_in: (i + 2).weeks.ago.to_date, check_out: (i + 2).weeks.ago.to_date + 3.days,
    guests_count: 2, total_price: hotel.rooms.first.price_per_night * 3, status: 'completed'
  )
  eb.save!(validate: false)
  extra_bookings << eb
end

extra_bookings.each_with_index do |booking, i|
  Review.create!(
    user: booking.user, hotel: booking.room.hotel, booking: booking,
    rating: [5, 4, 5][i],
    body: review_texts[3 + i]
  )
end

puts "   ✅ #{Review.count} отзывов создано"

# ---------------------------------------------------------------------------
# 6. Избранное
# ---------------------------------------------------------------------------
puts "❤️  Создание избранного..."

Favorite.create!(user: clients[0], hotel: hotels[0])
Favorite.create!(user: clients[0], hotel: hotels[4])
Favorite.create!(user: clients[1], hotel: hotels[1])
Favorite.create!(user: clients[2], hotel: hotels[4])

puts "   ✅ #{Favorite.count} избранных создано"

# ---------------------------------------------------------------------------
# Итог
# ---------------------------------------------------------------------------
puts ""
puts "=" * 60
puts "🎉 Seeds завершены успешно!"
puts "=" * 60
puts "  Пользователи: #{User.count}"
puts "    — Админ:       admin@checqin.ru / password123"
puts "    — Менеджеры (с привязкой к городам):"
puts "                   manager1@checqin.ru (Москва) / password123"
puts "                   manager2@checqin.ru (Санкт-Петербург) / password123"
puts "                   manager3@checqin.ru (Сочи) / password123"
puts "    — Клиенты:     user1@mail.ru / password123"
puts "  Отели:       #{Hotel.count}"
puts "  Номера:      #{Room.count}"
puts "  Properties:  #{Property.count}"
puts "  Бронирования:#{Booking.count}"
puts "  Отзывы:      #{Review.count}"
puts "  Избранное:   #{Favorite.count}"
puts "=" * 60
