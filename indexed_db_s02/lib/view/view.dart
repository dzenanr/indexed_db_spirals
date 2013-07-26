part of indexed_db;

class TasksView {
  TasksStore tasksStore;

  Element _taskElements;

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

    ButtonElement clearTasks = query('#clear-tasks');
    clearTasks.onClick.listen((MouseEvent e) {
      tasksStore.clear().then((_) {
        _clearElements();
      });
    });
  }

  Element _newElement(Task task) {
    return new Element.html('''
        <li>
          <button class='task-button remove-task'>X</button>
          ${task.title}
        </li>
    ''');
  }

  _addElement(Task task) {
    var taskElement = _newElement(task);
    taskElement.query('.remove-task').onClick.listen((MouseEvent e) {
      tasksStore.remove(task).then((_) {
        _taskElements.nodes.remove(taskElement);
      });
    });
    _taskElements.nodes.add(taskElement);
  }

  loadElements(List tasks) {
    for (Task task in tasks) {
      _addElement(task);
    }
  }

  _clearElements() {
    _taskElements.nodes.clear();
  }
}

