const bcrypt = require('bcryptjs');
const prisma = require('./prisma');

async function main() {
  console.log('🌱 Starting Database Seeding...');

  // 1. Create Default Staff Account
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

  // 2. Create Default Customer Account
  const customerPasswordHash = await bcrypt.hash('Customer@123', 10);
  const customer = await prisma.user.upsert({
    where: { email: 'customer@cafe.com' },
    update: {},
    create: {
      email: 'customer@cafe.com',
      passwordHash: customerPasswordHash,
      name: 'Regular Customer',
      phone: '9876543212',
      role: 'CUSTOMER',
    },
  });
  console.log('✅ Customer Account Seeded: customer@cafe.com / Customer@123');

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

  // Delete any existing sample products so only staff-added products show up
  await prisma.product.deleteMany({});
  console.log('✅ Sample Products Cleaned: Only Staff-Added Products will be displayed');

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
