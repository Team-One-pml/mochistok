import 'package:flutter/material.dart';
import 'package:mochi_stok/core/theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login belum terhubung ke layanan autentikasi.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 48,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4),
                        const _MochiLogo(),
                        const SizedBox(height: 10),
                        const Text(
                          'Mochi Stock',
                          style: TextStyle(
                            color: MochiTheme.ink,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Catat stok bahan dan mochi jadi dengan rapi.',
                          style: TextStyle(
                            color: MochiTheme.muted,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _FieldLabel('Username'),
                              const SizedBox(height: 5),
                              TextFormField(
                                controller: _usernameController,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.username],
                                decoration: const InputDecoration(
                                  hintText: 'Masukkan username',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Username wajib diisi.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              const _FieldLabel('Password'),
                              const SizedBox(height: 5),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) => _submit(),
                                decoration: const InputDecoration(
                                  hintText: 'Masukkan password',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password wajib diisi.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                height: 44,
                                child: FilledButton(
                                  onPressed: _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: MochiTheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: const Text('Masuk'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: MochiTheme.primary,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _MochiLogo extends StatelessWidget {
  const _MochiLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 82,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E9),
                  borderRadius: BorderRadius.circular(36),
                ),
              ),
              const Text('🐰', style: TextStyle(fontSize: 52, height: 1)),
              const Positioned(
                top: 3,
                right: 12,
                child: Text('🍓', style: TextStyle(fontSize: 19)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Mochi-Madu',
            style: TextStyle(
              color: Color(0xFF8A453D),
              fontSize: 14,
              fontWeight: FontWeight.w900,
              height: 1,
              shadows: [Shadow(color: Color(0xFFFFD98A), offset: Offset(0, 1))],
            ),
          ),
        ],
      ),
    );
  }
}
