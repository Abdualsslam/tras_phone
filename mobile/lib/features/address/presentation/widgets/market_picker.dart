/// Market Picker Widget - اختيار الحي/السوق
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/market_model.dart';
import '../cubit/locations_cubit.dart';
import '../cubit/locations_state.dart';

class MarketPicker extends StatelessWidget {
  final Function(MarketModel)? onMarketSelected;
  final String locale;

  const MarketPicker({super.key, this.onMarketSelected, this.locale = 'ar'});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationsCubit, LocationsState>(
      builder: (context, state) {
        if (state.markets.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale == 'ar' ? 'اختر الحي' : 'Select District',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.markets.map((market) {
                final isSelected = state.selectedMarket?.id == market.id;
                return ChoiceChip(
                  label: Text(market.getName(locale)),
                  selected: isSelected,
                  onSelected: (_) {
                    context.read<LocationsCubit>().selectMarket(market);
                    onMarketSelected?.call(market);
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
