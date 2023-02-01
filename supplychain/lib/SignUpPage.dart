import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _passController = TextEditingController();
  TextEditingController _passConfirmController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Supply Chain",
          ),
        ),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Container(
              color: Colors.grey.shade100,
              child: Center(
                  child: Column(
                children: [
                  const Spacer(),
                  const Text("Sign Up",
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 35,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            blurStyle: BlurStyle.normal)
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        TextField(
                          textAlign: TextAlign.center,
                          controller: _mobileController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: const InputDecoration(
                            label: Text("Mobile Number"),
                            labelStyle: TextStyle(),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            hintStyle: TextStyle(color: Colors.black38),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextField(
                          controller: _passController,
                          obscureText: true,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(15),
                          ],
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.visibility),
                            label: Text("Create new password"),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            hintStyle: TextStyle(color: Colors.black38),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: _passConfirmController,
                          obscureText: true,
                          onChanged: (value) {
                            _errorText = _passConfirmController.value.text !=
                                    _passController.value.text
                                ? "Password does not match !"
                                : null;
                            setState(() {});
                          },
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(15),
                          ],
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            errorText: _errorText,
                            suffixIcon: const Icon(Icons.visibility),
                            label: Text("Confirm password"),
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            hintStyle: TextStyle(color: Colors.black38),
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        TextButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.grey),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),

                              // change width of the button
                              minimumSize: MaterialStateProperty.all<Size>(
                                  const Size(200, 50)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: const BorderSide(
                                          color: Colors.grey)))),
                          onPressed: () {
                            _errorText = _passConfirmController.value.text !=
                                    _passController.value.text
                                ? "Password does not match !"
                                : null;
                            setState(() {});

                            if (_errorText == null &&
                                _passConfirmController.value.text.length > 0 &&
                                _mobileController.value.text.length == 10) {
                              _SignUp();
                            } else {
                              _errorText = "Invalid Password";
                              setState(() {});
                            }
                          },
                          child: const Text('Sign Up',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        const Text("or Sign up with "),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(
                                  'https://cdn-icons-png.flaticon.com/64/281/281764.png'),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/LoginPage");
                      },
                      child: const Text("Already registered ? Log In",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold))),
                  const SizedBox(
                    height: 40,
                  ),
                ],
              )),
            )));
  }

  void _SignUp() {
    Navigator.pushNamed(context, "/OtpVerifyPage");
  }
}