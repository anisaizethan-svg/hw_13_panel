import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../locator_service.dart';
import '../bloc/search_bloc/search_bloc.dart';
import '../bloc/search_bloc/search_event.dart';
import '../bloc/search_bloc/search_state.dart';
import 'person_list.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});
  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<SearchBloc>(),
    child: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Search characters',
              border: InputBorder.none,
            ),
            onChanged: (query) =>
                context.read<SearchBloc>().add(SearchQueryChanged(query)),
          ),
          actions: [
            IconButton(
              tooltip: 'Clear search',
              icon: const Icon(Icons.close),
              onPressed: () {
                _controller.clear();
                context.read<SearchBloc>().add(const SearchQueryChanged(''));
              },
            ),
          ],
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            final bloc = context.read<SearchBloc>();
            switch (state.status) {
              case SearchStatus.initial:
                return const Center(
                  child: Text(
                    'Search for a character by name',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              case SearchStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case SearchStatus.empty:
                return Center(
                  child: Text(
                    'No characters found for “${state.query}”',
                    textAlign: TextAlign.center,
                  ),
                );
              case SearchStatus.error:
                return RetryMessage(
                  message: state.error!,
                  onRetry: () => bloc.add(SearchQueryChanged(state.query)),
                );
              case SearchStatus.loaded:
                return PersonList(
                  key: ValueKey(state.query),
                  persons: state.persons,
                  onNext: () => bloc.add(const SearchNextPage()),
                  hasMore: state.nextPage != null,
                  loadingMore: state.loadingMore,
                  error: state.error,
                );
            }
          },
        ),
      ),
    ),
  );
}
