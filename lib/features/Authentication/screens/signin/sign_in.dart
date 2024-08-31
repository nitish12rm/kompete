import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kompete/features/Authentication/screens/signup/sign_up.dart';

import '../../../../logic/authentication/login.dart';

class SignInScreen extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Sign In",style:TextStyle(color: Colors.white,fontStyle: FontStyle.italic,fontWeight: FontWeight.bold) ,),

        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Center(child: Text("KOMPETE",style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold,fontSize: 40,color: Colors.white),))),

            Expanded(child: Column(children: [
              TextField(
                controller: loginController.emailController,
                style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(borderSide:BorderSide(color: Colors.white)),
                  focusColor: Colors.white,
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white))
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),
                controller: loginController.passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),

                  border: OutlineInputBorder(borderSide:BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white))

                ),
                obscureText: true,
              ),
              SizedBox(height: 32),
              InkWell(
                  onTap: () {
                    loginController.loginWithEmail();
                  },
                child: Container(color: Colors.white,child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0,horizontal: 30),
                  child: Text('Sign In',style:TextStyle(color: Colors.black,fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),),
                ),),
              )

            ],)),
            Row(children: [Spacer(),Text("dont have an account? ",style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),),TextButton(onPressed: (){Get.to(()=>SignUpScreen());}, child: Text("Signup",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),))],),
            Expanded(child: Container(),),

          ],
        ),
      ),
    );
  }
}
