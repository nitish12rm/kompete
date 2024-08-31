import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../logic/authentication/signup.dart';

class SignUpScreen extends StatelessWidget {
  final SignupController signupController = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text("Signup",style:TextStyle(color: Colors.white,fontStyle: FontStyle.italic,fontWeight: FontWeight.bold) ,),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text("KOMPETE",style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold,fontSize: 40,color: Colors.white),)),
SizedBox(height: 30,),
            Expanded(child: Column(children: [
              TextField(
                controller: signupController.nameController,
                style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),
                decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),
                    border: OutlineInputBorder(borderSide:BorderSide(color: Colors.white)),
                    focusColor: Colors.white,
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white))
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 15,),
              TextField(
                controller: signupController.emailController,
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
              SizedBox(height: 15,),
              TextField(
                style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),
                controller: signupController.passwordController,
                decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),

                    border: OutlineInputBorder(borderSide:BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white))

                ),
                obscureText: true,
              ),
              SizedBox(height: 15,),

              Row(children: [
                Expanded(child:  TextField(
                  controller: signupController.weightController,
                  style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),
                  decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      labelStyle: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),
                      border: OutlineInputBorder(borderSide:BorderSide(color: Colors.white)),
                      focusColor: Colors.white,
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white))
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),),
                SizedBox(width: 8,),

                Expanded(child:  TextField(
                  controller: signupController.heightController,
                  style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),
                  decoration: InputDecoration(
                      labelText: 'Height (cm)',
                      labelStyle: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),
                      border: OutlineInputBorder(borderSide:BorderSide(color: Colors.white)),
                      focusColor: Colors.white,
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white))
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),)
              ],),
              SizedBox(height: 32),
              InkWell(
                onTap: () {
                  signupController.signup();
                },
                child: Container(color: Colors.white,child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0,horizontal: 30),
                  child: Text('Sign Up',style:TextStyle(color: Colors.black,fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),),
                ),),
              )

            ],)),
            Container(),

          ],
        ),
      ),
    );
  }
}
