import 'package:equatable/equatable.dart';

abstract class ReaderState extends Equatable {
  const ReaderState();
  @override
  List<Object> get props => [];
}

class ReaderInitial extends ReaderState {}

class ReaderLoading extends ReaderState {}

class ReaderLoaded extends ReaderState {
  final List<String> pageUrls;
  const ReaderLoaded(this.pageUrls);
  @override
  List<Object> get props => [pageUrls];
}

class ReaderError extends ReaderState {
  final String message;
  const ReaderError(this.message);
  @override
  List<Object> get props => [message];
}