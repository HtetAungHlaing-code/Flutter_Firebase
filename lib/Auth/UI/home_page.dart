import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/Auth/Services/Todo.dart';
import 'package:flutter_firebase/Auth/Services/authentication.dart';

class HomePage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  const HomePage({this.auth, this.logoutCallback, this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> _todoList;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onTodoAddedSubcription;
  StreamSubscription<Event> _onTodoChangedSubcription;
  Query _todoQuery;

  @override
  void initState() {
    super.initState();
    _todoList = List();
    _todoQuery = _database
        .reference()
        .child('todo')
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onTodoAddedSubcription = _todoQuery.onChildAdded.listen(onEntryAdded);
    _onTodoChangedSubcription =
        _todoQuery.onChildChanged.listen(onEntryChanged);
  }

  onEntryAdded(Event event) {
    setState(() {
      _todoList.add(Todo.fromSnapshot(event.snapshot));
    });
  }

  onEntryChanged(Event event) {
    var oldEntry = _todoList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _todoList[_todoList.indexOf(oldEntry)] =
          Todo.fromSnapshot(event.snapshot);
    });
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  showAddTodoDialog(BuildContext context) async {
    _textEditingController.clear();
    await showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _textEditingController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Add new todo"
                ),
              ),
            )
          ],
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          FlatButton(
            onPressed: (){
              addNewTodo(_textEditingController.text.toString());
              Navigator.pop(context);
            },
            child: Text('Save'),
          )
        ],
      );
    });
  }

  addNewTodo(String todoItem){
    if(todoItem.length > 0){
      Todo todo = Todo(todoItem,false,widget.userId);
      _database.reference().child("todo").push().set(todo.toJson());
    }
  }

  Widget showTodoList(){
    if(_todoList.length > 0 ){
      return ListView.builder(
        shrinkWrap: true,
        itemCount: _todoList.length,
        itemBuilder: (BuildContext context,int index){
          String todoId = _todoList[index].key;
          String subject = _todoList[index].subject;
          return ListTile(
            title: Text(
              subject,
              style: TextStyle(fontSize: 20.0,),
            ),
          );
        },
      );
    }
    else{
      return Center(
        child: Text(
          "Your list is empty."
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              signOut();
            },
            child: Text(
              "Logout",
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
          )
        ],
      ),
      body: showTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddTodoDialog(context);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
