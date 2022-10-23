import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poi_poi_todo/database/database.dart';
import 'package:poi_poi_todo/models/note_model.dart';

import 'add_note_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Note>> _noteList;

  final DateFormat _dateFormatter = DateFormat("MMM dd, yyyy");

  DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _updateNoteList();
  }

  _updateNoteList() {
    _noteList = DatabaseHelper.instance.getNoteList();
  }

  _delete(Note note) {
    DatabaseHelper.instance.deleteNote(note.id!);
    _updateNoteList();
    setState((){ });
  }

  Widget _buildTaskDesign(Note note, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
      ),
      child: Card(
        elevation: 2.0,
        child: ListTile(
          title: Text(
            note.title!,
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              decoration: note.status == 0
                  ? TextDecoration.none
                  : TextDecoration.lineThrough,
            ),
          ),
          subtitle: Text(
            '${_dateFormatter.format(note.date!)} - ${note.priority}',
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.black38,
              decoration: note.status == 0
                  ? TextDecoration.none
                  : TextDecoration.lineThrough,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  showConfirmDialog(note);
                },
                child: Icon(
                  Icons.delete,
                  size: 25.0,
                  color: Colors.red,
                ),
              ),
              Checkbox(
                onChanged: (value) {
                  note.status = value! ? 1 : 0;
                  DatabaseHelper.instance.updateNote(note);
                  _updateNoteList();
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => HomeScreen()));
                },
                activeColor: Theme.of(context).primaryColor,
                value: note.status == 1 ? true : false,
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => AddNoteScreen(
                  updateNoteList: _updateNoteList(),
                  note: note,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => AddNoteScreen(
                updateNoteList: _updateNoteList,
              ),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: FutureBuilder(
          future: _noteList,
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            
            final int completeNoteCount = snapshot.data!
                .where((Note note) => note.status == 1)
                .toList()
                .length;

            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              itemCount: int.parse(snapshot.data.length.toString()) + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 30.0, 10.0, 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Poi Poi Todo',
                          style: TextStyle(
                            color: Colors.lightBlueAccent.shade200,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        completeNoteCount == 0 && snapshot.data.length == 0
                            ? Text(
                                'Hey! you did not add any task yet',
                                style: TextStyle(
                                  color: Colors.lightBlueAccent.shade100,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : Text(
                                '$completeNoteCount of ${snapshot.data.length} task is complete',
                                style: TextStyle(
                                  color: Colors.lightBlueAccent.shade100,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ],
                    ),
                  );
                }
                return _buildTaskDesign(snapshot.data![index - 1], context);
              },
            );
          }),
    );
  }

  showConfirmDialog(Note note) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 16,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
              height: 150.0,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Text(
                    'Are you sure you want to delete?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14.0),
                  ),
                  const SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        onPressed: () {
                          _delete(note);
                          Navigator.pop(context);
                        },
                        padding: const EdgeInsets.all(12),
                        child: const Text('Yes',
                            style:
                            TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                      RaisedButton(
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        padding: const EdgeInsets.all(12),
                        child: const Text('No',
                            style:
                            TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                    ],
                  ),
                ],
              ),
            ));
      },
    );
  }
}
