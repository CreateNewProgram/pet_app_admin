import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playbus/admin/profile_screen.dart';

import 'alarm_screen.dart';
import 'friendboard_screen.dart';
import 'home_screen.dart';

class PetInfoListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('애완동물 정보 목록'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('petinfo').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final petData = documents[index].data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text('보호자 성명: ${petData['guardianName']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('전화번호: ${petData['phoneNumber']}'),
                      Text('아이 이름: ${petData['petName']}'),
                      Text('아이 품종: ${petData['breed']}'),
                      Text('아이 나이: ${petData['age']}'),
                      Text('아이 성별: ${petData['gender']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Handle modify action
                          // You can open a dialog or navigate to a new screen for modification
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
                                title: Text('삭제하시겠습니까?'),
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
                                      _firestore.collection('petinfo').doc(documents[index].id).delete();
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
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        elevation: 0,
        onTap: (selected) {
          // Handle navigation based on the selected tab
          switch (selected) {
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
            // Currently on PetInfoListPage
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => friendboardPage()),
              );
              break;
          }
        },
        selectedItemColor: Theme.of(context).colorScheme.onPrimaryContainer,
        unselectedItemColor: Theme.of(context).colorScheme.onPrimaryContainer,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "",
            backgroundColor: Colors.transparent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "",
            backgroundColor: Colors.transparent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_snippet),
            label: "",
            backgroundColor: Colors.transparent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_add),
            label: "",
            backgroundColor: Colors.transparent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper_outlined),
            label: "",
            backgroundColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
}
