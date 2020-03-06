import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:tarea_dos/models/todo_remainder.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  // TODO: inicializar la box
  Box _toDoBox;
  @override
  HomeState get initialState => HomeInitialState();
  HomeBloc() {
    _toDoBox = Hive.box("todos");
  }

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is OnLoadRemindersEvent) {
      try {
        List<TodoRemainder> _existingReminders = _loadReminders();
        yield LoadedRemindersState(todosList: _existingReminders);
      } on DatabaseDoesNotExist catch (_) {
        yield NoRemindersState();
      } on EmptyDatabase catch (_) {
        yield NoRemindersState();
      }
    }
    if (event is OnAddElementEvent) {
      _saveTodoReminder(event.todoReminder);
      yield NewReminderState(todo: event.todoReminder);
    }
    if (event is OnReminderAddedEvent) {
      yield AwaitingEventsState();
    }
    if (event is OnRemoveElementEvent) {
      _removeTodoReminder(event.removedAtIndex);
    }
  }

  List<TodoRemainder> _loadReminders() {
    if (_toDoBox.isEmpty) {
      throw EmptyDatabase();
    }
    return _toDoBox.values.map((todo) => todo as TodoRemainder).toList();
  }

  void _saveTodoReminder(TodoRemainder todoReminder) {
    _toDoBox.add(todoReminder);
  }

  void _removeTodoReminder(int removedAtIndex) {
    _toDoBox.deleteAt(removedAtIndex);
  }
}

class DatabaseDoesNotExist implements Exception {}

class EmptyDatabase implements Exception {}
