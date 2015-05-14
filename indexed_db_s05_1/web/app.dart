import 'package:indexed_db/indexed_db.dart';

main() async {
  var tasksDb = new TasksDb();
  await tasksDb.open();
  TasksStore tasksStore = tasksDb.tasksStore;
  var tasksView = new TasksView(tasksStore);
  tasksView.loadElements(tasksStore.tasks);
  /*  
  tasksDb.open().then((_) {
    TasksStore tasksStore = tasksDb.tasksStore;
    var tasksView = new TasksView(tasksStore);
    tasksView.loadElements(tasksStore.tasks);
  });*/
}