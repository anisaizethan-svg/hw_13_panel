import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/person_list_cubit/person_list_cubit.dart';
import '../bloc/person_list_cubit/person_list_state.dart';
import '../widgets/person_list.dart';
import '../widgets/search_widget.dart';

class PersonScreen extends StatelessWidget {
  const PersonScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Characters'),
      actions: [
        IconButton(
          tooltip: 'Search characters',
          icon: const Icon(Icons.search),
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const SearchWidget())),
        ),
      ],
    ),
    body: BlocBuilder<PersonListCubit, PersonListState>(
      builder: (context, state) {
        final cubit = context.read<PersonListCubit>();
        if (state.status == PersonListStatus.initial ||
            state.status == PersonListStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == PersonListStatus.error) {
          return RetryMessage(message: state.error!, onRetry: cubit.loadNext);
        }
        return Column(
          children: [
            if (state.isCached)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Showing saved characters',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            Expanded(
              child: PersonList(
                persons: state.persons,
                onNext: cubit.loadNext,
                hasMore: state.nextPage != null,
                loadingMore: state.loadingMore,
                error: state.error,
              ),
            ),
          ],
        );
      },
    ),
  );
}
