import 'dart:html';
import 'model.dart';

Element taskElements;
TasksStore tasksStore;

Element newElement(Task task) {
  return new Element.html('''
    <li>
      ${task.title}
    </li>
  ''');
}

addElement(Task task) {
  var taskElement = newElement(task);
  taskElements.nodes.add(taskElement);
}

loadElements(List tasks) {
  for (Task task in tasks) {
    addElement(task);
  }
}

clearElements() {
  taskElements.nodes.clear();
}

main() {
  taskElements = querySelector('#task-list');
  tasksStore = new TasksStore();
  tasksStore.open().then((_) {
    loadElements(tasksStore.tasks);
  });

  InputElement newTask = querySelector('#new-task');
  newTask.onKeyPress.listen((KeyboardEvent e) {
    if (e.keyCode == KeyCode.ENTER) {
      var title = newTask.value.trim();
      if (title != '') {
        tasksStore.add(title).then((task) {
          addElement(task);
        });
        newTask.value = '';
      }
    }
  });

  ButtonElement clear = querySelector('#clear-tasks');
  clear.onClick.listen((MouseEvent e) {
    tasksStore.clear().then((_) {
      clearElements();
    });
  });
}