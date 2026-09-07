import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/active_member_list_page.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/admin_main_page.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/attendance/attendance_dashboard_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/attendance/attendance_month_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/attendance/member_detail_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/gym_member_page.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/pending_approvals_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/chat_page/chat_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/data/model/messages_model.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/notifications/admin_notifications_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/notifications/create_notification_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/common/forget_password_page.dart';
import 'package:gym_lead_master/src/presentation/pages/common/notifications/member_notifications_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/common/profile_page/about_app_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/common/profile_page/contact_support_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/common/profile_page/help_faq_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/common/profile_page/privacy_policy_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/common/profile_page/term_and_conditions_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/login_pages/gym_admin_login_page.dart';
import 'package:gym_lead_master/src/presentation/pages/login_pages/gym_member_login_page.dart';
import 'package:gym_lead_master/src/presentation/pages/splash_page/initial_pages.dart';
import 'package:gym_lead_master/src/presentation/pages/splash_page/splash_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_home_page/member_home_page.dart';
import 'package:gym_lead_master/src/presentation/pages/signUp_page/gym_Admin_signUp_Page.dart';
import 'package:gym_lead_master/src/presentation/pages/signUp_page/gym_member_sigUp_page.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.initialPage:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.loginChooserPage:
        return MaterialPageRoute(builder: (_) => InitialPages());
      //  ------------------------- //
      case AppRoutes.gymAdminLogInPage:
        return MaterialPageRoute(builder: (_) => GymAdminLoginPage());
      case AppRoutes.gymMemberLoginPage:
        return MaterialPageRoute(builder: (_) => GymMemberLogInPage());
      case AppRoutes.gymAdminSignUpPage:
        return MaterialPageRoute(builder: (_) => GymAdminSignupPage());
      case AppRoutes.gymMemberSignUpPage:
        return MaterialPageRoute(builder: (_) => GymMemberSignUpPage());
      case AppRoutes.adminHomePage:
        return MaterialPageRoute(builder: (_) => adminHomePage());
      case AppRoutes.checkInPage:
        return MaterialPageRoute(builder: (_) => ActiveMemberListPage());
      // In appRouter.dart
      case AppRoutes.helpFaqPage:
        return MaterialPageRoute(builder: (_) => const HelpFaqScreen());
      case AppRoutes.contactSupportPage:
        return MaterialPageRoute(builder: (_) => const ContactSupportScreen());
      case AppRoutes.aboutAppPage:
        return MaterialPageRoute(builder: (_) => const AboutAppScreen());
      case AppRoutes.termsPage:
        return MaterialPageRoute(
          builder: (_) => const TermsAndConditionsScreen(),
        );
      case AppRoutes.memberHomePage:
        return MaterialPageRoute(builder: (_) => MemeberHomePage());
      case AppRoutes.privacyPolicyPage:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());
      case AppRoutes.forgetPasswordPage:
        return MaterialPageRoute(builder: (_) => const ForgetPasswordPage());
      case AppRoutes.memberNotificationsPage:
        return MaterialPageRoute(
          builder: (_) => const MemberNotificationsScreen(),
        );
      case AppRoutes.adminNotificationsPage:
        return MaterialPageRoute(
          builder: (_) => const AdminNotificationsScreen(),
        );
      case AppRoutes.gymMembersPage:
        return MaterialPageRoute(builder: (_) => const GymMembersPage());
      case AppRoutes.attendanceDashboardPage:
        {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder:
                (_) => AttendanceDashboardScreen(gymId: args['gymId']),
          );
        }
      case AppRoutes.attendanceMonthPage:
        {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder:
                (_) => AttendanceMonthScreen(
                  gymId: args['gymId'],
                  monthKey: args['monthKey'],
                  monthLabel: args['monthLabel'],
                  year: args['year'],
                  monthNum: args['monthNum'],
                ),
          );
        }
      case AppRoutes.memberDetailPage:
        {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder:
                (_) => MemberDetailScreen(
                  gymId: args['gymId'],
                  memberData: args['memberData'],
                ),
          );
        }
      case AppRoutes.chatDetailPage:
        {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder:
                (_) => ChatDetailScreen(
                  gymId: args['gymId'],
                  receiverUid: args['receiverUid'],
                  receiverName: args['receiverName'],
                  receiverImageBase64: args['receiverImageBase64'],
                  receiverImageUrl: args['receiverImageUrl'],
                ),
          );
        }
      case AppRoutes.createNotificationPage:
        {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder:
                (_) => CreateNotificationScreen(gymId: args['gymId']),
          );
        }
      case AppRoutes.pendingApprovalsPage:
        {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder:
                (_) => PendingApprovalsScreen(gymId: args['gymId']),
          );
        }
      default:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text("404 - Page Not Found")),
              ),
        );
    }
  }
}
