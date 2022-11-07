// import 'dart:html';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:training_app/screens/exercise_details_screen.dart';
import 'package:training_app/widgets/add_exercise_dialog.dart';

class CertainGroupScreen extends StatefulWidget {

  final String title;

  // const constructors can be used when all initialized variables are final
  const CertainGroupScreen(this.title);

  @override
  State<CertainGroupScreen> createState() => _CertainGroupScreenState(title);
}

class _CertainGroupScreenState extends State<CertainGroupScreen> {
  bool isFetched = false;
  late List<Map> documents = [];
  late final String appBarTitle;
  late String id;
  late List<String> searches = [];
  _CertainGroupScreenState(String text) {
    this.appBarTitle = text;
    this.id = FirebaseAuth.instance.currentUser!.uid;
    fetchData();
  }

  void refresh() {
    setState(() {
      fetchData();
      getSearches();
    });
  }

  void getSearches() async {
    List<String> search = [];
    var stream1 = await FirebaseFirestore.instance
        .collection('exercises/$appBarTitle/excersises')
        .get();
    var stream2 = await FirebaseFirestore.instance
        .collection('users/$id/exercises/$appBarTitle/exercises')
        .get();

    stream1.docs.forEach((element) {
      search.add(element['name']);
    });

    stream2.docs.forEach((element) {
      search.add(element['name']);
    });

    search.sort(((a, b) => a.compareTo(b)));
    this.searches = search;
    print(search);
  }

  void fetchData() async {
    this.documents.clear();
    var stream1 = await FirebaseFirestore.instance
        .collection('exercises/$appBarTitle/excersises')
        .get();
    var stream2 = await FirebaseFirestore.instance
        .collection('users/$id/exercises/$appBarTitle/exercises')
        .get();

    stream1.docs.forEach((element) {
      this.documents.add(element.data());
    });

    stream2.docs.forEach((element) {
      this.documents.add(element.data());
    });

    this.documents.sort(((a, b) => a['name'].compareTo(b['name'])));
    setState(() {
      isFetched = true;
    });
  }

