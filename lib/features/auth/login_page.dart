import 'package:flutter/material.dart';
import 'package:mochi_stok/core/theme.dart';
import 'package:mochi_stok/widgets/main_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Key menghubungkan form dengan proses validasi saat tombol Masuk ditekan.
  final _formKey = GlobalKey<FormState>();
  // Controller menyimpan nilai yang diketik pengguna pada masing-masing field.
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Controller dibersihkan agar tidak menyisakan resource setelah halaman ditutup.
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    // Navigasi hanya dilakukan jika seluruh field lolos validasi.
    if (!_formKey.currentState!.validate()) return;

    // Ganti halaman login dengan halaman utama agar tombol kembali tidak kembali ke login.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          // Lebar form dibatasi agar tetap nyaman dibaca pada layar besar.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // ScrollView menjaga form tetap dapat dijangkau saat layar pendek atau keyboard muncul.
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
                          // Validator di bawah dijalankan melalui key ini saat submit dipanggil.
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
                                  // trim memastikan input yang hanya berisi spasi dianggap kosong.
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
                                // Sembunyikan karakter password untuk menjaga privasi saat diketik.
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
                                  // Tombol menjalankan validasi lalu membuka halaman utama.
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

// Widget kecil ini menyamakan gaya label pada field username dan password.
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

// Logo dipisahkan agar pengaturan aset dan aksesibilitasnya terpusat.
class _MochiLogo extends StatelessWidget {
  const _MochiLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/mochi_madu_logo.png',
      height: 140,
      fit: BoxFit.contain,
      semanticLabel: 'Logo Mochi Madu Premium Quality',
    );
  }
}
