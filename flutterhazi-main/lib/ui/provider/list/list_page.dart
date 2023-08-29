import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_homework/ui/provider/list/list_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login/login_model.dart';

class ListPageProvider extends StatefulWidget {
  const ListPageProvider({Key? key}) : super(key: key);

  @override
  State<ListPageProvider> createState() => _ListPageProviderState();
}

class _ListPageProviderState extends State<ListPageProvider> {
  ListModel listModel = ListModel();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _initializePage());
  }

  void _initializePage() async {
    await listModel.loadUsers();
  }

  void _logout(BuildContext context) {
    listModel.removeToken();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: FutureBuilder(
        future: listModel.loadUsers(),
        builder: (context, snapshot) {
          if (listModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError && snapshot.error is ListException) {
            final ListException error = snapshot.error as ListException;
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              // A SnackBar megjelenítése a ListException hibaüzenettel
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error.message)),
              );
            });
            return SizedBox.shrink(); // Megjelenítés nélküli konténer
          } else {
            return ListView.builder(
              itemCount: listModel.users.length,
              itemBuilder: (context, index) {
                final user = listModel.users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.avatarUrl),
                  ),
                  title: Text(user.name),
                );
              },
            );
          }
        },
      ),
    );
  }

}
