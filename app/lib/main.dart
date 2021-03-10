import 'dart:convert';

import 'package:app/quiz.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primaryColor: Colors.white),
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Quiz quiz;
  List<Results> results;

  Future<void> fetchQuestions() async {
    var response = await http.get("https://opentdb.com/api.php?amount=40");
    var decRes = jsonDecode(response.body);
    print(decRes);
    quiz = Quiz.fromJson(decRes);
    results = quiz.results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz App"),
        backgroundColor: Colors.teal[200],
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchQuestions,
        child: FutureBuilder(
          future: fetchQuestions(),
          // ignore: missing_return
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text("press button to start...");
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                if (snapshot.hasError) return Container();
                return questionList();
            }
            return null;
          },
        ),
      ),
    );
  }

  // ignore: missing_return
  ListView questionList() {
    return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) => Card(
              color: Colors.white,
              elevation: 5.0,
              shadowColor: Colors.red,
              child: ExpansionTile(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      results[index].question,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FilterChip(
                              backgroundColor: Colors.grey[100],
                              label: Text(results[index].category),
                              onSelected: (b) {}),
                          SizedBox(
                            width: 10,
                          ),
                          FilterChip(
                              backgroundColor: Colors.grey[100],
                              label: Text(results[index].difficulty),
                              onSelected: (b) {})
                        ],
                      ),
                    )
                  ],
                ),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      "https://images.unsplash.com/photo-1573339607881-208e75e4b267?ixid=MXwxMjA3fDB8MHxzZWFyY2h8Mnx8ZGFyayUyMGZvcmVzdHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60"),
                  child: Text(
                    results[index].type.startsWith("m") ? "M" : "B",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                children: results[index].allAnswers.map((m) {
                  return AnswerWidget(results: results, index: index, m: m);
                }).toList(),
              ),
            ));
  }
}

class AnswerWidget extends StatefulWidget {
  final List<Results> results;
  final int index;
  final String m;

  AnswerWidget({Key key, this.results, this.index, this.m}) : super(key: key);
  @override
  _AnswerWidgetState createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  Color c = Colors.black;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          if (widget.m == widget.results[widget.index].correctAnswer) {
            c = Colors.green;
          } else {
            c = Colors.red;
          }
        });
      },
      title: Text(
        widget.m,
        textAlign: TextAlign.center,
        style: TextStyle(color: c, fontWeight: FontWeight.bold),
      ),
    );
  }
}
