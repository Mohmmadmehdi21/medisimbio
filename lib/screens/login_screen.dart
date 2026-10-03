import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medisimbio_ui/screens/auth_wrapper.dart';
import 'package:medisimbio_ui/screens/forgot_password_screen.dart';
import 'package:medisimbio_ui/screens/register_screen.dart';
import 'package:medisimbio_ui/services/firebase_service.dart';

/// Country code model for extensible international phone support.
class CountryCode {
  final String code;
  final String flag;
  final String name;
  final int digitLength;

  const CountryCode({
    required this.code,
    required this.flag,
    required this.name,
    this.digitLength = 10,
  });
}

const List<CountryCode> _countryCodes = [
  CountryCode(code: '+91', flag: '🇮🇳', name: 'India', digitLength: 10),
  CountryCode(code: '+1', flag: '🇺🇸', name: 'United States', digitLength: 10),
  CountryCode(
      code: '+44', flag: '🇬🇧', name: 'United Kingdom', digitLength: 10),
  CountryCode(code: '+971', flag: '🇦🇪', name: 'UAE', digitLength: 9),
  CountryCode(code: '+61', flag: '🇦🇺', name: 'Australia', digitLength: 9),
  CountryCode(code: '+65', flag: '🇸🇬', name: 'Singapore', digitLength: 8),
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  // ================================================================
  // CONTROLLERS
  // ================================================================

  final TextEditingController _emailOrMobileController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ================================================================
  // STATE
  // ================================================================

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isPhoneMode = false;
  CountryCode _selectedCountry = _countryCodes[0]; // Default India (+91)

  // ================================================================
  // INIT & DISPOSE
  // ================================================================

  @override
  void initState() {
    super.initState();
    _emailOrMobileController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _emailOrMobileController.removeListener(_onInputChanged);
    _emailOrMobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ================================================================
  // DYNAMIC INPUT DETECTION
  // ================================================================

  void _onInputChanged() {
    final rawInput = _emailOrMobileController.text;
    final trimmed = rawInput.trim();

    if (trimmed.isEmpty) {
      if (_isPhoneMode) {
        setState(() {
          _isPhoneMode = false;
        });
      }
      return;
    }

    // Handle pasted full number starting with country code prefix (e.g. +919876543210)
    if (trimmed.startsWith('+')) {
      for (final c in _countryCodes) {
        if (trimmed.startsWith(c.code)) {
          final localDigits =
              trimmed.substring(c.code.length).replaceAll(RegExp(r'\D'), '');
          setState(() {
            _selectedCountry = c;
            _isPhoneMode = true;
          });
          _emailOrMobileController.value = TextEditingValue(
            text: localDigits,
            selection: TextSelection.collapsed(offset: localDigits.length),
          );
          return;
        }
      }
    }

    // Email contains '@' or alphabetic characters
    final hasEmailChars =
        trimmed.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(trimmed);
    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');

    // Phone mode if no email characters and digits are present
    final isPhone = !hasEmailChars && digitsOnly.isNotEmpty;

    if (isPhone != _isPhoneMode) {
      setState(() {
        _isPhoneMode = isPhone;
      });
    }
  }

  // ================================================================
  // LOGIN / PHONE AUTH ROUTING
  // ================================================================

  Future<void> _loginOrSendOTP() async {
    final input = _emailOrMobileController.text.trim();

    if (input.isEmpty) {
      _showMessage('Please enter your email or mobile number.');
      return;
    }

    if (_isPhoneMode) {
      await _sendOTP(input);
    } else {
      await _loginWithEmail(input);
    }
  }

  // ================================================================
  // EMAIL / PASSWORD LOGIN
  // ================================================================

  Future<void> _loginWithEmail(String email) async {
    final password = _passwordController.text;

    // Email validation
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter your password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.signInWithEmail(
        email: email,
        password: password,
      );

      if (!mounted) return;
      _showMessage('Sign in successful!');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage(_cleanErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ================================================================
  // PHONE AUTHENTICATION (SMS OTP)
  // ================================================================

  Future<void> _sendOTP(String phoneInput) async {
    final rawDigits = phoneInput.replaceAll(RegExp(r'\D'), '');

    // Indian mobile (or selected country) digit validation
    if (rawDigits.length != _selectedCountry.digitLength) {
      _showMessage(
          'Enter a valid ${_selectedCountry.digitLength}-digit mobile number');
      return;
    }

    // E.164 phone formatting normalization (+919876543210)
    final e164Phone = '${_selectedCountry.code}$rawDigits';

    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.verifyPhoneNumber(
        phoneNumber: e164Phone,
        onVerificationCompleted: (phoneAuthCred) async {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          _showMessage('Phone sign-in successful!');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthWrapper()),
            (route) => false,
          );
        },
        onVerificationFailed: (e) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          _showMessage(_cleanErrorMessage(e));
        },
        onCodeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          _showOTPDialog(verificationId, e164Phone);
        },
        onCodeAutoRetrievalTimeout: (verificationId) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showMessage(_cleanErrorMessage(e));
    }
  }

  void _showOTPDialog(String verificationId, String phone) {
    final otpController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Enter SMS Verification Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Code sent to $phone',
                    style:
                        const TextStyle(fontSize: 13, color: Color(0xFF5A716E)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      letterSpacing: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: '123456',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF5A716E)),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final code = otpController.text.trim();
                          if (code.isEmpty || code.length < 6) {
                            _showMessage('Please enter valid 6-digit code.');
                            return;
                          }

                          setDialogState(() => isSubmitting = true);

                          final navigator = Navigator.of(context);

                          try {
                            await _firebaseService.signInWithPhoneOTP(
                              verificationId: verificationId,
                              smsCode: code,
                              mobile: phone,
                            );

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (mounted) {
                              _showMessage('Phone sign-in successful!');
                              navigator.pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const AuthWrapper()),
                                (route) => false,
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            _showMessage(_cleanErrorMessage(e));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF087F73),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Verify & Sign In'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================================================================
  // COUNTRY SELECTOR MODAL
  // ================================================================

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Select Country Code',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173330),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _countryCodes.length,
                  itemBuilder: (context, index) {
                    final c = _countryCodes[index];
                    final isSelected = c.code == _selectedCountry.code;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: isSelected ? const Color(0xFFE6F2F0) : null,
                      leading: Text(
                        c.flag,
                        style: const TextStyle(fontSize: 22),
                      ),
                      title: Text(
                        c.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF173330),
                        ),
                      ),
                      trailing: Text(
                        c.code,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF087F73)
                              : const Color(0xFF5A716E),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCountry = c;
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================================================================
  // FORGOT PASSWORD
  // ================================================================

  void _forgotPassword() {
    final input = _emailOrMobileController.text.trim();
    final initialEmail = input.contains('@') ? input : '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(initialEmail: initialEmail),
      ),
    );
  }

  // ================================================================
  // GOOGLE LOGIN
  // ================================================================

  Future<void> _continueWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await _firebaseService.signInWithGoogle();

      if (!mounted) return;

      if (credential != null) {
        _showMessage('Google Sign-In successful!');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
          (route) => false,
        );
      } else {
        _showMessage('Google Sign-In canceled.');
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage(_cleanErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ================================================================
  // APPLE LOGIN
  // ================================================================

  void _continueWithApple() {
    _showMessage('Apple Sign-In is not configured for Android.');
  }

  // ================================================================
  // REGISTER
  // ================================================================

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  // ================================================================
  // MESSAGE & CLEAN ERROR PARSER
  // ================================================================

  String _cleanErrorMessage(dynamic error) {
    var msg = error.toString();
    if (msg.startsWith('Exception: ')) {
      msg = msg.substring(11);
    }
    return msg;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: const Color(0xFF087F73),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F8),

      // ============================================================
      // REAL DEVICE SCREEN
      // ============================================================

      body: SafeArea(
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ==================================================
                    // LOGO
                    // ==================================================

                    const _MedisimbioLogo(),

                    const SizedBox(
                      height: 5,
                    ),

                    // ==================================================
                    // SUBTITLE
                    // ==================================================

                    const Text(
                      'Login to your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5A716E),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(
                      height: 34,
                    ),

                    // ==================================================
                    // COMBINED EMAIL / MOBILE INPUT FIELD
                    // ==================================================

                    _CustomInputField(
                      controller: _emailOrMobileController,
                      hintText: _isPhoneMode
                          ? '98765 43210'
                          : 'Email or Mobile Number',
                      prefixIcon:
                          _isPhoneMode ? null : Icons.mail_outline_rounded,
                      isPhoneMode: _isPhoneMode,
                      selectedCountry: _selectedCountry,
                      onCountryTap: _showCountryPicker,
                      keyboardType: _isPhoneMode
                          ? TextInputType.phone
                          : TextInputType.emailAddress,
                      inputFormatters: _isPhoneMode
                          ? [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(
                                  _selectedCountry.digitLength),
                            ]
                          : null,
                    ),

                    // ==================================================
                    // PASSWORD FIELD & FORGOT PASSWORD (EMAIL MODE ONLY)
                    // ==================================================

                    if (!_isPhoneMode) ...[
                      const SizedBox(
                        height: 14,
                      ),
                      _CustomInputField(
                        controller: _passwordController,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        selectedCountry: _selectedCountry,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: const Color(
                              0xFF5A716E,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 7,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(
                                0xFF087F73,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(
                      height: 14,
                    ),

                    // ==================================================
                    // LOGIN / SEND OTP BUTTON
                    // ==================================================

                    _PrimaryButton(
                      text: _isPhoneMode ? 'Send OTP' : 'Login',
                      isLoading: _isLoading,
                      onPressed: _loginOrSendOTP,
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // OR DIVIDER
                    // ==================================================

                    const _OrDivider(),

                    const SizedBox(
                      height: 20,
                    ),

                    // ==================================================
                    // GOOGLE
                    // ==================================================

                    _SocialLoginButton(
                      icon: const _GoogleIcon(),
                      text: 'Continue with Google',
                      onTap: _continueWithGoogle,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ==================================================
                    // APPLE
                    // ==================================================

                    _SocialLoginButton(
                      icon: const Icon(
                        Icons.apple,
                        size: 22,
                        color: Colors.black,
                      ),
                      text: 'Continue with Apple',
                      onTap: _continueWithApple,
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    // ==================================================
                    // CREATE ACCOUNT
                    // ==================================================

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(
                              0xFF5A716E,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _openRegister,
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(
                                0xFF087F73,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ==================================================================
// MEDISIMBIO LOGO
// ==================================================================

class _MedisimbioLogo extends StatelessWidget {
  const _MedisimbioLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/medisimbio.png',
      width: 190,
      height: 65,
      fit: BoxFit.contain,
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return const Text(
          'Medisimbio',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF175D57),
          ),
        );
      },
    );
  }
}

// ==================================================================
// INPUT FIELD
// ==================================================================

class _CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool isPhoneMode;
  final CountryCode selectedCountry;
  final VoidCallback? onCountryTap;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _CustomInputField({
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.isPhoneMode = false,
    required this.selectedCountry,
    this.onCountryTap,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(
            0xFFD9E4E1,
          ),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (isPhoneMode)
            InkWell(
              onTap: onCountryTap,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: double.infinity,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedCountry.flag,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      selectedCountry.code,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF173330),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF5A716E),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 1,
                      height: 22,
                      color: const Color(0xFFD9E4E1),
                    ),
                  ],
                ),
              ),
            )
          else if (prefixIcon != null)
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Icon(
                prefixIcon,
                color: const Color(
                  0xFF5A716E,
                ),
                size: 20,
              ),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF173330),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8C9E9A),
                ),
                suffixIcon: suffixIcon,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isPhoneMode ? 8 : (prefixIcon == null ? 16 : 0),
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// PRIMARY BUTTON
// ==================================================================

class _PrimaryButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.text,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(
            0xFF087F73,
          ),
          disabledBackgroundColor: const Color(
            0xFF72AAA4,
          ),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              26,
            ),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }
}

// ==================================================================
// OR DIVIDER
// ==================================================================

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(
              0xFFD9E4E1,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 14,
          ),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8C9E9A),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(
              0xFFD9E4E1,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// SOCIAL LOGIN BUTTON
// ==================================================================

class _SocialLoginButton extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(
            color: Color(0xFFD9E4E1),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              14,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(
              width: 10,
            ),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF173330),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// GOOGLE ICON
// ==================================================================

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/google_logo.png',
      width: 22,
      height: 22,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Text(
          'G',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4285F4),
          ),
        );
      },
    );
  }
}
