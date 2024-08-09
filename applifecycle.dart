// ignore_for_file: prefer_const_constructors_in_immutables, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:iu_nav_bus/fireAuth_service.dart';
import 'package:iu_nav_bus/main.dart';

class LifeCycleManager extends StatefulWidget {
  LifeCycleManager({required Key key, required this.child}) : super(key: key);

  final Widget child;

  @override
  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('AppLifecycleState: $state');
    if (state == AppLifecycleState.paused) {
      print('AppLifecycleState state: Paused');
      // Update user online status to offline
      updateUserStatus("false");
      updateUserOnlineStatus(false);
    } else if (state == AppLifecycleState.resumed) {
      print('AppLifecycleState state: Resumed');
      // Update user online status to online
      updateUserStatus("true");
      updateUserOnlineStatus(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void updateUserOnlineStatus(bool isOnline) {
    // Implement your logic to update user online status in Firestore or Supabase
  }

  void updateUserStatus(String status) {
    var user = supabase.auth.currentUser;

    if (user != null) {
      var email = supabase.auth.currentUser!.email;
      updateUserStatusOnFireStore(
        context,
        status,
        email!,
      );
    }
  }
}
