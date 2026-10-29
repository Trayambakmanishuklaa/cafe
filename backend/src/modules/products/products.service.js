const prisma = require('../../database/prisma');
const { ApiError } = require('../../middleware/errorHandler');

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

  static async getAllForStaff() {
    return await prisma.product.findMany({
      include: {
        category: true,
      },
      orderBy: { createdAt: 'desc' },
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

  static async createProduct({ name, description, categorySlug, price, imageUrl, isVeg, prepTimeMinutes }) {
    let category = await prisma.category.findUnique({ where: { slug: categorySlug } });
    if (!category) {
      category = await prisma.category.findFirst({
        where: { OR: [{ slug: categorySlug }, { name: { contains: categorySlug, mode: 'insensitive' } }] },
      });
    }

    if (!category) {
      throw new ApiError(400, `Category '${categorySlug}' not found`);
    }

    return await prisma.product.create({
      data: {
        name,
        description,
        categoryId: category.id,
        price: parseFloat(price),
        imageUrl: imageUrl || null,
        isVeg: isVeg !== undefined ? isVeg === true || isVeg === 'true' : true,
        prepTimeMinutes: prepTimeMinutes ? parseInt(prepTimeMinutes, 10) : 10,
        isAvailable: true,
        stockCount: 100,
      },
      include: {
        category: true,
      },
    });
  }

  static async updateProduct(id, { name, description, categorySlug, price, imageUrl, isAvailable, isVeg }) {
    const data = {};
    if (name) data.name = name;
    if (description) data.description = description;
    if (price !== undefined) data.price = parseFloat(price);
    if (imageUrl !== undefined) data.imageUrl = imageUrl;
    if (isAvailable !== undefined) data.isAvailable = isAvailable === true || isAvailable === 'true';
    if (isVeg !== undefined) data.isVeg = isVeg === true || isVeg === 'true';

    if (categorySlug) {
      const category = await prisma.category.findUnique({ where: { slug: categorySlug } });
      if (category) data.categoryId = category.id;
    }

    return await prisma.product.update({
      where: { id },
      data,
      include: {
        category: true,
      },
    });
  }

  static async toggleAvailability(id, isAvailable) {
    return await prisma.product.update({
      where: { id },
      data: { isAvailable },
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
