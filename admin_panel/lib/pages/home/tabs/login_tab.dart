import 'package:admin_panel/locator.dart';
import 'package:admin_panel/services/providers/base_provider.dart';
import 'package:admin_panel/utils/strings.dart';
import 'package:admin_panel/widgets/global/input_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginTab extends StatefulWidget {
  const LoginTab({super.key});

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  final _passController = TextEditingController();
  String? _wrongPass;

  @override
  void dispose() {
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseProvider = Provider.of<BaseProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.person_pin_circle_sharp,
          size: 100,
          color: Colors.white54,
        ),
        Text(
          baseProvider.auth ? "Giriş Yapıldı!" : "Giriş Yap",
          style: const TextStyle(fontSize: 24, color: Colors.white54),
        ),
        const SizedBox(height: 50),
        if (!baseProvider.auth)
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: InputWidget(
              controller: _passController,
              hintText: "Şifre",
              errorText: _wrongPass,
              isSecret: true,
              onTap: () {
                if (_passController.text == KStrings.pass) {
                  locator.get<BaseProvider>().setAuth();
                } else {
                  _wrongPasswordShowError();
                }
              },
            ),
          )
      ],
    );
  }

  void _wrongPasswordShowError() async {
    _passController.clear();
    setState(() => _wrongPass = "Hatalı Şifre!");
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _wrongPass = null);
  }
}
