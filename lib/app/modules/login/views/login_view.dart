import 'package:flutter/material.dart';
import 'package:fresco_shop/app/utils/components/custom_text_field.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    // Initialisé par défaut sur la cuisine, mais modifiable via les raccourcis
    final emailController = TextEditingController(text: "cuisine1@garba.local");
    final passwordController = TextEditingController(text: "password");

    final FocusNode emailFocusNode = FocusNode();
    final FocusNode passwordFocusNode = FocusNode();

    // Liste des comptes rapides pour générer les boutons dynamiquement
    final List<Map<String, dynamic>> quickUsers = [
      {
        'title': 'Caisse',
        'email': 'caisse@garba.local',
        'icon': Icons.point_of_sale_rounded,
        'color': Colors.blue,
      },
      {
        'title': 'Cuisine',
        'email': 'cuisine1@garba.local',
        'icon': Icons.soup_kitchen_rounded,
        'color': Colors.amber,
      },
      {
        'title': 'Distro',
        'email': 'distro@garba.local',
        'icon': Icons.delivery_dining_rounded,
        'color': Colors.green,
      },
    ];

    return GestureDetector(
      onTap: () {
        emailFocusNode.unfocus();
        passwordFocusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 20.0,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // En-tête : Logo & Identité visuelle
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.amber.shade50,
                      child: Icon(
                        Icons.storefront_rounded,
                        size: 48,
                        color: Colors.amber.shade900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Fresco Garba",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Sélectionnez votre poste ou connectez-vous",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- SECTION : CONNEXION RAPIDE ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: quickUsers.map((user) {
                        return Expanded(
                          child: Card(
                            elevation: 0,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                // Remplit automatiquement les formulaires
                                emailController.text = user['email'];
                                passwordController.text = "password";

                                // Retire le clavier de l'écran proprement
                                emailFocusNode.unfocus();
                                passwordFocusNode.unfocus();

                                Get.snackbar(
                                  "Poste sélectionné",
                                  "Formulaire configuré pour : ${user['title']}",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFF1E2230),
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 1),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14.0,
                                ),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: (user['color'] as Color)
                                          .withOpacity(0.1),
                                      child: Icon(
                                        user['icon'] as IconData,
                                        color: user['color'] as Color,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      user['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 30),

                    // Champ réutilisable : Adresse Email
                    CustomTextField(
                      controller: emailController,
                      focusNode: emailFocusNode,
                      labelText: 'Adresse Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) {
                        FocusScope.of(context).requestFocus(passwordFocusNode);
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "L'adresse email est requise.";
                        }
                        if (!GetUtils.isEmail(value.trim())) {
                          return "Veuillez entrer une adresse email valide.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Champ réutilisable : Mot de passe
                    CustomTextField(
                      controller: passwordController,
                      focusNode: passwordFocusNode,
                      labelText: 'Mot de passe',
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        passwordFocusNode.unfocus();
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Le mot de passe est requis.";
                        }
                        if (value.trim().length < 6) {
                          return "Le mot de passe doit contenir au moins 6 caractères.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Bouton de connexion réactif
                    Obx(() {
                      final bool loading = controller.isLoading.value;
                      return ElevatedButton(
                        onPressed: loading
                            ? null
                            : () {
                                emailFocusNode.unfocus();
                                passwordFocusNode.unfocus();

                                if (formKey.currentState!.validate()) {
                                  controller.submitLogin(
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade800,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.amber.shade800
                              .withOpacity(0.6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Se connecter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