  @override
  void initState() {
    super.initState();
    getSearches();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              automaticallyImplyLeading: Platform.isAndroid ? false : true,
              floating: false,
              pinned: true,
              flexibleSpace: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                        left: Platform.isIOS
                            ? MediaQuery.of(context).size.width * 0.07
                            : MediaQuery.of(context).size.width * 0.02),
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: FlexibleSpaceBar(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            flex: 0,
                            child: Text(
                              appBarTitle,
                              style: GoogleFonts.roboto(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: 30),
                            ),
                          )
                        ],
                      ),
                      titlePadding: EdgeInsets.zero,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                AddExerciseDialog(appBarTitle, refresh));
                      },
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(context).secondaryHeaderColor,
                      )),
                  IconButton(
                      onPressed: () {
                        showSearch(
                            context: context,
                            delegate: MuscleGroupDelegate(searches, id));
                      },
                      icon: Icon(
                        Icons.search,
                        color: Theme.of(context).secondaryHeaderColor,
                      )),
                ],
              ),
              expandedHeight: MediaQuery.of(context).size.height * 0.2,
            ),
            // StreamBuilder(
            //   stream: FirebaseFirestore.instance
            //       .collection('exercises/$appBarTitle/excersises')
            //       .snapshots(),
            //   builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting)
            //       return const SliverToBoxAdapter(
            //         child: Center(child: CircularProgressIndicator()),
            //       );
            //     var documents = snapshot.data!.docs;
            //     documents.sort(
            //       (a, b) => (a['name'].compareTo(b['name'])),
            //     );

            //     return SliverList(
            //       delegate: SliverChildBuilderDelegate((context, index) {
            //         return ListTile(
            //           onTap: () async {
            //             String name = documents[index]['name'];
            //             var docs = await FirebaseFirestore.instance
            //                 .collection(
            //                     'users/$id/exercisesPerformed/$name/history')
            //                 .get();
            //             List<Map<String, dynamic>> allData =
            //                 docs.docs.map((doc) => doc.data()).toList();
            //             if (allData.isEmpty)
            //               allData = [
            //                 {'name': documents[index]['name']}
            //               ];
            //             else
            //               allData
            //                   .sort((a, b) => (a['date'].compareTo(b['date'])));
            //             print(allData);
            //             print(documents[index]['type']);
            //             Navigator.of(context).push(MaterialPageRoute(
            //                 builder: ((context) => ExerciseDetailsScreen(
            //                     allData, documents[index]))));
            //           },
            //           title: Text(documents[index]['name']),
            //         );
            //       }, childCount: documents.length),
            //     );
            //   },
            // ),
            // StreamBuilder(
            //   stream: FirebaseFirestore.instance
            //       .collection('users/$id/exercises/$appBarTitle/exercises')
            //       .snapshots(),
            //   builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            //     Stream stream = FirebaseFirestore.instance.collection('exercises/$appBarTitle/excersises').snapshots();

            //     if (snapshot.connectionState == ConnectionState.waiting)
            //       return const SliverToBoxAdapter(
            //         child: Center(child: CircularProgressIndicator()),
            //       );
            //     var docs = snapshot.data!.docs;
            //     docs.sort(
            //       (a, b) => (a['name'].compareTo(b['name'])),
            //     );

            //     return SliverList(
            //       delegate: SliverChildBuilderDelegate((context, index) {
            //         return ListTile(
            //           title: Text(docs[index]['name']),
            //         );
            //       }, childCount: docs.length),
            //     );
            //   },
            // )
            isFetched
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ListTile(
                        onTap: () async {
                          String name = documents[index]['name'];
                          var docs = await FirebaseFirestore.instance
                              .collection(
                                  'users/$id/exercisesPerformed/$name/history')
                              .get();
                          List<Map<String, dynamic>> allData =
                              docs.docs.map((doc) => doc.data()).toList();
                          if (allData.isEmpty)
                            allData = [
                              //   {'name': documents[index]['name']}
                            ];
                          else
                            allData.sort(
                                (a, b) => (a['date'].compareTo(b['date'])));
                          print(allData);
                          print(documents[index]['type']);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: ((context) =>
                                  ExerciseDetailsScreen(allData, name))));
                        },
                        title: Text(documents[index]['name']),
                      );
                    },
                    childCount: documents.length,
                  ))
                : SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  )
          ],
        ),
      ),
    );
  }
}

class MuscleGroupDelegate extends SearchDelegate {
  late List<String> searches = [];
  late String id;
  MuscleGroupDelegate(this.searches, this.id) {}

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
            onPressed: () {
              if (query.isEmpty) {
                close(context, null);
              } else {
                query = '';
              }
            },
            icon: const Icon(Icons.clear)),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null), //closing searchbar
      );

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder(
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        var docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Container(
            child: Text(''),
          );
        }

        List<Map<String, dynamic>> allData = [];
        docs.forEach((element) {
          allData.add(element as Map<String, dynamic>);
        });
        //      docs.map((e) => e.data()).toList() as List<Map<String, dynamic>>;

        if (allData.isEmpty)
          allData = [
            //   {'name': documents[index]['name']}
          ];
        else
          allData.sort((a, b) => (a['date'].compareTo(b['date'])));

        Navigator.of(context).push(MaterialPageRoute(
            builder: ((context) => ExerciseDetailsScreen(allData, query))));
        return ExerciseDetailsScreen(allData, query);
      },
      stream: FirebaseFirestore.instance
          .collection('users/$id/exercisesPerformed/$query/history')
          .snapshots(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = searches.where(((element) {
      return element.toLowerCase().contains(query.toLowerCase());
    }));

    if (this.searches.length < 1) {
      return Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: suggestions.length,
      itemBuilder: ((context, index) {
        return ListTile(
          title: Text(suggestions.elementAt(index)),
          onTap: () {
            query = suggestions.elementAt(index);
          },
        );
      }),
    );
  }
}


//trzeba zablokowac mozliwosc dodania samej spacji do cwiczen
// i dodac mozliwosc ich usuniecia