part of indexed_db;

class TasksView {
  TasksStore _tasksStore;

  InputElement _completeAllTasks = querySelector('#complete-all-tasks');
  Element _taskElements = querySelector('#task-list');
  Element _footer = querySelector('.footer');
  Element _activeTasksCount = querySelector('#active-tasks-count');
  Element _allElements = querySelector('#filter a[href="#/"]');
  Element _activeElements = querySelector('#filter a[href="#/active"]');
  Element _completedElements = querySelector('#filter a[href="#/completed"]');
  ButtonElement _clearCompletedTasks = querySelector('#clear-completed-tasks');

  TasksView(this._tasksStore) {
    window.onHashChange.listen((e) => _updateFilter());

    _completeAllTasks.onClick.listen((Event e) {
      _tasksStore.complete();
      _clearElements();
      loadElements(_tasksStore.tasks);
      _updateFilter();
    });

    InputElement newTask = querySelector('#new-task');
    newTask.onKeyPress.listen((KeyboardEvent e) {
      if (e.keyCode == KeyCode.ENTER) {
        var title = newTask.value.trim();
        if (title != '') {
          _tasksStore.add(title)
            .then((task) {
              _addElement(task);
              newTask.value = '';
              _updateFilter();
            })
            .catchError((e) {
              newTask.value = '${title} : title not unique';
              newTask.select();
            });
        }
      }
    });

    _clearCompletedTasks.onClick.listen((MouseEvent e) {
      _tasksStore.removeCompleted()
        .then((_) {
          _clearElements();
          loadElements(_tasksStore.tasks);
        });
    });
  }

  Element _newElement(Task task) {
    return new Element.html('''
      <li>
        <input class='task-completed' type='checkbox'
          ${task.completed ? 'checked' : ''}>
        <button class='task-button remove-task'>X</button>
        <label class='task-title'>${task.title}</label>
        <input class='edit-title' value='${task.title}'>
      </li>
    ''');
  }

  _addElement(Task task) {
    var taskElement = _newElement(task);

    Element title = taskElement.querySelector('.task-title');
    InputElement editTitle = taskElement.querySelector('.edit-title');
    editTitle.hidden = true;
    title.onDoubleClick.listen((MouseEvent e) {
      title.hidden = true;
      editTitle.hidden = false;
      editTitle.select();
    });
    editTitle.onKeyPress.listen((KeyboardEvent e) {
      if (e.keyCode == KeyCode.ENTER) {
        var value = editTitle.value.trim();
        if (value != '') {
          task.title = value;
          task.updated = new DateTime.now();
          _tasksStore.update(task)
            .then((_) {
              title.text = value;
              title.hidden = false;
              editTitle.hidden = true;
              _updateDisplay();
            })
            .catchError((e) {
              editTitle.value =
                '${title.text} (old) ${editTitle.value} (new) : title not unique';
              editTitle.select();
            });
        }
      }
    });

    taskElement.querySelector('.remove-task').onClick.listen((MouseEvent e) {
      _tasksStore.remove(task)
        .then((_) {
          _taskElements.nodes.remove(taskElement);
          _updateDisplay();
        });
    });

    taskElement.querySelector('.task-completed').onClick.listen((MouseEvent e) {
      task.completed = !task.completed;
      task.updated = new DateTime.now();
      _tasksStore.update(task);
      _updateDisplay();
      _updateFilter(); // does not help to hide an active task in completed
    });

    _taskElements.nodes.add(taskElement);
    _updateDisplay();
    _updateFilter(); // does not help to hide a new task in completed
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

  _updateFilter() {
    switch(window.location.hash) {
      case '#/active':
        _showActive();
        break;
      case '#/completed':
        _showCompleted();
        break;
      default:
        _showAll();
        break;
    }
  }

  _showAll() {
    _setSelectedFilter(_allElements);
    for (var element in _taskElements.children) {
      element.hidden = false;
    }
  }

  _showActive() {
    _setSelectedFilter(_activeElements);
    for (var element in _taskElements.children) {
      Element titleLabel = element.querySelector('.task-title');
      String title = titleLabel.text;
      _tasksStore.find(title)
        .then((task) {
          element.hidden = task.completed;
        })
        .catchError((e) {});
    }
  }

  _showCompleted() {
    _setSelectedFilter(_completedElements);
    for (LIElement element in _taskElements.children) {
      Element titleLabel = element.querySelector('.task-title');
      String title = titleLabel.text;
      _tasksStore.find(title)
        .then((task) {
          element.hidden = !task.completed;
        })
        .catchError((e) {});
    }
  }

  _setSelectedFilter(Element element) {
    _allElements.classes.remove('selected');
    _activeElements.classes.remove('selected');
    _completedElements.classes.remove('selected');
    element.classes.add('selected');
  }

  _updateDisplay() {
    var allCount =_tasksStore.tasks.length;
    var completedCount = _tasksStore.completed.length;
    var activeCount = _tasksStore.active.length;

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

