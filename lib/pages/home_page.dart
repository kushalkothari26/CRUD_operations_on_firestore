import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/services/firestore.dart';
import 'package:flutter/material.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final FirestoreService firestoreService=FirestoreService();

  final TextEditingController textController=TextEditingController();

  void openNoteBox({String? docID}){
    showDialog(context: context, builder:(context)=>AlertDialog(
      content: TextField(
        controller: textController,
      ),
      actions: [
        ElevatedButton(onPressed: (){
          if(docID==null){
            firestoreService.addNote(textController.text);
          }
          else{
            firestoreService.updateNote(docID, textController.text);
          }
          textController.clear();
          Navigator.pop(context);
        }, child: const Text("Add"))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes")),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder:(context,snapshot){
          if(snapshot.hasData){
            List notesList=snapshot.data!.docs;

            return ListView.builder(itemCount: notesList.length,itemBuilder: (context,index){
              DocumentSnapshot document=notesList[index];
              String docID=document.id;

              Map<String,dynamic>data=
                  document.data() as Map<String,dynamic>;
              String noteText = data['note'];

              return ListTile(
                title: Text(noteText),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: ()=>openNoteBox(docID:docID),
                        icon: Icon(Icons.edit)
                    ),
                    IconButton(
                        onPressed: ()=>firestoreService.deleteNote(docID),
                        icon: Icon(Icons.delete)
                    ),
                  ],
                )
              );
            }
            );
          }

          else{
            return const Text("No Notes");
          }
        }
      ),
    );
  }
}
