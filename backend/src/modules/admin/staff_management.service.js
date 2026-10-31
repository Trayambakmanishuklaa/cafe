const bcrypt = require('bcryptjs');
const prisma = require('../../database/prisma');
const { ApiError } = require('../../middleware/errorHandler');

class StaffManagementService {
  static async createStaff({ name, phone, email, password }) {
    if (!name || !phone || !password) {
      throw new ApiError(400, 'Full name, mobile number, and password are required');
    }

    const existingPhone = await prisma.user.findUnique({ where: { phone } });
    if (existingPhone) {
      throw new ApiError(400, `Staff member with mobile number '${phone}' already exists`);
    }

    const emailVal = email && email.trim().isNotEmpty ? email.trim() : `staff_${phone}@cafe.com`;
    const existingEmail = await prisma.user.findUnique({ where: { email: emailVal } });
    if (existingEmail) {
      throw new ApiError(400, `User with email '${emailVal}' already exists`);
    }

    const passwordHash = await bcrypt.hash(password, 10);

    return await prisma.user.create({
      data: {
        name,
        phone,
        email: emailVal,
        passwordHash,
        role: 'STAFF',
      },
      select: {
        id: true,
        name: true,
        phone: true,
        email: true,
        role: true,
        createdAt: true,
      },
    });
  }

  static async getStaffList(search) {
    const where = {
      role: 'STAFF',
    };

    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { phone: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } },
      ];
    }

    return await prisma.user.findMany({
      where,
      select: {
        id: true,
        name: true,
        phone: true,
        email: true,
        role: true,
        createdAt: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  static async resetStaffPassword(id, newPassword) {
    if (!newPassword || newPassword.length < 6) {
      throw new ApiError(400, 'Password must be at least 6 characters long');
    }

    const staff = await prisma.user.findUnique({ where: { id } });
    if (!staff) throw new ApiError(404, 'Staff account not found');

    const passwordHash = await bcrypt.hash(newPassword, 10);

    return await prisma.user.update({
      where: { id },
      data: { passwordHash },
      select: { id: true, name: true, email: true },
    });
  }
}

module.exports = StaffManagementService;
