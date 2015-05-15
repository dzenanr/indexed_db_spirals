part of indexed_db;

class TasksDb {
  static const String TASKS_DB = 'todoDb';
  static const String TASKS_STORE = 'tasksStore';
  
  var _store;
  TasksStore _tasksStore;
  
  TasksStore get tasksStore => _tasksStore;
  
  Future open() async {
    _store = await Store.open(TASKS_DB, TASKS_STORE);
    await _loadDb();
  }
  
  Future _loadDb() async {
    _tasksStore = new TasksStore(_store);
    await _tasksStore.load();
  }
}

class TasksStore {
  final _store;
  final Tasks _tasks = new Tasks();

  TasksStore(this._store);
  
  Tasks get tasks => _tasks;
  bool get isEmpty => tasks.length == 0;
  
  Future load() async {
    await for (var taskJsonString in _store.all()) {
      var task = new Task();
      task.fromJsonString(taskJsonString);
      tasks.add(task);
    } 
  }
  
  Future<Task> add(String title) async {
    var task = new Task.id(title);
    var foundTask = tasks.find(title);
    if (foundTask == null) {
      await _store.save(task.toJsonString(), task.title);
      tasks.add(task);
    } else {
      task == null;
      throw new IdException('${title} title is not unique.');
    }
    return task;
  }
  
  Future update(Task task, String beforeTitle) async {
    if (task.title == beforeTitle) {
      await _store.save(task.toJsonString(), task.title);
    } else {
      int count = tasks.count(task.title);
      if (count > 1) {
        throw new IdException('${task} title is not unique.');
      } else {
        await _store.removeByKey(beforeTitle);
        await _store.save(task.toJsonString(), task.title);  
      }
    }   
  }
  
  Future completeActive() async {
    Tasks activeTasks = tasks.active;
    for (var task in activeTasks) {
      task.isCompleted = true;
      task.whenUpdated = new DateTime.now();
      await update(task, task.title);  
    }
  }

  Future<bool> remove(Task task) async {
    await _store.removeByKey(task.title);
    return tasks.remove(task);
  }
  
  Future<bool> removeCompleted() async {
    bool removedAllCompleted = true;
    Tasks completedTasks = tasks.completed;
    for (var task in completedTasks) {
      if (! await remove(task)) {
        removedAllCompleted = false;
      }
    }
    return removedAllCompleted;
  }

  Future clear() async {
    await _store.nuke();
    tasks.clear();
  }  
}