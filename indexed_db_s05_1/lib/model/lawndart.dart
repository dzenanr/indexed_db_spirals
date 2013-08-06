part of indexed_db;

class TasksDb {
  static const String TASKS_DB = 'todoDb';
  static const String TASKS_STORE = 'tasksStore';
  
  var _store = new Store(TASKS_DB, TASKS_STORE);
  TasksStore _tasksStore;
  
  TasksStore get tasksStore => _tasksStore;
  
  Future open() {
    Completer completer = new Completer();
    _store.open()
      .then((_) {
        _loadDb()
          .then((_) {
            completer.complete();
          });
      });
    return completer.future;
  }
  
  Future _loadDb() {
    _tasksStore = new TasksStore(_store);
    return _tasksStore.load();
  }
}

class TasksStore {
  final _store;
  final Tasks _tasks = new Tasks();

  TasksStore(this._store);
  
  Tasks get tasks => _tasks;
  bool get isEmpty => tasks.length == 0;
  
  Future load() {
    Stream dataStream = _store.all();
    return dataStream.forEach((taskMap) {      
      var task = new Task.fromDb(taskMap);
      tasks.add(task);
    });
  }
  
  Future<Task> add(String title) {
    Completer completer = new Completer();
    var task = new Task(title);
    find(title)
      .then((foundTask) {
        if (foundTask != null) {
          completer.completeError('${title} title is not unique');
        } else {
          var taskMap = task.toDb();
          _store.save(taskMap, task.title)
            .then((_) {
              tasks.add(task);
              completer.complete();
            });
        }
      });
    return completer.future
      .then((_) {
        return task;
      });
  }
  
  Future update(Task task, String beforeTitle) {
    Completer completer = new Completer();
    var taskMap = task.toDb();
    if (task.title == beforeTitle) {
      _store.save(taskMap, task.title)
        .then((_) {
          completer.complete();
        });
    } else {
      int count = tasks.count(task.title);
      if (count > 1) {
        completer.completeError('${task} title is not unique');
      } else {
        _store.removeByKey(beforeTitle)
          .then((_) {
            _store.save(taskMap, task.title)
              .then((_) {
                completer.complete();
              });
          });    
      }
    }   
    return completer.future;
  }
  
  Future<Task> find(String title) {
    var future = _store.getByKey(title);
    return future
      .then((taskMap) {
        return tasks.find(title);
      })
      .catchError((e) {
        return null;
      });
  }
  
  Future complete() {
    Completer completer = new Completer();
    int count = 0;
    Tasks activeTasks = tasks.active;
    int activeLength = activeTasks.length;
    for (var task in activeTasks) {
      task.completed = true;
      task.updated = new DateTime.now();
      update(task, task.title)
        .then((_) {
          if (++count == activeLength) {
            completer.complete();
          }
        });
    }
    return completer.future;
  }

  Future remove(Task task) {
    var future =_store.removeByKey(task.title);
    return future
      .then((_) {
        task.title = null;
        tasks.remove(task);
      });
  }
  
  Future removeCompleted() {
    Completer completer = new Completer();
    int count = 0;
    Tasks completedTasks = tasks.completed;
    int completedLength = completedTasks.length;
    for (var task in completedTasks) {
      remove(task)
        .then((_) {
          if (++count == completedLength) {
            completer.complete();
          }
        });
    }
    return completer.future;
  }

  Future clear() {
    var future = _store.nuke();
    return future
      .then((_) {
        tasks.clear();
      });
  }
  
}