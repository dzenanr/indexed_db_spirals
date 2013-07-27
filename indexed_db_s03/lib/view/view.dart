part of indexed_db;

class TasksView {
  TasksStore tasksStore;

  Element _taskElements;
  ButtonElement clearTasks;

  TasksView(this.tasksStore) {
    _taskElements = query('#task-list');

    InputElement newTask = query('#new-task');
    newTask.onKeyPress.listen((KeyboardEvent e) {
      if (e.keyCode == KeyCode.ENTER) {
        var title = newTask.value.trim();
        if (title != '') {
          tasksStore.add(title).then((task) {
            _addElement(task);
          });
          newTask.value = '';
        }
      }
    });

    clearTasks = query('#clear-tasks');
    clearTasks.onClick.listen((MouseEvent e) {
      tasksStore.clear().then((_) {
        _clearElements();
        _updateFooter();
      });
    });
  }

  Element _newElement(Task task) {
    return new Element.html('''
        <li>
          <button class='task-button remove-task'>X</button>
          <input class='task-completed' type='checkbox'
            ${task.completed ? 'checked' : ''}>
          <label class='task-title'>${task.title}</label>
        </li>
    ''');
  }

  _addElement(Task task) {
    var taskElement = _newElement(task);
    taskElement.query('.remove-task').onClick.listen((MouseEvent e) {
      tasksStore.remove(task).then((_) {
        _taskElements.nodes.remove(taskElement);
        _updateFooter();
      });
    });
    taskElement.query('.task-completed').onClick.listen((MouseEvent e) {
      task.completed = !task.completed;
      task.updated = new DateTime.now();
      tasksStore.update(task);
    });
    _taskElements.nodes.add(taskElement);
    _updateFooter();
  }

  loadElements(List tasks) {
    for (Task task in tasks) {
      _addElement(task);
    }
    _updateFooter();
  }

  _clearElements() {
    _taskElements.nodes.clear();
  }

  _updateFooter() {
    if (tasksStore.tasks.length == 0) {
      clearTasks.style.display = 'none';
    } else {
      clearTasks.style.display = 'inline';
    }
  }
}

