import 'package:indexed_db/indexed_db.dart';

main() {
  var tasksDb = new TasksDb();
  tasksDb.open().then((_) {
    TasksStore tasksStore = tasksDb.tasksStore;
    var tasksView = new TasksView(tasksStore);
    tasksView.loadElements(tasksStore.tasks);
  });
}