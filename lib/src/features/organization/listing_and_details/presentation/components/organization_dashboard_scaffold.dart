import 'package:mentor_mobile_app/imports_bindings.dart';

class OrganizationDashboardScaffold extends StatefulWidget {
  const OrganizationDashboardScaffold({
    required this.pages,
    super.key,
    this.initialIndex = 0,
    this.profileImageUrl,
    this.floatingActionButtons,
  });
  final List<Widget> pages;
  final int initialIndex;
  final String? profileImageUrl;
  final List<Widget?>? floatingActionButtons;

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
    if (!mounted) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: widget.pages),
      floatingActionButton:
          widget.floatingActionButtons != null &&
                  widget.floatingActionButtons!.length > _currentIndex
              ? widget.floatingActionButtons![_currentIndex]
              : null,
      bottomNavigationBar: OrganizationBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        profileImageUrl: widget.profileImageUrl,
      ),
    );
  }
}
