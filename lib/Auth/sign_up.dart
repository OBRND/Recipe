import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal/Auth/auth_service.dart';
import 'package:meal/Auth/sign_in.dart';

import '../Models/decoration.dart';

class SignUp extends StatefulWidget {
  // const Sign_up({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String First_name ='';
  String Last_name ='';
  String Phone_number = '';
  String error ="";
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      extendBodyBehindAppBar: true,
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      // backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [

        ],),
      body: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Container(
          padding: EdgeInsets.only(top: 200,left: 20,right: 20),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox( height: 20),
                  TextFormField(
                      decoration: textinputdecoration.copyWith(hintText: 'Email'),
                      validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                      onChanged: (val){
                        setState(() => email = val);
                      }

                  ),
                  SizedBox( height: 10),
                  TextFormField(
                      decoration: textinputdecoration.copyWith(hintText: 'Password'),
                      validator: (val) => val!.length < 6 ? 'Enter password more that 6 characters' : null,
                      obscureText: true,
                      onChanged: (val){
                        setState(() => password = val);
                      }
                  ),
                  SizedBox( height: 10),
                  TextFormField(
                      decoration: textinputdecoration.copyWith(hintText: 'First Name'),
                      validator: (val) => val!.isEmpty ? 'Enter First' : null,
                      onChanged: (val){
                        setState(() => First_name = val);
                      }
                  ),
                  SizedBox( height: 10),
                  TextFormField(
                      decoration: textinputdecoration.copyWith(hintText: 'Last Name'),
                      validator: (val) => val!.isEmpty ? 'Enter Last name' : null,
                      onChanged: (val){
                        setState(() => Last_name = val);
                      }
                  ),
                  SizedBox( height: 10),
                  TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: textinputdecoration.copyWith(hintText: 'Phone number'),
                      validator: (val) => val!.length == 10 ?   null : 'Please enter a 10 digit phone number ',
                      onChanged: (val){
                        setState(() => Phone_number = val );
                      }
                  ),
                  SizedBox( height: 10),
                  ElevatedButton(
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.white54),)),
                          backgroundColor: MaterialStateColor.resolveWith((states) => Color.fromARGB(255, 7, 255, 172))),
                      child: Text("Register",
                        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      ),

                      onPressed: () async{
                        if(_formKey.currentState!.validate()){
                          //   setState(() => loading = true);
                          dynamic result = await _auth.registerWEP(email, password,First_name, Last_name, Phone_number);
                          if(result == null){
                            setState((){ error ='please supply a valid email';
                              //     loading = false;
                            });
                          }
                        }
                      }
                  ),

                  SizedBox( height: 0),
                  Text(error,
                      style: TextStyle(color: Colors.red)
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: FloatingActionButton.extended(onPressed:(){
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (BuildContext context) => SignIn()
                        ),
                      );
                    },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),),
                      backgroundColor: Color.fromARGB(255, 37, 236, 160),
                      extendedPadding: EdgeInsetsDirectional.only(start: 16.0, end: 20.0),
                      icon: Icon(Icons.person_outline_outlined),
                      label: Text('Log in',style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),),
                    ),
                  )

                ],
              ),
            ),
          ),
        ),
      ),
      //   );
      // }
    );
  }
}