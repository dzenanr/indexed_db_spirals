import 'dart:html';
import 'model.dart';

Element taskElements;
TaskStore taskStore;

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
  taskElements = query('#task-list');
  taskStore = new TaskStore();
  taskStore.open().then((_) {
    loadElements(taskStore.tasks);
  });

  InputElement newTask = query('#new-task');
  newTask.onKeyPress.listen((KeyboardEvent e) {
    if (e.keyCode == KeyCode.ENTER) {
      var title = newTask.value.trim();
      if (title != '') {
        taskStore.add(title).then((task) {
          addElement(task);
        });
        newTask.value = '';
      }
    }
  });

  ButtonElement clear = query('#clear');
  clear.onClick.listen((MouseEvent e) {
    taskStore.clear().then((_) {
      clearElements();
    });
  });
}