import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:multiplayer_frontend/json%20class/join_game_class.dart';
import 'package:multiplayer_frontend/setup_page.dart';
import 'package:multiplayer_frontend/warning_popups.dart';

import 'config.dart';

// Start screen for user where they can create or join a game

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final nameController = TextEditingController();
  final gameCodeController = TextEditingController();

  var loading = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Up and down the river"),
        ),
        body: loading ? _showLoading(context) : _showOptions(context)

    );
  }

  Widget _showLoading(BuildContext context){
    return const Center(
      child: CircularProgressIndicator()
    );
  }

  Widget _showOptions(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create game',
                style: Theme.of(context).textTheme.headline3,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    constraints:
                        const BoxConstraints(minWidth: 100, maxWidth: 300),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        fillColor: Color(0x00000000), //Translucent
                        border: UnderlineInputBorder(),
                        labelText: 'Enter your name',
                      ),
                      controller: nameController,
                      onFieldSubmitted: (String str) {
                        _createGame(context);
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _createGame(context);
                    },
                    icon: const Icon(Icons.check),
                  )
                ],
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Join game',
                style: Theme.of(context).textTheme.headline3,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    constraints:
                        const BoxConstraints(minWidth: 100, maxWidth: 300),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        fillColor: Color(0x00000000), //Translucent
                        border: UnderlineInputBorder(),
                        labelText: 'Enter the game code',
                      ),
                      controller: gameCodeController,
                      onFieldSubmitted: (String str) {
                        _collectUserName(context);
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _collectUserName(context);
                    },
                    icon: const Icon(Icons.login),
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _collectUserName(BuildContext context) async {
    if (gameCodeController.text.isEmpty) {
      WarningPopups.customWarning(context, "A game code must be given");
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Enter name'),
            content: TextFormField(
              decoration: const InputDecoration(
                fillColor: Color(0x00000000), //Translucent
                border: UnderlineInputBorder(),
                labelText: 'Enter your name',
              ),
              controller: nameController,
              onFieldSubmitted: (String str) {
                _joinGame(context);
              },
            ),
            actions: <Widget>[
              IconButton(
                  onPressed: () {
                    _joinGame(context);
                  },
                  icon: const Icon(Icons.check))
            ],
          );
        },
      );
    }
  }

  void _createGame(BuildContext context) async {
    setState(() {
      loading = true;
    });

    String name = nameController.text;
    name = name.trim();

    if (name.isEmpty) {
      WarningPopups.customWarning(context, "A name must be given");
      return;
    }

    final params = {"name": name};

    var url = Uri.https(apiURL, "start/create_game");
    try {
      http.Response response =
          await http.post(url, headers: jsonHeader, body: json.encode(params));
      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = jsonDecode(response.body.toString());
        JoinGame gameInfo = JoinGame.fromJson(responseMap);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SetupScreen(
                      arguments: gameInfo,
                    )));
      } else {
        WarningPopups.httpError(response, context);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      WarningPopups.unknownError(context);
    }

    setState(() {
      loading = false;
    });
  }

  void _joinGame(BuildContext context) async {
    setState(() {
      loading = true;
    });

    String name = nameController.text;
    name = name.trim();
    String gameCodeString = gameCodeController.text;

    if (name.isEmpty) {
      WarningPopups.customWarning(context, "A name must be given");
      return;
    }

    final params = {"game_id": gameCodeString, "name": name};

    var url = Uri.https(apiURL, "start/join_game");
    try {
      http.Response response =
          await http.post(url, headers: jsonHeader, body: json.encode(params));
      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = jsonDecode(response.body.toString());
        JoinGame gameInfo = JoinGame.fromJson(responseMap);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SetupScreen(
                      arguments: gameInfo,
                    )));
      } else {
        WarningPopups.httpError(response, context);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      WarningPopups.unknownError(context);
    }

    setState(() {
      loading = false;
    });
  }
}
