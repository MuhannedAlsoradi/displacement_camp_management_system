import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool isPasswordHidden = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // gradient
              Container(
                height: 220,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2F5D75), Color(0xFF4F8A8B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home_work_outlined,
                          color: Color(0xFF2F5D75),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "نظام إدارة المخيمات",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F5D75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Card(
                  elevation: 12,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'تسجيل الدخول ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'يرجى ادخال بينات الاعتماد للوصول الي النظام ',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 25),
                          TextFormField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              labelText: 'اسم المستخدم ',
                              hintText: 'ادخل اسم المستخدم',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجي ادخال اسم المستخدم';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: passwordController,
                            obscureText: isPasswordHidden,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              hintText: '*******',
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isPasswordHidden = !isPasswordHidden;
                                  });
                                },
                                icon: Icon(
                                  isPasswordHidden
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.purple),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجي ادخال كلمة المرور';
                              }
                              return null;
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text('نسبت كلمة المرور؟'),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff2A5D83),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () {},
                            child: isLoading
                                ? CircularProgressIndicator()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'تسجيل دخول ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // support
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'دعم الفني',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.headset_mic, color: Colors.grey),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Gaza Camp Management System 2026 ©',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                  SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('دعم فني', style: TextStyle(color: Colors.grey)),
                        SizedBox(width: 6),
                        Icon(Icons.shield, color: Colors.green, size: 18),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
