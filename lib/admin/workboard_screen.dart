import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playbus/admin/friendboard_screen.dart';
import 'package:playbus/admin/home_screen.dart';
import 'package:playbus/admin/petinfolist_screen.dart';
import 'package:playbus/admin/profile_screen.dart';
import '../components/my_container.dart';
import '../components/my_textfield.dart';
import '../components/wall_post.dart';
import 'alarm_screen.dart';

const seedColor = Color(0xff00ffff);
const outPadding = 32.0;

class DynamicColorDemo extends StatelessWidget {
  const DynamicColorDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: seedColor,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.notoSansNKoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}

class workboardPage extends StatefulWidget {
  const workboardPage({Key? key}) : super(key: key);

  @override
  State<workboardPage> createState() => _boardPageState();
}

class _boardPageState extends State<workboardPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();
  File? _image;
  String? imageName;
  int _selected = 0;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image != null) {
      try {
        imageName = DateTime.now().millisecondsSinceEpoch.toString();
        final Reference storageReference = FirebaseStorage.instance.ref().child('images/$imageName');
        final UploadTask uploadTask = storageReference.putFile(_image!);
        await uploadTask.whenComplete(() {
          print('Image uploaded');
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void postMessage() {
    if (textController.text.isNotEmpty) {
      _uploadImage().then((_) {
        FirebaseFirestore.instance.collection("work Posts").add({
          "UserEmail": currentUser.email,
          'Message': textController.text,
          'TimeStamp': Timestamp.now(),
          'Likes': [],
          'ImageURL': _image != null ? 'images/$imageName' : null,
        });

        setState(() {
          textController.clear();
          _image = null;
          imageName = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hide the back button
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [Colors.grey, Colors.lightBlueAccent], // Adjust colors as needed
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => friendboardPage()),
                  );
                },
                child: Text('산책 친구'),
                style: TextButton.styleFrom(primary: Colors.black),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {},
                child: Text('산책 알바'),
                style: TextButton.styleFrom(primary: Colors.black),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.lightBlueAccent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selected,
        elevation: 0,
        onTap: (selected) {
          setState(() {
            _selected = selected;
          });
          switch (_selected) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PetInfoListPage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
              break;
            case 4:
              break;
          }
        },
        selectedItemColor: Theme.of(context).colorScheme.onPrimaryContainer,
        unselectedItemColor: Theme.of(context).colorScheme.onPrimaryContainer,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "",
              backgroundColor: Colors.transparent),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "",
              backgroundColor: Colors.transparent),
          BottomNavigationBarItem(
              icon: Icon(Icons.text_snippet),
              label: "",
              backgroundColor: Colors.transparent),
          BottomNavigationBarItem(
              icon: Icon(Icons.notification_add),
              label: "",
              backgroundColor: Colors.transparent),
          BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_outlined),
              label: "",
              backgroundColor: Colors.transparent),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("work Posts")
                  .orderBy("TimeStamp", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final post = snapshot.data!.docs[index];
                      return WallPost(
                        messsage: post['Message'],
                        user: post['UserEmail'],
                        postId: post.id,
                        likes: List<String>.from(post['Likes'] ?? []),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: textController,
                    hintText: '입력하세요',
                    obscureText: false,
                  ),
                ),
                IconButton(
                  onPressed: postMessage,
                  icon: Icon(Icons.arrow_circle_up),
                ),
                IconButton(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WallPost extends StatefulWidget {
  final String messsage;
  final String user;
  final String postId;
  final List<String> likes;

  const WallPost({
    Key? key,
    required this.messsage,
    required this.user,
    required this.postId,
    required this.likes,
  }) : super(key: key);

  @override
  _WallPostState createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  TextEditingController editController = TextEditingController();
  bool isEditing = false;
  bool liked = false;

  @override
  Widget build(BuildContext context) {
    return MyContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isEditing
              ? TextField(
            controller: editController,
            decoration: InputDecoration(
              hintText: '수정 사항을 입력해주세요',
            ),
          )
              :Text(widget.messsage),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('작성자: ${widget.user}'),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_up),
                    onPressed: () {
                      // Handle liking the post
                      setState(() {
                        liked = !liked;
                      });
                    },
                    color: liked ? Colors.blue : Colors.blue,
                  ),
                  Text(widget.likes.length.toString()),
                  // Modify and delete buttons
                  isEditing
                      ? IconButton(
                    icon: Icon(Icons.done),
                    onPressed: () {
                      // Handle update action
                      FirebaseFirestore.instance.collection("work Posts").doc(widget.postId).update({
                        'Message': editController.text,
                      });
                      setState(() {
                        isEditing = false;
                      });
                    },
                    color: Colors.green,
                  )
                      : IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Handle modify action
                      setState(() {
                        editController.text = widget.messsage;
                        isEditing = true;
                      });
                    },
                    color: Colors.black,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Handle delete action
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('게시글을 삭제하시겠습니까?'),
                            content: Text('정말로 삭제 하시겠습니까?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('취소'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Perform the delete action
                                  FirebaseFirestore.instance.collection("work Posts").doc(widget.postId).delete();
                                  Navigator.pop(context);
                                },
                                child: Text('삭제'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
