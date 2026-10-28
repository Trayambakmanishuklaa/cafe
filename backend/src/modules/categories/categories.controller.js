const prisma = require('../../database/prisma');

class CategoriesController {
  static async getAll(req, res, next) {
    try {
      const categories = await prisma.category.findMany({
        where: { isActive: true },
        orderBy: { sortOrder: 'asc' },
        include: {
          _count: {
            select: { products: true },
          },
        },
      });

      res.status(200).json({
        success: true,
        data: categories,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = CategoriesController;
