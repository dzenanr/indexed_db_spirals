import 'package:indexed_db/indexed_db.dart';

main() {
  var tasksStore = new TasksStore();
  var tasksView = new TasksView(tasksStore);
  tasksStore.open().then((_) {
    tasksView.loadElements(tasksStore.tasks);
  });
}