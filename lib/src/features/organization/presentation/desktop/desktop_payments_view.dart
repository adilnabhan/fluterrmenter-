import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentor_mobile_app/core/bloc/bloc.dart';
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/payment_history_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/cubit/members_and_leads_cubit.dart';
import 'package:mentor_mobile_app/src/features/organization/presentation/desktop/desktop_content_constraint.dart';

class DesktopPaymentsView extends StatelessWidget {
  const DesktopPaymentsView({
    super.key,
    required this.orgId,
  });

  final int orgId;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.isDarkMode ? context.colors.background : const Color(0xFFF8F9FA),
      child: DesktopContentConstraint(
        maxWidth: 1600,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: context.isDarkMode ? 0.3 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: BlocProvider(
            create: (_) => MembersAndLeadsCubit(orgId: orgId),
            child: PaymentHistoryList(
              orgId: orgId,
              showBackButton: false,
            ),
          ),
        ),
      ),
    );
  }
}

