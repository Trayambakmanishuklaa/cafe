const bcrypt = require('bcryptjs');
const prisma = require('./prisma');

async function main() {
  console.log('🌱 Starting Database Seeding...');

  // 1. Create Default Owner Account
  const ownerPasswordHash = await bcrypt.hash('Owner@123', 10);
  const owner = await prisma.user.upsert({
    where: { email: 'owner@cafe.com' },
    update: {},
    create: {
      email: 'owner@cafe.com',
      passwordHash: ownerPasswordHash,
      name: 'Cafe Owner',
      phone: '9876543210',
      role: 'OWNER',
    },
  });
  console.log('✅ Owner Account Seeded: owner@cafe.com / Owner@123');

  // 2. Create Default Staff Account
  const staffPasswordHash = await bcrypt.hash('Staff@123', 10);
  const staff = await prisma.user.upsert({
    where: { email: 'staff@cafe.com' },
    update: {},
    create: {
      email: 'staff@cafe.com',
      passwordHash: staffPasswordHash,
      name: 'Head Barista Staff',
      phone: '9876543211',
      role: 'STAFF',
    },
  });
  console.log('✅ Staff Account Seeded: staff@cafe.com / Staff@123');

  // 3. Create Default Categories (Strictly 4 as per prompt rules)
  const categoriesData = [
    { name: 'Tea Corner', slug: 'tea', description: 'Freshly brewed aromatic Indian chais and teas', icon: 'local_cafe', sortOrder: 1 },
    { name: 'Coffee Corner', slug: 'coffee', description: 'Rich espresso, lattes, and artisan cold coffees', icon: 'coffee', sortOrder: 2 },
    { name: 'Bun & Bakery', slug: 'bun-bakery', description: 'Warm fresh buns, maska, and baked treats', icon: 'bakery_dining', sortOrder: 3 },
    { name: 'Burger Station', slug: 'burger', description: 'Juicy burgers with crispy patties & gourmet sauces', icon: 'lunch_dining', sortOrder: 4 },
  ];

  const categoriesMap = {};
  for (const cat of categoriesData) {
    const createdCat = await prisma.category.upsert({
      where: { slug: cat.slug },
      update: cat,
      create: cat,
    });
    categoriesMap[cat.slug] = createdCat.id;
  }
  console.log('✅ 4 Main Categories Seeded');

  // 4. Create Seed Products
  const productsData = [
    // Tea Corner
    { categoryId: categoriesMap['tea'], name: 'Classic Milk Tea', description: 'Traditional home-style milk tea', price: 30, isVeg: true, prepTimeMinutes: 5 },
    { categoryId: categoriesMap['tea'], name: 'Masala Chai', description: 'Brewed with cardamoms, cloves, ginger and cinnamon', price: 40, isVeg: true, prepTimeMinutes: 5 },
    { categoryId: categoriesMap['tea'], name: 'Ginger Tea', description: 'Spiced hot tea with crushed fresh ginger', price: 40, isVeg: true, prepTimeMinutes: 5 },
    { categoryId: categoriesMap['tea'], name: 'Elaichi Tea', description: 'Aromatic green cardamom infused chai', price: 40, isVeg: true, prepTimeMinutes: 5 },
    { categoryId: categoriesMap['tea'], name: 'Kulhad Chai', description: 'Served piping hot in traditional clay cups', price: 50, isVeg: true, prepTimeMinutes: 7 },
    { categoryId: categoriesMap['tea'], name: 'Lemon Tea', description: 'Refreshing black tea with fresh lemon juice', price: 35, isVeg: true, prepTimeMinutes: 5 },
    { categoryId: categoriesMap['tea'], name: 'Cutting Chai', description: 'Half cup strong kadak chai', price: 25, isVeg: true, prepTimeMinutes: 4 },
    { categoryId: categoriesMap['tea'], name: 'Strong Chai', description: 'Extra tea leaves brewed for a bold wake-up kick', price: 35, isVeg: true, prepTimeMinutes: 5 },

    // Coffee Corner
    { categoryId: categoriesMap['coffee'], name: 'Espresso', description: 'Bold single shot of dark roasted espresso', price: 80, isVeg: true, prepTimeMinutes: 5 },
    { categoryId: categoriesMap['coffee'], name: 'Cappuccino', description: 'Espresso layered with steamed milk and thick froth', price: 120, isVeg: true, prepTimeMinutes: 7 },
    { categoryId: categoriesMap['coffee'], name: 'Cafe Latte', description: 'Smooth espresso with plenty of creamy milk', price: 130, isVeg: true, prepTimeMinutes: 7 },
    { categoryId: categoriesMap['coffee'], name: 'Classic Hot Coffee', description: 'Comforting whipped traditional coffee', price: 90, isVeg: true, prepTimeMinutes: 6 },
    { categoryId: categoriesMap['coffee'], name: 'Cold Coffee', description: 'Blended chilled milk coffee with chocolate syrup', price: 110, isVeg: true, prepTimeMinutes: 8 },
    { categoryId: categoriesMap['coffee'], name: 'Iced Coffee', description: 'Chilled espresso over ice cubes with milk', price: 120, isVeg: true, prepTimeMinutes: 6 },
    { categoryId: categoriesMap['coffee'], name: 'Mocha Coffee', description: 'Rich cocoa blended with dark espresso', price: 140, isVeg: true, prepTimeMinutes: 8 },
    { categoryId: categoriesMap['coffee'], name: 'Caramel Coffee', description: 'Espresso infused with butterscotch caramel drizzle', price: 150, isVeg: true, prepTimeMinutes: 8 },

    // Bun & Bakery Corner
    { categoryId: categoriesMap['bun-bakery'], name: 'Bun Maska', description: 'Soft sweet bun loaded with rich Amul butter', price: 45, isVeg: true, prepTimeMinutes: 3 },
    { categoryId: categoriesMap['bun-bakery'], name: 'Butter Bun', description: 'Toasted bun with melted butter spread', price: 40, isVeg: true, prepTimeMinutes: 4 },
    { categoryId: categoriesMap['bun-bakery'], name: 'Jam Bun', description: 'Warm bun filled with mixed fruit jam', price: 45, isVeg: true, prepTimeMinutes: 3 },
    { categoryId: categoriesMap['bun-bakery'], name: 'Cheese Bun', description: 'Melted cheddar cheese stuffed inside toasted bun', price: 60, isVeg: true, prepTimeMinutes: 5 },
    { categoryId: categoriesMap['bun-bakery'], name: 'Toasted Bun', description: 'Crispy pan-toasted white bun', price: 50, isVeg: true, prepTimeMinutes: 4 },
    { categoryId: categoriesMap['bun-bakery'], name: 'Garlic Bun', description: 'Garlic butter brushed soft bakery bun', price: 65, isVeg: true, prepTimeMinutes: 6 },
    { categoryId: categoriesMap['bun-bakery'], name: 'Chocolate Bun', description: 'Dark chocolate lava filled sweet bun', price: 70, isVeg: true, prepTimeMinutes: 5 },

    // Burger Station
    { categoryId: categoriesMap['burger'], name: 'Classic Veg Burger', description: 'Crispy veggie patty with mayonnaise & fresh lettuce', price: 99, isVeg: true, prepTimeMinutes: 10 },
    { categoryId: categoriesMap['burger'], name: 'Aloo Tikki Burger', description: 'Spiced potato patty with mint mayo and onions', price: 79, isVeg: true, prepTimeMinutes: 8 },
    { categoryId: categoriesMap['burger'], name: 'Cheese Burger', description: 'Crispy patty topped with extra melted cheese slice', price: 129, isVeg: true, prepTimeMinutes: 10 },
    { categoryId: categoriesMap['burger'], name: 'Crispy Veg Burger', description: 'Double crunch patty with house secret sauce', price: 119, isVeg: true, prepTimeMinutes: 12 },
    { categoryId: categoriesMap['burger'], name: 'Double Patty Burger', description: 'Loaded double veggie patties with jalapeño spread', price: 169, isVeg: true, prepTimeMinutes: 14 },
    { categoryId: categoriesMap['burger'], name: 'Spicy Burger', description: 'Hot peri peri spiced burger patty', price: 139, isVeg: true, prepTimeMinutes: 10 },
    { categoryId: categoriesMap['burger'], name: 'Paneer Burger', description: 'Crispy cottage cheese steak patty with herbs', price: 149, isVeg: true, prepTimeMinutes: 12 },
  ];

  for (const prod of productsData) {
    const existing = await prisma.product.findFirst({
      where: { name: prod.name, categoryId: prod.categoryId },
    });
    if (!existing) {
      await prisma.product.create({ data: prod });
    }
  }
  console.log('✅ Seed Menu Products Added (Tea, Coffee, Buns, Burgers)');

  // 5. Seed Seating Tables
  for (let i = 1; i <= 10; i++) {
    const tableNumber = i;
    const capacity = i <= 4 ? 2 : i <= 8 ? 4 : 8;
    const zone = i <= 5 ? 'WINDOW_SIDE' : 'LOUNGE_AREA';
    await prisma.cafeTable.upsert({
      where: { tableNumber },
      update: { capacity, zone },
      create: {
        tableNumber,
        capacity,
        zone,
        qrCode: `TABLE_${tableNumber}_QR_CODE`,
      },
    });
  }
  console.log('✅ 10 Cafe Seating Tables Seeded');

  // 6. Seed Loyalty Rewards & Badges
  const rewardsData = [
    { title: 'Free Bun Maska', description: 'Redeem 200 points for a warm Bun Maska', pointsCost: 200, discountAmount: 45, rewardType: 'FREE_ITEM' },
    { title: 'Flat ₹50 OFF', description: 'Get ₹50 discount on orders above ₹150', pointsCost: 300, discountAmount: 50, rewardType: 'DISCOUNT_FLAT', minSpend: 150 },
    { title: 'Free Cold Coffee', description: 'Redeem 400 points for a refreshing Cold Coffee', pointsCost: 400, discountAmount: 110, rewardType: 'FREE_ITEM' },
  ];

  for (const reward of rewardsData) {
    const existing = await prisma.reward.findFirst({ where: { title: reward.title } });
    if (!existing) {
      await prisma.reward.create({ data: reward });
    }
  }

  const achievementsData = [
    { code: 'CHAI_EXPLORER', title: 'Chai Explorer', description: 'Tried 5 different tea varieties', badgeIcon: 'emoji_food_beverage', pointsBonus: 50 },
    { code: 'COFFEE_FAN', title: 'Coffee Fan', description: 'Ordered 10 cups of coffee', badgeIcon: 'coffee', pointsBonus: 100 },
    { code: 'COMBO_MASTER', title: 'Combo Master', description: 'Created 3 custom combo meals', badgeIcon: 'restaurant', pointsBonus: 75 },
    { code: 'WEEKEND_REGULAR', title: 'Weekend Regular', description: 'Visited 3 weekends in a row', badgeIcon: 'event', pointsBonus: 120 },
  ];

  for (const ach of achievementsData) {
    await prisma.achievement.upsert({
      where: { code: ach.code },
      update: ach,
      create: ach,
    });
  }
  console.log('✅ Loyalty Rewards & Achievements Seeded');

  console.log('🎉 Seeding Completed Successfully!');
}

main()
  .catch((e) => {
    console.error('Error during seeding:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
