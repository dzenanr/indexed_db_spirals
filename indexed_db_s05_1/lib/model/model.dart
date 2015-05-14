part of indexed_db;

class Task { 
  String title;
  bool isCompleted = false;
  DateTime whenUpdated = new DateTime.now();

  Task();
  
  Task.id(this.title);
  
  void fromJsonMap(Map<String, Object> jsonMap) {
    title  = jsonMap['title'];
    isCompleted = jsonMap['isCompleted'];
    whenUpdated = DateTime.parse(jsonMap['whenUpdated']);
  }
  
  void fromJsonString(String jsonString) {
    Map<String, Object> jsonMap = JSON.decode(jsonString);
    fromJsonMap(jsonMap);
  }
  
  Map<String, Object> toJsonMap() {
    var jsonMap = new Map<String, Object>();
    jsonMap['title'] = title;
    jsonMap['isCompleted'] = isCompleted;
    jsonMap['whenUpdated'] = whenUpdated.toString();
    return jsonMap;
  }
  
  String toJsonString() => JSON.encode(toJsonMap());

  /**
   * Compares two tasks based on title.
   * If the result is less than 0 then the first task is less than the second,
   * if it is equal to 0 they are equal and
   * if the result is greater than 0 then the first is greater than the second.
   */
  int compareTo(Task task) {
    if (title != null) {
      return title.compareTo(task.title);
    }
    return null;
  }

  /**
   * Returns a string that represents this task.
   */
  String toString() {
    return '${title}';
  }

  display() {
    print(toString);
  }
}

class Tasks {
  var _tasks = new List<Task>();

  Iterator<Task> get iterator => _tasks.iterator;

  int get length => _tasks.length;

  Tasks get completed {
    var completed = new Tasks();
    for (var task in _tasks) {
      if (task.isCompleted) {
        completed.add(task);
      }
    }
    return completed;
  }

  Tasks get active {
    var active = new Tasks();
    for (var task in _tasks) {
      if (!task.isCompleted) {
        active.add(task);
      }
    }
    return active;
  }


  List<Task> toList() => _tasks;

  sort() {
    _tasks.sort((m,n) => m.compareTo(n));
  }

  bool contains(String title) {
    if (title != null) {
      for (var task in _tasks) {
        if (task.title == title) {
          return true;
        }
      }
    }
    return false;
  }

  Task find(String title) {
    if (title != null) {
      for (var task in _tasks) {
        if (task.title == title) {
          return task;
        }
      }
    }
    return null;
  }
  
  int count(String title) {
    var count = 0;
    if (title != null) {
      for (var task in _tasks) {
        if (task.title == title) {
          count++;
        }
      }
    }
    return count;
  }

  bool add(Task task) {
    if (contains(task.title)) {
      return false;
    } else {
      _tasks.add(task);
      return true;
    }
  }

  bool remove(Task task) {
    return _tasks.remove(task);
  }

  clear() => _tasks.clear();

  display() {
    _tasks.forEach((t) {
      t.display();
    });
  }
}
