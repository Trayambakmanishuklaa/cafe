const bcrypt = require('bcryptjs');
const prisma = require('../../database/prisma');
const { ApiError } = require('../../middleware/errorHandler');

class StaffService {
  static async getStaffList() {
    return await prisma.user.findMany({
      where: {
        role: { in: ['STAFF', 'OWNER'] },
      },
      select: {
        id: true,
        name: true,
        email: true,
        phone: true,
        role: true,
        createdAt: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  static async createStaffAccount({ name, email, password, phone, role }) {
    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      throw new ApiError(400, 'User with this email already exists');
    }

    const assignedRole = role === 'OWNER' ? 'OWNER' : 'STAFF';
    const passwordHash = await bcrypt.hash(password, 10);

    const created = await prisma.user.create({
      data: {
        name,
        email,
        passwordHash,
        phone,
        role: assignedRole,
      },
      select: {
        id: true,
        name: true,
        email: true,
        phone: true,
        role: true,
        createdAt: true,
      },
    });

    return created;
  }

  static async updateStaffRole(staffId, role) {
    const user = await prisma.user.findUnique({ where: { id: staffId } });
    if (!user) {
      throw new ApiError(404, 'Staff account not found');
    }

    return await prisma.user.update({
      where: { id: staffId },
      data: { role },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
      },
    });
  }
}

module.exports = StaffService;
