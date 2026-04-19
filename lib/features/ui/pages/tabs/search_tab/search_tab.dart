import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/utils/app_assets.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';
import 'package:sokon/features/ui/pages/tabs/search_tab/cubit/search_states.dart';
import 'package:sokon/features/ui/pages/tabs/search_tab/cubit/search_view_model.dart';
import 'package:sokon/features/ui/widgets/custom_text_form_field.dart';
import 'package:sokon/features/ui/widgets/nearby_estate_card.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final SearchViewModel viewModel = getIt<SearchViewModel>();
  final TextEditingController _searchController = TextEditingController();

  // Filter state variables
  bool _isForRent = true;
  bool _isForSale = false;
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
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(10.sp),
                      decoration: BoxDecoration(
                        color: AppColors.offWhiteColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: AppColors.blackColor),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Text("Search", style: AppStyles.bold24Primary),
                ],
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                controller: _searchController,
                onChanged: (query) => viewModel.search(query),
                paddingVertical: 18.h,
                borderRadius: 14,
                fillColor: AppColors.whiteColor,
                borderSideColor: AppColors.grayColor.withOpacity(0.3),
                hintText: "Search...",
                hintStyle: AppStyles.medium12gray,
                prefixIconName: Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Image.asset(AppAssets.searchIcon, width: 20.w),
                ),
                suffixIconName: IconButton(
                  onPressed: () => _showFilterBottomSheet(context),
                  icon: Image.asset(AppAssets.filterIcon, width: 20.w),
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: BlocBuilder<SearchViewModel, SearchStates>(
                  bloc: viewModel,
                  builder: (context, state) {
                    if (state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SearchError) {
                      return Center(child: Text("Error: ${state.message}"));
                    } else if (state is SearchLoaded) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Result", style: AppStyles.bold18PrimaryColor),
                          SizedBox(height: 10.h),
                          Expanded(
                            child: state.results.isEmpty
                                ? const Center(child: Text("No estates found."))
                                : ListView.separated(
                                    itemCount: state.results.length,
                                    separatorBuilder: (context, index) => SizedBox(height: 15.h),
                                    itemBuilder: (context, index) {
                                      return NearbyEstateCard(apartment: state.results[index]);
                                    },
                                  ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
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
                        SizedBox(height: 20.h),
                        Center(child: Text("Filter", style: AppStyles.bold20black)),
                        SizedBox(height: 30.h),
                        Text("Looking for", style: AppStyles.bold16PrimaryColor),
                        CheckboxListTile(
                          title: Text("For Rent", style: AppStyles.medium13Gray),
                          value: _isForRent,
                          activeColor: AppColors.primaryColor,
                          onChanged: (val) {
                            setSheetState(() {
                              _isForRent = val ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                        CheckboxListTile(
                          title: Text("For Sale", style: AppStyles.medium13Gray),
                          value: _isForSale,
                          activeColor: AppColors.primaryColor,
                          onChanged: (val) {
                            setSheetState(() {
                              _isForSale = val ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                        SizedBox(height: 20.h),
                        Text("Property Type", style: AppStyles.bold16PrimaryColor),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing: 10,
                          children: ["Apartment", "Penthouse", "Hotel", "Villa"].map((type) {
                            return ChoiceChip(
                              label: Text(type),
                              selected: _selectedPropertyType == type,
                              selectedColor: AppColors.primaryColor.withOpacity(0.2),
                              onSelected: (val) {
                                setSheetState(() {
                                  _selectedPropertyType = type;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20.h),
                        Text("Price Range", style: AppStyles.bold16PrimaryColor),
                        RangeSlider(
                          values: _currentRangeValues,
                          min: 0,
                          max: 1000,
                          divisions: 100,
                          activeColor: AppColors.primaryColor,
                          labels: RangeLabels(
                            "\$${_currentRangeValues.start.round()}",
                            "\$${_currentRangeValues.end.round()}",
                          ),
                          onChanged: (val) {
                            setSheetState(() {
                              _currentRangeValues = val;
                            });
                          },
                        ),
                        SizedBox(height: 20.h),
                        Text("Facilities", style: AppStyles.bold16PrimaryColor),
                        SizedBox(height: 15.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSelectableFacility(setSheetState, Icons.bed, "Bedroom"),
                            _buildSelectableFacility(setSheetState, Icons.bathtub, "Bathtub"),
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
                                    _isForSale = false;
                                    _selectedPropertyType = "Apartment";
                                    _currentRangeValues = const RangeValues(10, 800);
                                    _selectedFacilities.clear();
                                  });
                                },
                                child: Text("Reset", style: AppStyles.medium16RedColor),
                              ),
                            ),
                            Expanded(
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
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text("Apply", style: AppStyles.semiBold14White),
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
              color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
              border: Border.all(color: isSelected ? AppColors.primaryColor : AppColors.grayColor.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: isSelected ? AppColors.primaryColor : AppColors.grayColor),
          ),
          SizedBox(height: 5.h),
          Text(label, style: isSelected ? AppStyles.medium10blueDarkColor : AppStyles.medium12gray),
        ],
      ),
    );
  }
}
