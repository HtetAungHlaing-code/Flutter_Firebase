import 'package:flutter/material.dart';

import 'Services/authentication.dart';

class LoginSignUp extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback loginCallback;

  const LoginSignUp({ this.auth, this.loginCallback});
  @override
  _LoginSignUpState createState() => _LoginSignUpState();
}

class _LoginSignUpState extends State<LoginSignUp> {
  final _formKey = GlobalKey<FormState>();
  String _email;
  String _password;
  String _errorMessage;
  bool _isLoading;
  bool _isLoginForm;
  //check if form is valid before login /signup
  bool validateAndSave(){
    final form = _formKey.currentState;
    if(form.validate()){
      form.save();
      return true;
    }
    return false;
  }

  //perform login or signup
  void validateAndSubmit()async{
    setState(() {
      _errorMessage= "";
      _isLoading = true;
    });
    if(validateAndSave()){
      String userId = "";
      try{
        if(_isLoginForm){
          userId = await widget.auth.signIn(_email, _password);
          print('Signed in : $userId');
        }
        else{
          userId = await widget.auth.signUp(_email, _password);
          print('Signed Up : $userId');
        }
        setState(() {
          _isLoading = false;
        });
        if(userId.length > 0 && userId != null && _isLoginForm){
          widget.loginCallback();
        }
      }
      catch(e){
        print('Error : $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          _formKey.currentState.reset();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
  }

  void resetForm(){
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  void toggleFormMode(){
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase Login/SignUp"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          showForm(),
          showCircularProgress(),
        ],
      ),
    );
  }

  Widget showCircularProgress(){
    if(_isLoading){
      return Center(child: CircularProgressIndicator(),);
    }
    return Container(height: 0.0,width: 0.0,);
  }

  Widget showForm(){
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            showLogo(),
            showEmailInput(),
            showPasswordInput(),
            showPrimaryButton(),
            showSecondaryButton(),
          ],
        ),
      ),
    );
  }

  Widget showErrorMessage(){
    if(_errorMessage.length > 0 && _errorMessage != null){
      return Text(
        _errorMessage,
        style: TextStyle(fontSize: 14.0,color: Colors.red,height: 1.0,
            fontWeight: FontWeight.bold),
      );
    }else{
      return Container(
        height: 0.0,
      );
    }
  }

  Widget showLogo() {
    return Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('Assets/dab.gif'),
            fit: BoxFit.cover,
          )),
        ),
      ),
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        autofocus: false,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            hintText: "Email",
            icon: Icon(
              Icons.email,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        autofocus: false,
        obscureText: true,
        decoration: InputDecoration(
            hintText: "Password",
            icon: Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget showPrimaryButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 50, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: RaisedButton(
          elevation: 4.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          color: Colors.blue,
          child: Text(
            _isLoginForm ? 'Login' : 'Sign Up',
            style: TextStyle(fontSize: 20.0, color: Colors.white),
          ),
          onPressed: () {
              validateAndSubmit();
          },
        ),
      ),
    );
  }

  Widget showSecondaryButton(){
    return FlatButton(
      child: Text(
        _isLoginForm ? 'Create an Account' : 'Have an Account? Sign in',
        style: TextStyle(
          fontSize: 18.0,fontWeight: FontWeight.w300
        ),
      ),
      onPressed: (){
        toggleFormMode();
      },
    );
  }

}
