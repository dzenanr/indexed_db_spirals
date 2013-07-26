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
    completed = value['completed'] == 'true' ? true : false {
  }

  Map toDb() {
    return {
      'title': title,
      'completed': completed.toString(),
      'updated': updated.toString()
    };
  }
}

class TaskStore {
  static const String TASK_STORE = 'taskStore';
  static const String TITLE_INDEX = 'titleIndex';

  final List<Task> tasks = new List();
  Database _db;

  Future open() {
    return window.indexedDB.open('taskDb',
        version: 1,
        onUpgradeNeeded: _initDb)
      .then(_loadDb);
  }

  void _initDb(VersionChangeEvent e) {
    var db = (e.target as Request).result;
    var objectStore = db.createObjectStore(TASK_STORE,
        autoIncrement: true);
    objectStore.createIndex(TITLE_INDEX, 'title', unique: true);
  }

  Future _loadDb(Database db) {
    _db = db;
    var trans = db.transaction(TASK_STORE, 'readonly');
    var store = trans.objectStore(TASK_STORE);

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

    var transaction = _db.transaction(TASK_STORE, 'readwrite');
    var objectStore = transaction.objectStore(TASK_STORE);

    objectStore.add(taskMap).then((addedKey) {
      task.key = addedKey;
    });

    return transaction.completed.then((_) {
      tasks.add(task);
      return task;
    });
  }

  Future remove(Task task) {
    var transaction = _db.transaction(TASK_STORE, 'readwrite');
    transaction.objectStore(TASK_STORE).delete(task.key);

    return transaction.completed.then((_) {
      task.key = null;
      tasks.remove(task);
    });
  }

  Future clear() {
    var transaction = _db.transaction(TASK_STORE, 'readwrite');
    transaction.objectStore(TASK_STORE).clear();

    return transaction.completed.then((_) {
      tasks.clear();
    });
  }
}