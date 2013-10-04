import 'dart:async';
import 'dart:html';
import 'dart:indexed_db';

class Task {
  String title;
  bool completed = false;
  DateTime updated = new DateTime.now();
  var key;

  Task(this.title);

  Task.fromDb(this.key, Map value):
    title = value['title'],
    updated = DateTime.parse(value['updated']),
    completed = value['completed'] == 'true' {
  }

  Map toDb() {
    return {
      'title': title,
      'completed': completed.toString(),
      'updated': updated.toString()
    };
  }
}

class TasksStore {
  static const String TASKS_STORE = 'tasksStore';

  final List<Task> tasks = new List();
  Database _db;

  Future open() {
    return window.indexedDB.open('tasksDb00',
        version: 1,
        onUpgradeNeeded: _initDb)
      .then(_loadDb);
  }

  void _initDb(VersionChangeEvent e) {
    var db = (e.target as Request).result;
    var objectStore = db.createObjectStore(TASKS_STORE, autoIncrement: true);
  }

  Future _loadDb(Database db) {
    _db = db;
    var trans = db.transaction(TASKS_STORE, 'readonly');
    var store = trans.objectStore(TASKS_STORE);

    var cursors = store.openCursor(autoAdvance: true).asBroadcastStream();
    cursors.listen((cursor) {
      var task = new Task.fromDb(cursor.key, cursor.value);
      tasks.add(task);
    });
    return cursors.length.then((_) {
      return tasks.length;
    });
  }

  Future<Task> add(String title) {
    var task = new Task(title);
    var taskMap = task.toDb();

    var transaction = _db.transaction(TASKS_STORE, 'readwrite');
    var objectStore = transaction.objectStore(TASKS_STORE);

    objectStore.add(taskMap).then((addedKey) {
      task.key = addedKey;
    });

    return transaction.completed.then((_) {
      tasks.add(task);
      return task;
    });
  }

  Future clear() {
    var transaction = _db.transaction(TASKS_STORE, 'readwrite');
    transaction.objectStore(TASKS_STORE).clear();

    return transaction.completed.then((_) {
      tasks.clear();
    });
  }
}