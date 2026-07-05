import 'package:flutter/material.dart';
import 'package:sokon/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/utils/app_assets.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';
import 'package:sokon/features/ui/pages/tabs/search_tab/cubit/search_states.dart';
import 'package:sokon/features/ui/pages/tabs/search_tab/cubit/search_view_model.dart';
import 'package:sokon/features/ui/widgets/featured_estates_card.dart';
import 'package:sokon/features/ui/widgets/search_widget.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final SearchViewModel viewModel = getIt<SearchViewModel>();
  final TextEditingController _searchController = TextEditingController();

  // Filter state
  bool _isForRent = true;
  String _selectedPropertyType = "Apartment";
  RangeValues _currentRangeValues = const RangeValues(10, 800);
  final Set<String> _selectedFacilities = {};

  @override
  void initState() {
    super.initState();
    viewModel.getAllApartments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(width: 15.w),
                  Text(l10n.search, style: theme.textTheme.headlineMedium),
                ],
              ),
              SizedBox(height: 20.h),
              SearchWidget(
                hintText: l10n.searchPlaceholder,
                controller: _searchController,
                onChanged: (query) => viewModel.search(query),
                onFilterTap: () => _showFilterBottomSheet(context),

              ),
              SizedBox(height: 20.h),
              Expanded(
                child: BlocBuilder<SearchViewModel, SearchStates>(
                  bloc: viewModel,
                  builder: (context, state) {
                    if (state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is SearchError) {
                      return Center(child: Text("Error: ${state.message}"));
                    }

                    return ListView(
                      children: [
                        if (state is SearchInitial && state.recentSearches.isNotEmpty) ...[
                          Text(l10n.recent, style: theme.textTheme.titleMedium),
                          SizedBox(height: 10.h),
                          ...state.recentSearches.map((s) => _buildListItem(
                                icon: Icons.access_time,
                                title: s,
                                subtitle: l10n.recentSearch,
                                onTap: () {
                                  _searchController.text = s;
                                  viewModel.search(s);
                                },
                              )),
                          SizedBox(height: 20.h),
                        ],
                        if (state is SearchLoaded) ...[
                          Text(l10n.result, style: theme.textTheme.titleMedium),
                          SizedBox(height: 10.h),
                          if (state.results.isEmpty)
                            Center(child: Text(l10n.noEstatesFound))
                          else
                            ...state.results.map((apartment) => Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: FeaturedEstatesCard(apartment: apartment),
                                )),
                        ]
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(8.sp),
        decoration: BoxDecoration(
          color: AppColors.offWhiteColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.grayColor, size: 20.sp),
      ),
      title: Text(title, style: Theme.of(context).textTheme.labelMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: EdgeInsets.all(20.sp),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40.w,
                            height: 5.h,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Text(l10n.lookingFor, style: Theme.of(context).textTheme.labelMedium),
                        _buildFilterCheckbox(l10n.forRent, _isForRent, (v) => setSheetState(() => _isForRent = v!)),
                        // _buildFilterCheckbox(l10n.forSale, _isForSale, (v) => setSheetState(() => _isForSale = v!)),
                        SizedBox(height: 20.h),
                        Text(l10n.propertyType, style: Theme.of(context).textTheme.labelMedium),
                        ...["Apartment",].map((type) => _buildFilterCheckbox(
                              type,
                              _selectedPropertyType == type,
                              (v) => setSheetState(() => _selectedPropertyType = type),
                            )),
                        SizedBox(height: 20.h),
                        Text(l10n.priceRange, style: Theme.of(context).textTheme.labelMedium),
                        RangeSlider(
                          values: _currentRangeValues,
                          min: 0,
                          max: 5000,
                          divisions: 100,
                          activeColor: AppColors.primaryColor,
                          labels: RangeLabels(
                            "EG${_currentRangeValues.start.round()}",
                            "EG${_currentRangeValues.end.round()}",
                          ),
                          onChanged: (val) => setSheetState(() => _currentRangeValues = val),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("EG${_currentRangeValues.start.round()}", style: Theme.of(context).textTheme.bodyMedium),
                            Text("EG${_currentRangeValues.end.round()}", style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Text(l10n.facilities, style: Theme.of(context).textTheme.labelMedium),
                        SizedBox(height: 15.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSelectableFacility(setSheetState, Icons.bed, l10n.bedroom),
                            _buildSelectableFacility(setSheetState, Icons.bathtub, l10n.bathtub),
                            _buildSelectableFacility(setSheetState, Icons.ac_unit, "AC"),
                            _buildSelectableFacility(setSheetState, Icons.wifi, "WIFI"),
                          ],
                        ),
                        SizedBox(height: 40.h),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  setSheetState(() {
                                    _isForRent = true;
                                    _selectedPropertyType = "Apartment";
                                    _currentRangeValues = const RangeValues(10, 800);
                                    _selectedFacilities.clear();
                                  });
                                },
                                child: Text(l10n.reset, style: AppStyles.medium16RedColor),
                              ),
                            ),
                            SizedBox(width: 15.w),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () {
                                  viewModel.filter(
                                    minPrice: _currentRangeValues.start,
                                    maxPrice: _currentRangeValues.end,
                                  );
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  padding: EdgeInsets.symmetric(vertical: 15.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                child: Text(l10n.apply, style: AppStyles.semiBold14White),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFilterCheckbox(String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(title, style: AppStyles.medium13Gray),
      value: value,
      activeColor: AppColors.primaryColor,
      contentPadding: EdgeInsets.zero,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  Widget _buildSelectableFacility(StateSetter setSheetState, IconData icon, String label) {
    final isSelected = _selectedFacilities.contains(label);
    return InkWell(
      onTap: () {
        setSheetState(() {
          if (isSelected) {
            _selectedFacilities.remove(label);
          } else {
            _selectedFacilities.add(label);
          }
        });
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.sp),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.grayColor :AppColors.transparentColor,
              border: Border.all(width: 2,color: isSelected ? AppColors.primaryLight : AppColors.grayColor.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Icon(icon, color: isSelected ? AppColors.primaryColor : AppColors.grayColor),
                Text(label, style: isSelected ? AppStyles.bold10Primary : AppStyles.medium12gray),
              ],
            )

          ),
          SizedBox(height: 5.h),
        ],
      ),
    );
  }
}
