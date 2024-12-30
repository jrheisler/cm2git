import 'package:cm_2_git/services/singleton_data.dart';
import 'package:cm_2_git/services/state_manager_registry.dart';
import 'package:cm_2_git/views/kanban_view.dart';
import 'package:flutter/material.dart';


final SMReg smReg = SMReg();
late SingletonData singletonData;


void main() async{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    singletonData = setSingles();
    singletonData.version = '.175';

    return MaterialApp(
      debugShowCheckedModeBanner: singletonData.kDebugMode,
      title: 'cm2git v ${singletonData.version}',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: singletonData.kPrimaryColor),
        useMaterial3: true,
      ),
      home: const KanbanBoardScreen(),
    );
  }
}
