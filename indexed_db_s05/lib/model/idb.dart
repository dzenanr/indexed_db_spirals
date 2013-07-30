part of indexed_db;

class TasksDb {
  static const String TASKS_STORE = 'tasksStore';
  static const String TITLE_INDEX = 'titleIndex';

  Database _db;
  TasksStore _tasksStore;

  Database get db => _db;
  TasksStore get tasksStore => _tasksStore;

  Future open() {
    return window.indexedDB.open('tasksDb03',
        version: 1,
        onUpgradeNeeded: _initDb)
      .then(_loadDb);
  }

  void _initDb(VersionChangeEvent e) {
    var db = (e.target as Request).result;
    var store = db.createObjectStore(TASKS_STORE, autoIncrement: true);
    store.createIndex(TITLE_INDEX, 'title', unique: true);
  }

  Future<int> _loadDb(Database db) {
    _db = db;
    _tasksStore = new TasksStore(this);
    return _tasksStore.load();
  }
}

class TasksStore {
  static const String READ_ONLY = 'readonly';
  static const String READ_WRITE = 'readwrite';

  final TasksDb todo;
  final Tasks tasks = new Tasks();

  TasksStore(this.todo);

  Future<int> load() {
    var trans = todo.db.transaction(TasksDb.TASKS_STORE, READ_ONLY);
    var store = trans.objectStore(TasksDb.TASKS_STORE);
    var cursor = store.openCursor(autoAdvance: true).asBroadcastStream();
    cursor.listen((cursor) {
      var task = new Task.fromDb(cursor.key, cursor.value);
      tasks.add(task);
    });
    return cursor.length.then((_) {
      return tasks.length;
    });
  }

  Future<Task> add(String title) {
    var task = new Task(title);
    var taskMap = task.toDb();

    var trans = todo.db.transaction(TasksDb.TASKS_STORE, READ_WRITE);
    var store = trans.objectStore(TasksDb.TASKS_STORE);
    var future = store.add(taskMap).then((addedKey) {
      task.key = addedKey;
      tasks.add(task);
    });
    return future.then((_) {
      return task;
    });
  }

  Future update(Task task) {
    var taskMap = task.toDb();
    var trans = todo.db.transaction(TasksDb.TASKS_STORE, READ_WRITE);
    var store = trans.objectStore(TasksDb.TASKS_STORE);
    var future = store.put(taskMap, task.key);
    return future;
  }

  Future<Task> find(String title) {
    var trans = todo.db.transaction(TasksDb.TASKS_STORE, READ_ONLY);
    var store = trans.objectStore(TasksDb.TASKS_STORE);
    var future = store.index(TasksDb.TITLE_INDEX).get(title);
    return future.then((taskMap) {
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
    var trans = todo.db.transaction(TasksDb.TASKS_STORE, READ_WRITE);
    var store = trans.objectStore(TasksDb.TASKS_STORE);
    store.delete(task.key);
    return trans.completed.then((_) {
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
    var trans = todo.db.transaction(TasksDb.TASKS_STORE, READ_WRITE);
    var store = trans.objectStore(TasksDb.TASKS_STORE);
    store.clear();
    return trans.completed.then((_) {
      tasks.clear();
    });
  }
}