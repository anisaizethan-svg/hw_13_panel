import 'package:flutter/material.dart';

import '../../domain/entities/person_entity.dart';
import 'person_card.dart';

class PersonList extends StatefulWidget {
  const PersonList({
    super.key,
    required this.persons,
    required this.onNext,
    required this.hasMore,
    this.loadingMore = false,
    this.error,
  });
  final List<PersonEntity> persons;
  final VoidCallback onNext;
  final bool hasMore, loadingMore;
  final String? error;
  @override
  State<PersonList> createState() => _PersonListState();
}

class _PersonListState extends State<PersonList> {
  final _controller = ScrollController();
  @override
  void initState() {
    super.initState();
    _controller.addListener(_scroll);
  }

  void _scroll() {
    if (_controller.position.extentAfter < 450 &&
        widget.hasMore &&
        !widget.loadingMore &&
        widget.error == null) {
      widget.onNext();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView.separated(
    controller: _controller,
    padding: const EdgeInsets.all(12),
    itemCount: widget.persons.length + 1,
    separatorBuilder: (_, index) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      if (index < widget.persons.length) {
        return PersonCard(person: widget.persons[index]);
      }
      if (widget.error != null) {
        return RetryMessage(message: widget.error!, onRetry: widget.onNext);
      }
      if (widget.loadingMore) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return widget.hasMore
          ? Center(
              child: TextButton(
                onPressed: widget.onNext,
                child: const Text('Load more'),
              ),
            )
          : const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: Text(
                  'All characters loaded',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
    },
  );
}

class RetryMessage extends StatelessWidget {
  const RetryMessage({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}
