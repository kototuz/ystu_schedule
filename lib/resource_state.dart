abstract class State<T> {}

class Downloading<T> extends State<T> {}

class Error<T> extends State<T> {
  final String message;
  Error(this.message);
}

class Ok<T> extends State<T> {
  final T value;
  Ok(this.value);
}
