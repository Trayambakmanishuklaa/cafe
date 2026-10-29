const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const prisma = require('../../database/prisma');
const env = require('../../config/env');
const { ApiError } = require('../../middleware/errorHandler');

class AuthService {
  static async register({ name, email, password, phone, role }) {
    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      throw new ApiError(400, 'User with this email already exists');
    }

    if (phone) {
      const existingPhone = await prisma.user.findUnique({ where: { phone } });
      if (existingPhone) {
        throw new ApiError(400, 'User with this phone number already exists');
      }
    }

    // Role safety: public registration can only create CUSTOMER unless bootstrap flag or explicit allowed check
    const assignedRole = role === 'OWNER' || role === 'STAFF' ? role : 'CUSTOMER';

    const passwordHash = await bcrypt.hash(password, 10);

    const user = await prisma.$transaction(async (tx) => {
      const createdUser = await tx.user.create({
        data: {
          name,
          email,
          passwordHash,
          phone,
          role: assignedRole,
        },
      });

      // Create CustomerProfile and LoyaltyAccount for customer role
      await tx.customerProfile.create({
        data: { userId: createdUser.id },
      });

      await tx.loyaltyAccount.create({
        data: { userId: createdUser.id, pointsBalance: 100, lifetimePoints: 100 }, // 100 welcome bonus points
      });

      // Also record initial welcome bonus in loyalty transaction ledger
      const loyaltyAccount = await tx.loyaltyAccount.findUnique({
        where: { userId: createdUser.id },
      });

      if (loyaltyAccount) {
        await tx.loyaltyTransaction.create({
          data: {
            loyaltyAccountId: loyaltyAccount.id,
            type: 'EARN',
            points: 100,
            description: 'Welcome Bonus for joining Cafe Passport!',
          },
        });
      }

      return createdUser;
    });

    const token = this.generateToken(user);

    const loyaltyAccount = await prisma.loyaltyAccount.findUnique({
      where: { userId: user.id },
    });

    return {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        loyaltyPoints: loyaltyAccount?.pointsBalance || 100,
        membershipTier: loyaltyAccount?.tier || 'BRONZE',
      },
      token,
    };
  }

  static async login({ email, password }) {
    const user = await prisma.user.findUnique({
      where: { email },
      include: { loyaltyAccount: true },
    });

    if (!user) {
      throw new ApiError(401, 'Invalid email or password');
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new ApiError(401, 'Invalid email or password');
    }

    const token = this.generateToken(user);

    return {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        loyaltyPoints: user.loyaltyAccount?.pointsBalance || 0,
        membershipTier: user.loyaltyAccount?.tier || 'BRONZE',
      },
      token,
    };
  }

  static generateToken(user) {
    return jwt.sign(
      { userId: user.id, email: user.email, role: user.role },
      env.JWT_SECRET,
      { expiresIn: env.JWT_EXPIRES_IN }
    );
  }
}

module.exports = AuthService;
