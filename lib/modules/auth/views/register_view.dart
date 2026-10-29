
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _confirmPasswordController = TextEditingController();

  // Premium Beige Glass TextField
  Widget _buildNeumorphicTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    Color fieldColor = const Color(0xFFF5E6CC),
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    const textColor = Color(0xFF3D2B1F);
    const hintColor = Color(0xFF9B8874);
    const iconColor = Color(0xFF75563A);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(fieldColor, Colors.white, 0.35)!,
            fieldColor,
            Color.lerp(fieldColor, const Color(0xFFD8C3A5), 0.25)!,
          ],
        ),
        border: Border.all(
          color: const Color(0xFFD8C3A5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF75563A).withAlpha(22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.white.withAlpha(180),
            blurRadius: 6,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          cursorColor: iconColor,
          style: const TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: hintColor,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 10,
              ),
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Color.lerp(
                    fieldColor,
                    const Color(0xFFE2D0B6),
                    0.65,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD8C3A5),
                    width: 0.7,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 19,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIcon: suffixIcon,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 20,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8EB),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withAlpha(200),
                        offset: const Offset(-2, -2),
                        blurRadius: 6,
                      ),
                      BoxShadow(
                        color: const Color(0xFF75563A).withAlpha(20),
                        offset: const Offset(2, 4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF224D35),
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Cafe Logo
              Center(
                child: Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8EB),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD6A15D),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB68B55).withAlpha(55),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.coffee_rounded,
                        size: 34,
                        color: Color(0xFF224D35),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Shubh's",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF224D35),
                          fontFamily: 'serif',
                        ),
                      ),
                      Text(
                        '– CAFE –',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB68B55),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Create Your Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF224D35),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Join Shubh's Cafe and enjoy the best\n"
                    'tea, coffee, buns & burgers',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF827462),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // Full Name
              _buildNeumorphicTextField(
                controller: controller.nameController,
                hintText: 'Enter your full name',
                icon: Icons.person_outline_rounded,
                fieldColor: const Color(0xFFF5E6CC),
                keyboardType: TextInputType.name,
              ),

              const SizedBox(height: 16),

              // Email
              _buildNeumorphicTextField(
                controller: controller.emailController,
                hintText: 'Enter your email address',
                icon: Icons.mail_outline_rounded,
                fieldColor: const Color(0xFFF5E6CC),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              // Phone Number
              _buildNeumorphicTextField(
                controller: controller.phoneController,
                hintText: 'Enter your phone number (Optional)',
                icon: Icons.phone_outlined,
                fieldColor: const Color(0xFFF5E6CC),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              // Password
              _buildNeumorphicTextField(
                controller: controller.passwordController,
                hintText: 'Create a strong password',
                icon: Icons.lock_outline_rounded,
                fieldColor: const Color(0xFFF5E6CC),
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                suffixIcon: IconButton(
                  tooltip: _obscurePassword
                      ? 'Show password'
                      : 'Hide password',
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: const Color(0xFF75563A),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Confirm Password
              _buildNeumorphicTextField(
                controller: _confirmPasswordController,
                hintText: 'Re-enter your password',
                icon: Icons.lock_outline_rounded,
                fieldColor: const Color(0xFFF5E6CC),
                obscureText: _obscureConfirmPassword,
                keyboardType: TextInputType.visiblePassword,
                suffixIcon: IconButton(
                  tooltip: _obscureConfirmPassword
                      ? 'Show password'
                      : 'Hide password',
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: const Color(0xFF75563A),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword =
                      !_obscureConfirmPassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 28),

              // Register Button
              Obx(
                    () => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF224D35),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                    const Color(0xFF224D35).withAlpha(150),
                    minimumSize: const Size.fromHeight(58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor:
                    const Color(0xFF224D35).withAlpha(65),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                    if (controller.passwordController.text !=
                        _confirmPasswordController.text) {
                      Get.snackbar(
                        'Validation Error',
                        'Passwords do not match',
                        backgroundColor:
                        const Color(0xFFFFE8E4),
                        colorText: const Color(0xFF9B2828),
                        margin: const EdgeInsets.all(16),
                        borderRadius: 14,
                      );
                      return;
                    }

                    controller.register();
                  },
                  child: controller.isLoading.value
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'REGISTER',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 17,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(
                    child: Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Color(0xFF827462),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Text(
                      'Login Now',
                      style: TextStyle(
                        color: Color(0xFF224D35),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Decorative Divider
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      color: Color(0xFFD8C3A5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Icon(
                      Icons.eco_rounded,
                      size: 19,
                      color: const Color(0xFF224D35).withAlpha(170),
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      color: Color(0xFFD8C3A5),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Footer
              const Center(
                child: Text(
                  'More Than Just Coffee ♡',
                  style: TextStyle(
                    color: Color(0xFF827462),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
