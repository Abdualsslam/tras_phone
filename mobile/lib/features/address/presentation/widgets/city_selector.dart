/// City Selector Widget - اختيار المدينة
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/city_entity.dart';
import '../cubit/locations_cubit.dart';
import '../cubit/locations_state.dart';

class CitySelector extends StatelessWidget {
  final Function(CityEntity)? onCitySelected;
  final String? labelText;
  final String locale;

  const CitySelector({
    super.key,
    this.onCitySelected,
    this.labelText,
    this.locale = 'ar',
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationsCubit, LocationsState>(
      builder: (context, state) {
        if (state.status == LocationsStatus.loading && state.cities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.cities.isEmpty) {
          return Text(
            locale == 'ar' ? 'لا توجد مدن متاحة' : 'No cities available',
          );
        }

        return DropdownButtonFormField<CityEntity>(
          decoration: InputDecoration(
            labelText: labelText ?? (locale == 'ar' ? 'المدينة' : 'City'),
            border: const OutlineInputBorder(),
          ),
          initialValue: state.selectedCity,
          items: state.cities.map((city) {
            return DropdownMenuItem(
              value: city,
              child: Row(
                children: [
                  if (city.isCapital)
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                  if (city.isCapital) const SizedBox(width: 8),
                  Text(city.getName(locale)),
                ],
              ),
            );
          }).toList(),
          onChanged: (city) {
            if (city != null) {
              context.read<LocationsCubit>().selectCity(city);
              onCitySelected?.call(city);
            }
          },
        );
      },
    );
  }
}
