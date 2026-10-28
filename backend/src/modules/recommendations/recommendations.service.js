const prisma = require('../../database/prisma');

class RecommendationsService {
  static async getRecommendations({ productId, categorySlug }) {
    let targetCategorySlug = 'bun-bakery';

    if (categorySlug === 'tea') {
      targetCategorySlug = 'bun-bakery';
    } else if (categorySlug === 'coffee') {
      targetCategorySlug = 'bun-bakery';
    } else if (categorySlug === 'burger') {
      targetCategorySlug = 'coffee';
    }

    const recCategory = await prisma.category.findUnique({
      where: { slug: targetCategorySlug },
    });

    if (!recCategory) {
      return await prisma.product.findMany({ take: 2, where: { isAvailable: true } });
    }

    // Limit to 2 complementary suggestions to avoid spamming the user
    return await prisma.product.findMany({
      where: {
        categoryId: recCategory.id,
        isAvailable: true,
        id: productId ? { not: productId } : undefined,
      },
      take: 2,
    });
  }

  static async getCombos() {
    return await prisma.combo.findMany({
      where: { isActive: true },
      include: {
        items: {
          include: {
            product: true,
          },
        },
      },
    });
  }
}

module.exports = RecommendationsService;
