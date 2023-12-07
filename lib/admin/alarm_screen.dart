import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playbus/admin/petinfolist_screen.dart';
import 'package:playbus/admin/profile_screen.dart';

import 'friendboard_screen.dart';
import 'home_screen.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  TextEditingController messageController = TextEditingController();
  int _selected = 0;

  Future<void> sendNotification(String message) async {
    final url = 'https://fcm.googleapis.com/fcm/send';
    final serverKey =
        'AAAAPl6oIbs:APA91bH6AVywOsA6Qd8w5M5BMkhmvbDPmTQaYA6nO46F04cBsrSQxxGldCguLVvmiRCA14rb7vnrnqrKX_EeR3spqGr6Y6FuY8QcLJq5EHPT4R4H34OvpmnkQmc7jCuIdo5bbdq4fjjL'; // 이건 안건드려도 됩니다
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final List<String> tokens = [
      'fpvh-CGNT0KGnJrhddbu99:APA91bHtcJvUS33s1P73gihcoiiD_Hbekxw1nvZI0JpxSPOKvMfMdQENBbkUSrV7_mN-FH_mPyGgrGGAtzTJ2KSTW8PSvLcrGNmmQ6iTp-6dhsCi1NoZ1b1m5cXM-NfSV98qYaR3gP1U',
      'eN80FEWhTPebQ1peCR4Xcg:APA91bGq2M0z-V8VFeW2aanS-v5UxtL_1V0-wF72SZyVZTzOjADbHrFMiSrG7tnrsRCywJ8_rTF0V0kmNBH_YyVCCbE4eHx5X_peRFVQpFABNEczEhY06HbtxePBV107KBlUNBbqmjb3',
      'ccCdvJR6rqoAOfOFOOiJez:APA91bE2Da9EkOsD0ioXOrQwuQhlIfYw372UMJaZtggzBlhS31WfKQQJ0T9ZFnPwyR5trElZpGPFl7S1w1_KrAu1F6xF0pmvVc1VyETRnuMZpi7NRFO83Q6Vuz_DKGngtydJuLTwHFOj'
    ];

    final body = {
      'registration_ids': tokens,
      'notification': {
        'title': 'New Message',
        'body': message,
      },
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully.');

      await FirebaseFirestore.instance.collection('notifications').add({
        'message': message,
        'timestamp': DateTime.now(),
      });
    } else {
      print('Failed to send notification. Error: ${response.body}');
    }
  }

  Future<void> deleteNotification(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(documentId)
          .delete();
      print('Notification deleted successfully.');
    } catch (e) {
      print('Failed to delete notification. Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('알림 전송'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey,
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
            // Navigation page
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.send),
              label: Text('오늘 산책을 하셨나요?'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              onPressed: () {
                sendNotification('오늘 산책을 하셨나요?');
              },
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.send),
              label: Text('산책할 때 좋은 물건들 보실래요?'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              onPressed: () {
                sendNotification('산책할 때 좋은 물건들 보실래요?');
              },
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.send),
              label: Text('매너글 게시 부탁드립니다'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              onPressed: () {
                sendNotification('매너글 게시 부탁드립니다');
              },
            ),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: '직접 보낼 텍스트를 입력하세요',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text('직접 보내기'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              onPressed: () {
                String message = messageController.text;
                sendNotification(message);
              },
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text('No Data');
                  }

                  final documents = snapshot.data?.docs;

                  return ListView.builder(
                    itemCount: documents?.length ?? 0,
                    itemBuilder: (context, index) {
                      dynamic notification = documents?[index].data();
                      String? documentId = documents?[index].id;

                      return ListTile(
                        title: Text(notification?['message'] ?? ''),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteNotification(documentId!);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
