/* // Register Section
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Register',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 34,
                        fontFamily: 'helvetica',
                        color: Color(0xffffffff),
                      ),
                    ),
                    TextFormField(
                      controller: new_emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        errorText: email ? "Email must be in abc@def.com format" : null,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: new_passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        errorText: pass ? "Password must be at least 6 characters" : null,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordCheck,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        filled: true,
                        fillColor: Colors.white,
                        errorText: pass_check ? "Passwords do not match" : null,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _goal,
                      decoration: InputDecoration(
                        labelText: 'Enter savings goal',
                        filled: true,
                        fillColor: Colors.white,
                        errorText: value ? 'value must be an integer or double of 2 decimal places' : null,
                      ),
                     
                    ),
                    SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: _createUser,
                      child: Text('Register'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} */