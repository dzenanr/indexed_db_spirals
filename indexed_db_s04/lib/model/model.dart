part of indexed_db;

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

  Task.fromDbWoutKey(Map value):
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
  static const String TITLE_INDEX = 'titleIndex';

  final List<Task> tasks = new List();
  Database _db;

  List<Task> get completed {
    var completed = new List<Task>();
    for (var task in tasks) {
      if (task.completed) {
        completed.add(task);
      }
    }
    return completed;
  }

  List<Task> get active {
    var active = new List<Task>();
    for (var task in tasks) {
      if (!task.completed) {
        active.add(task);
      }
    }
    return active;
  }

  Future open() {
    return window.indexedDB
      .open('tasksDb03', version: 1, onUpgradeNeeded: _initDb)
      .then(_loadDb);
  }

  void _initDb(VersionChangeEvent e) {
    var db = (e.target as Request).result;
    var store = db.createObjectStore(TASKS_STORE, autoIncrement: true);
    store.createIndex(TITLE_INDEX, 'title', unique: true);
  }

  Future<int> _loadDb(Database db) {
    _db = db;
    var trans = db.transaction(TASKS_STORE, 'readonly');
    var store = trans.objectStore(TASKS_STORE);

    var cursor = store.openCursor(autoAdvance: true).asBroadcastStream();
    cursor.listen((cursor) {
      var task = new Task.fromDb(cursor.key, cursor.value);
      tasks.add(task);
    });
    return cursor.length
      .then((_) {
        return tasks.length;
      });
  }

  Future<Task> add(String title) {
    var task = new Task(title);
    var taskMap = task.toDb();

    var trans = _db.transaction(TASKS_STORE, 'readwrite');
    var store = trans.objectStore(TASKS_STORE);

    var future = store.add(taskMap)
      .then((addedKey) {
        task.key = addedKey;
        tasks.add(task);
      });
    return future
      .then((_) {
        return task;
      });
  }

  Future update(Task task) {
    var taskMap = task.toDb();
    var trans = _db.transaction(TASKS_STORE, 'readwrite');
    var future = trans.objectStore(TASKS_STORE).put(taskMap, task.key);
    return future;
  }

  Future<Task> find(String title) {
    var trans = _db.transaction(TASKS_STORE, 'readonly');
    var store = trans.objectStore(TASKS_STORE);
    var index = store.index(TITLE_INDEX);
    var future = index.get(title);
    return future
      .then((taskMap) {
        var task = new Task.fromDbWoutKey(taskMap);
        return task;
      });
  }

  Future complete() {
    Future future;
    for (var task in tasks) {
      if (!task.completed) {
        task.completed = true;
        task.updated = new DateTime.now();
        future = update(task);
      }
    }
    return future;
  }

  Future remove(Task task) {
    var trans = _db.transaction(TASKS_STORE, 'readwrite');
    trans.objectStore(TASKS_STORE).delete(task.key);
    return trans.completed
      .then((_) {
        task.key = null;
        tasks.remove(task);
      });
  }

  Future removeCompleted() {
    Future future;
    for (var task in tasks) {
      if (task.completed) {
        future = remove(task);
      }
    }
    return future;
  }

  Future clear() {
    var trans = _db.transaction(TASKS_STORE, 'readwrite');
    trans.objectStore(TASKS_STORE).clear();
    return trans.completed
      .then((_) {
        tasks.clear();
      });
  }
}