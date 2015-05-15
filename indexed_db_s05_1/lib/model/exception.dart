part of indexed_db;

class ModelException implements Exception {

  final String msg;

  ModelException(this.msg);

  toString() => '*** $msg ***';

}

class IdException extends ModelException {

  IdException(String msg) : super(msg);

}