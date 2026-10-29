const ProductsService = require('./products.service');

class ProductsController {
  static async getAll(req, res, next) {
    try {
      const products = await ProductsService.getAll(req.query);
      res.status(200).json({
        success: true,
        data: products,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getAllForStaff(req, res, next) {
    try {
      const products = await ProductsService.getAllForStaff();
      res.status(200).json({
        success: true,
        data: products,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getById(req, res, next) {
    try {
      const product = await ProductsService.getById(req.params.id);
      if (!product) {
        return res.status(404).json({ success: false, message: 'Product not found' });
      }
      res.status(200).json({
        success: true,
        data: product,
      });
    } catch (error) {
      next(error);
    }
  }

  static async createProduct(req, res, next) {
    try {
      const product = await ProductsService.createProduct(req.body);
      res.status(201).json({
        success: true,
        message: 'Product added successfully',
        data: product,
      });
    } catch (error) {
      next(error);
    }
  }

  static async updateProduct(req, res, next) {
    try {
      const updated = await ProductsService.updateProduct(req.params.id, req.body);
      res.status(200).json({
        success: true,
        message: 'Product updated successfully',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }

  static async toggleAvailability(req, res, next) {
    try {
      const updated = await ProductsService.toggleAvailability(req.params.id, req.body.isAvailable);
      res.status(200).json({
        success: true,
        message: 'Product availability updated',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getCombos(req, res, next) {
    try {
      const combos = await ProductsService.getCombos();
      res.status(200).json({
        success: true,
        data: combos,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = ProductsController;
