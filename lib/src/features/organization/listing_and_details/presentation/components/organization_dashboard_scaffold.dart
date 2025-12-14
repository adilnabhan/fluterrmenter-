import 'package:mentor_mobile_app/imports_bindings.dart';

class OrganizationDashboardScaffold extends StatefulWidget {
  const OrganizationDashboardScaffold({
    required this.pages,
    super.key,
    this.initialIndex = 0,
    this.profileImageUrl,
  });
  final List<Widget> pages;
  final int initialIndex;
  final String? profileImageUrl;

  @override
  State<OrganizationDashboardScaffold> createState() =>
      _OrganizationDashboardScaffoldState();
}

class _OrganizationDashboardScaffoldState
    extends State<OrganizationDashboardScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: widget.pages),
      bottomNavigationBar: OrganizationBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        profileImageUrl: widget.profileImageUrl,
      ),
    );
  }
}
