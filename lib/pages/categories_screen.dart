import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_list/dialogs/add_category_dialog.dart';
import 'package:flutter_todo_list/dialogs/google_sign_in.dart';
import 'package:flutter_todo_list/pages/tasks_screen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String userID = '';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    userID = user.uid;
    final dbCategories = FirebaseFirestore.instance
        .collection('userCategories')
        .doc(userID)
        .collection('categories');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cписок дел'),
        actions: [
          IconButton(
              onPressed: () {
                final provider =
                    Provider.of<GoogleSignInProvider>(context, listen: false);
                provider.googleLogout();
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: StreamBuilder(
        stream: dbCategories.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text(
              'Список категорий пуст',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ));
          } else {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  int length = (snapshot.data!.docs[index].get('all') as int);
                  int ready = (snapshot.data!.docs[index].get('ready') as int);
                  double percent = ready / (length == 0 ? 1 : length);
                  return Dismissible(
                    key: Key(snapshot.data!.docs[index].id),
                    child: Card(
                      elevation: 5,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TasksScreen(
                                    categoryID: snapshot.data!.docs[index].id,
                                    userID: userID),
                              ));
                        },
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                getIcon(snapshot.data!.docs[index].get('icon')),
                                color: const Color(0xFF082427),
                                size: 40,
                              ),
                              title: Text(
                                snapshot.data!.docs[index].get('categoryTitle'),
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text('Осталось: ${length - ready}'),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Color(0xFF082427),
                                ),
                                onPressed: () {
                                  deleteCategory(snapshot.data!.docs[index].id);
                                },
                              ),
                            ),
                            LinearPercentIndicator(
                              lineHeight: 20.0,
                              percent: percent,
                              center: Text(
                                "${(percent * 100.0).toStringAsFixed(1)}%",
                                style: const TextStyle(
                                    fontSize: 15.0, color: Colors.white),
                              ),
                              barRadius: const Radius.circular(10),
                              backgroundColor: const Color(0xFFB0AEB3),
                              progressColor: const Color(0xFF082427),
                            ),
                            const Padding(padding: EdgeInsets.only(bottom: 20)),
                          ],
                        ),
                      ),
                    ),
                    onDismissed: (direction) {
                      deleteCategory(snapshot.data!.docs[index].id);
                    },
                  );
                });
          }
        },
      ),
      floatingActionButton: AddCategoryDialog(userID: userID),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  IconData getIcon(String name) {
    IconData res = Icons.task;
    for (final IconLabel icon in IconLabel.values) {
      if (icon.label == name) res = icon.icon;
    }
    return res;
  }

  void deleteCategory(String id) {
    final dbCategories = FirebaseFirestore.instance
        .collection('userCategories')
        .doc(userID)
        .collection('categories');
    dbCategories.doc(id).delete();
    FirebaseFirestore.instance
        .collection('userTasks')
        .doc(userID.toString())
        .collection('categories')
        .doc(id)
        .collection('tasks')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }
}
