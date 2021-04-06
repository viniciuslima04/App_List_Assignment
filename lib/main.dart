import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

// PAREI NO MINUTO 11:08 DA PARTE 2
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();
  var _toDoList = [];
  var _lastRemoved = {};
  var _lastRemovedPos = 0;

  void _addToDo() {
    setState(() {
      _toDoList.add({
        "title": _toDoController.text,
        "ok": false,
      });
      _saveData();
      _toDoController.text = "";
    });
  }

  Widget _buildItem(context, index) {
    var item = _toDoList[index];

    return Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.startToEnd,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 10),
          color: Colors.red,
          child: Icon(Icons.delete, color: Colors.white),
        ),
        child: CheckboxListTile(
          title: Text(item["title"]),
          value: item["ok"],
          secondary:
              CircleAvatar(child: Icon(item["ok"] ? Icons.check : Icons.error)),
          onChanged: (ok) {
            setState(() {
              item["ok"] = ok;
              _saveData();
            });
          },
        ),
        onDismissed: (direction) {
          setState(() {
            _lastRemoved = Map.from(item);
            _lastRemovedPos = index;
            _toDoList.removeAt(index);
            _saveData();

            final snack = SnackBar(
              content: Text("Tarefa\"${_lastRemoved["title"]}\"removida!"),
              duration: Duration(seconds: 2),
              action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _toDoList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                },
              ),
            );

            //Limpar a pilha de Snackbar
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            //Mostro o SnackBar
            ScaffoldMessenger.of(context).showSnackBar(snack);
          });
        });
  }

  Future<Null> _refresh() async {
    setState(() {
      _toDoList.sort((a, b) {
        return a['title'].toLowerCase().compareTo(b['title'].toLowerCase());
      });
      _toDoList.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });
      _saveData();
    });
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/data.json");
    return file.writeAsString(data);
  }

  Future<String> _loadDate() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File("${directory.path}/data.json");
      return await file.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    _loadDate().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Lista de Tarefas"),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
                padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
                child: Row(children: [
                  Expanded(
                      child: TextField(
                    decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                    controller: _toDoController,
                  )),
                  TextButton(
                    child: Text("ADD", style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.blueAccent)),
                    onPressed: _addToDo,
                  )
                ])),
            Expanded(
                child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 10.0),
                      itemCount: _toDoList.length,
                      itemBuilder: _buildItem,
                    )))
          ],
        ));
  }
}
