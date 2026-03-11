import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType textInputType;
  final int maxLine;
  final bool isPhoneNumber;
  final bool isValidator;
  final dynamic validator;
  final bool isEmail;
  final bool isName;
  final bool isDigits;
  final TextCapitalization capitalization;
  final IconData? iconData;
  final bool isPassword;
  final bool? readOnly;
  final String? validatorMsg;
  final String? label;
  final Function? onTap;
  final Function(String)? onValueChange;
  final IconData? suffixIcon;
  final Widget? prefixIcon;
  final bool showRequiredAsterisk;

  const CustomTextField({
    required this.controller,
    required this.hintText,
    required this.textInputType,
    this.maxLine = 1,
    this.isPhoneNumber = false,
    this.isValidator = true,
    this.isEmail = false,
    this.isName = false,
    this.isDigits = false,
    this.capitalization = TextCapitalization.none,
    this.iconData,
    this.isPassword = false,
    this.readOnly,
    this.onTap,
    this.label,
    this.onValueChange,
    this.suffixIcon,
    this.prefixIcon,
    this.showRequiredAsterisk = false,
    super.key,
    this.validatorMsg,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                  children: [
                    TextSpan(text: widget.label!),
                    if (widget.showRequiredAsterisk)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
          TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _isObscure : false,
            keyboardType: widget.textInputType,
            textCapitalization: widget.capitalization,
            autovalidateMode: AutovalidateMode.disabled,
            readOnly: widget.readOnly ?? false,
            maxLines: widget.maxLine,
            cursorColor: theme.primaryColor,
            inputFormatters: widget.isPhoneNumber
                ? [FilteringTextInputFormatter.digitsOnly]
                : [FilteringTextInputFormatter.singleLineFormatter],
            validator: _buildValidator(),
            onChanged: widget.onValueChange,
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.readOnly == true
                  ? theme.disabledColor.withValues(alpha: 0.05)
                  : theme.inputDecorationTheme.fillColor ??
                      theme.cardColor.withValues(alpha: 0.05),
              hintText: widget.hintText,
              hintStyle:
                  inputTheme.hintStyle ?? TextStyle(color: theme.hintColor),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primaryColor,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                        color: theme.primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    )
                  : widget.suffixIcon != null
                      ? Icon(
                          widget.suffixIcon,
                          color: theme.primaryColor,
                        )
                      : null,
              prefixIcon: widget.prefixIcon,
            ),
          ),
        ],
      ),
    );
  }

  String? Function(String?)? _buildValidator() {
    if (widget.validator != null) {
      return widget.validator as String? Function(String?);
    }
    if (!widget.isValidator) return null;
    if (widget.isPhoneNumber) {
      return Validators.compose([
        Validators.required('Phone number is required'),
        Validators.minLength(10, 'Mobile number cannot be less than 10 digits'),
        Validators.maxLength(
            10, 'Mobile number cannot be greater than 10 digits'),
      ]);
    } else if (widget.isEmail) {
      return Validators.compose([
        Validators.required('Email is required'),
        Validators.email('Invalid email address'),
      ]);
    } else if (widget.isName) {
      return Validators.compose([
        Validators.patternString(
            r"^[A-Za-z\s]+$", 'Only alphabets and spaces are allowed'),
        Validators.required('${widget.hintText} is required'),
      ]);
    } else if (widget.isDigits) {
      return Validators.compose([
        Validators.patternRegExp(
            RegExp(r"^[0-9]*$"), 'Only digits are allowed'),
        Validators.required('${widget.hintText} is required'),
      ]);
    } else if (widget.isPassword) {
      return Validators.compose([
        Validators.patternString(
            r"^.{6,}$", 'Password must be at least 6 characters long'),
        Validators.required('password is required'),
      ]);
    } else {
      return Validators.required('This field is required');
    }
  }
}
