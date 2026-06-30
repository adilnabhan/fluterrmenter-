import 'package:mentor_mobile_app/imports_bindings.dart';

class MultipleValueListenableBuilder<T> extends StatelessWidget {
  const MultipleValueListenableBuilder({required this.valueListenables, required this.builder, super.key, this.child});

  final List<ValueListenable<T>> valueListenables;
  final Widget Function(BuildContext context, List<T> values, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return _CombinedValueListenableBuilder<T>(valueListenables: valueListenables, builder: builder, child: child);
  }
}

class _CombinedValueListenableBuilder<T> extends StatefulWidget {
  const _CombinedValueListenableBuilder({required this.valueListenables, required this.builder, super.key, this.child});

  final List<ValueListenable<T>> valueListenables;
  final Widget Function(BuildContext context, List<T> values, Widget? child) builder;
  final Widget? child;

  @override
  State<_CombinedValueListenableBuilder<T>> createState() => _CombinedValueListenableBuilderState();
}

class _CombinedValueListenableBuilderState<T> extends State<_CombinedValueListenableBuilder<T>> {
  late List<T> _values;

  @override
  void initState() {
    super.initState();
    _values = widget.valueListenables.map((v) => v.value).toList();
    for (var i = 0; i < widget.valueListenables.length; i++) {
      widget.valueListenables[i].addListener(() {
        if (!mounted) return;
        setState(() {
          _values[i] = widget.valueListenables[i].value;
        });
      });
    }
  }

  @override
  void dispose() {
    for (final listenable in widget.valueListenables) {
      listenable.removeListener(() {});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _values, widget.child);
  }
}
