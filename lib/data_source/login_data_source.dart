import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';

class LoginDataSource   {
    Future<String> login(String email, String password)   async {
        final Uri loginUri = Uri.parse('https://reqres.in/api/login');
        final Map<String,dynamic> body =
        {
            "email": email,
            "password": password
        };
        Response response = await post(loginUri, body: body);
        dynamic responseData = jsonDecode(response.body);
        if(response.statusCode == 200){
            return responseData['token'];
        }
        // log(response.body);
        throw Exception(responseData['error']);
    }

}