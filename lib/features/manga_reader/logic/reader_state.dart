import 'package:equatable/equatable.dart';

abstract class ReaderState extends Equatable {
  const ReaderState();
  @override
  List<Object> get props => [];
}

class ReaderInitial extends ReaderState {}

class ReaderLoading extends ReaderState {}

class ReaderLoaded extends ReaderState {
  final Map<String, dynamic> chapter;
  const ReaderLoaded(this.chapter);
  @override
  List<Object> get props => [chapter];
}

class ReaderError extends ReaderState {
  final String message;
  const ReaderError(this.message);
  @override
  List<Object> get props => [message];
}