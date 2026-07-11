
import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_padding.dart';
import 'package:gym_lead_master/src/core/constants/app_text_size.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_payment_page/data/model/plan.dart';

class AvailablePlansCard extends StatefulWidget {
  final List<Plan> plans;
  final Function(Plan) onPlanSelected;

  const AvailablePlansCard({
    super.key,
    required this.plans,
    required this.onPlanSelected,
  });

  @override
  State<AvailablePlansCard> createState() => _AvailablePlansCardState();
}

class _AvailablePlansCardState extends State<AvailablePlansCard> {
  Plan? _selectedPlan;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppPaddings.medium),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Plans',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppPaddings.medium),
            ...widget.plans.map((plan) {
              final isSelected = _selectedPlan?.id == plan.id;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPlan = plan;
                  });
                  widget.onPlanSelected(plan);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppPaddings.medium),
                  padding: const EdgeInsets.all(AppPaddings.medium),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? AppColors.BrightBlue : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected ? AppColors.BrightBlue.withOpacity(0.1) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            plan.name,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.BrightBlue : null,
                            ),
                          ),
                          Text(
                            '\$${plan.price.toStringAsFixed(2)}/${plan.duration.toLowerCase()}',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: isSelected ? AppColors.BrightBlue : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...plan.features.map((feature) => Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.successGreen, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(feature, style: AppTextStyles.bodyMedium)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
///////////////////////////////////


