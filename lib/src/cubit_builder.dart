import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:value_cubit/value_cubit.dart';

/// Helps handling in widget the states with [BaseState]
class ValueCubitBuilder<C extends Cubit<BaseState<S>>, S>
    extends StatefulWidget {
  /// The [cubit] that the [BlocBuilderBase] will interact with.
  /// If omitted, [BlocBuilderBase] will automatically perform a lookup using
  /// [BlocProvider] and the current `BuildContext`.
  final C? cubit;

  /// {@macro bloc_builder_build_when}
  final BlocBuilderCondition<BaseState<S>>? buildWhen;

  final Widget Function(BuildContext context, ValueState<S> state,
      Object? error, StackTrace? stackTrace) builderValue;

  /// Retourne le widget en cas d'erreur. S'il retourne null et qu'il
  /// possède une valeur (provenant d'un état précédent), alors [builderValue]
  /// est appelé
  final BlocWidgetBuilder<ErrorState<S>> builderError;
  final BlocWidgetBuilder<WaitingState<S>> builderWaiting;
  final BlocWidgetBuilder<NoValueState<S>> builderNoValue;
  final Widget Function(BuildContext context, BaseState<S> state, Widget child)?
      builder;

  const ValueCubitBuilder(
      {Key? key,
      required this.builderValue,
      required this.builderWaiting,
      required this.builderNoValue,
      required this.builderError,
      this.cubit,
      this.builder,
      this.buildWhen})
      : super(key: key);

  @override
  State<ValueCubitBuilder<C, S>> createState() =>
      _ValueCubitBuilderState<C, S>();
}

class _ValueCubitBuilderState<C extends Cubit<BaseState<S>>, S>
    extends State<ValueCubitBuilder<C, S>> implements StateVisitor<Widget, S> {
  @override
  Widget build(BuildContext context) {
    final builder = widget.builder ?? (context, state, child) => child;

    return BlocBuilder<C, BaseState<S>>(
        builder: (context, state) =>
            builder(context, state, state.accept(this)),
        bloc: widget.cubit,
        buildWhen: widget.buildWhen);
  }

  @override
  Widget visitErrorState(ErrorState<S> state) =>
      widget.builderError(context, state);

  @override
  Widget visitInitState(InitState<S> state) =>
      widget.builderWaiting(context, state);

  @override
  Widget visitNoValueState(NoValueState<S> state) =>
      widget.builderNoValue(context, state);

  @override
  Widget visitValueState(ValueState<S> state) =>
      widget.builderValue(context, state, null, null);

  @override
  Widget visitPendingState(PendingState<S> state) =>
      widget.builderWaiting(context, state);
}
