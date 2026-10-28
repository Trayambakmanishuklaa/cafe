const prisma = require('../../database/prisma');

class ProductsService {
  static async getAll({ categorySlug, search, isVeg }) {
    const where = { isAvailable: true };

    if (categorySlug) {
      const category = await prisma.category.findUnique({ where: { slug: categorySlug } });
      if (category) {
        where.categoryId = category.id;
      }
    }

    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    if (isVeg !== undefined) {
      where.isVeg = isVeg === 'true';
    }

    return await prisma.product.findMany({
      where,
      include: {
        category: {
          select: { name: true, slug: true },
        },
        customizations: true,
      },
      orderBy: { name: 'asc' },
    });
  }

  static async getById(id) {
    return await prisma.product.findUnique({
      where: { id },
      include: {
        category: true,
        customizations: true,
      },
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

module.exports = ProductsService;
