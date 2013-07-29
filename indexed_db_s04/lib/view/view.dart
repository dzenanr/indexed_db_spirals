part of indexed_db;

class TasksView {
  TasksStore _tasksStore;

  InputElement _completeAllTasks = query('#complete-all-tasks');
  Element _taskElements = query('#task-list');
  Element _footer = query('.footer');
  Element _activeTasksCount = query('#active-tasks-count');
  ButtonElement _clearCompletedTasks = query('#clear-completed-tasks');

  TasksView(this._tasksStore) {
    _completeAllTasks.onClick.listen((Event e) {
      _tasksStore.completeTasks();
      _clearElements();
      loadElements(_tasksStore.tasks);
    });

    InputElement newTask = query('#new-task');
    newTask.onKeyPress.listen((KeyboardEvent e) {
      if (e.keyCode == KeyCode.ENTER) {
        var title = newTask.value.trim();
        if (title != '') {
          _tasksStore.add(title).then((task) {
            _addElement(task);
          });
          newTask.value = '';
        }
      }
    });

    _clearCompletedTasks.onClick.listen((MouseEvent e) {
      _tasksStore.removeCompletedTasks().then((_) {
        _clearElements();
        loadElements(_tasksStore.tasks);
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
      _tasksStore.remove(task).then((_) {
        _taskElements.nodes.remove(taskElement);
        _updateDisplay();
      });
    });
    taskElement.query('.task-completed').onClick.listen((MouseEvent e) {
      task.completed = !task.completed;
      task.updated = new DateTime.now();
      _tasksStore.update(task);
      _updateDisplay();
    });
    _taskElements.nodes.add(taskElement);
    _updateDisplay();
  }

  loadElements(List tasks) {
    for (Task task in tasks) {
      _addElement(task);
    }
    _updateDisplay();
  }

  _clearElements() {
    _taskElements.nodes.clear();
    _updateDisplay();
  }

  _updateDisplay() {
    var allCount =_tasksStore.tasks.length;
    var completedCount = _tasksStore.completedTasks.length;
    var activeCount = _tasksStore.activeTasks.length;

    if (completedCount == allCount) {
      _completeAllTasks.checked = true;
    } else {
      _completeAllTasks.checked = false;
    }

    var display = allCount == 0 ? 'none' : 'block';
    _completeAllTasks.style.display = display;
    _footer.style.display = display;

    _activeTasksCount.innerHtml =
        '<b>${activeCount}</b> active task${activeCount != 1 ? 's' : ''}';
    if (completedCount == 0) {
      _clearCompletedTasks.style.display = 'none';
    } else {
      _clearCompletedTasks.style.display = 'inline';
      _clearCompletedTasks.text ='Clear completed (${completedCount})';
    }
  }
}

