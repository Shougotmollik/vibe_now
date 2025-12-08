import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/auth_title.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/custom_text_form_field.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundVariant,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 150.h),
            AuthTitle(title: 'Log In', subtitle: 'Welcome Back'),
            SizedBox(height: 20.h),
            CustomTextFormField(label: 'Email', hintText: 'Enter your email'),
            SizedBox(height: 20.h),
            CustomTextFormField(
              label: 'Password',
              hintText: 'Enter your password',
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Checkbox(value: true, onChanged: (value) {}),
                Text(
                  'Remember Me',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: Colors.black38,
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            PrimaryButton.text(onPressed: () {}, text: 'Sign In'),
            // SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don\'t have an account?'),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Sign Up',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.copyWith(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
