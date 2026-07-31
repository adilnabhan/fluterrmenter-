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
  List<bool>? _initialized;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initList();
  }

  void _initList() {
    _initialized = List<bool>.generate(
      widget.pages.length,
      (index) => index == _currentIndex,
    );
  }

  void _onTap(int index) {
    if (!mounted) return;
    setState(() {
      _currentIndex = index;
      if (_initialized == null) {
        _initList();
      }
      if (index < _initialized!.length) {
        _initialized![index] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialized == null || _initialized!.length != widget.pages.length) {
      final oldList = _initialized;
      _initialized = List<bool>.generate(
        widget.pages.length,
        (index) {
          if (index == _currentIndex) return true;
          if (oldList != null && index < oldList.length) {
            return oldList[index];
          }
          return false;
        },
      );
    }

    return Scaffold(
      extendBody: false,
      body: IndexedStack(
        index: _currentIndex,
        children: List<Widget>.generate(
          widget.pages.length,
          (index) {
            if (index < _initialized!.length && _initialized![index]) {
              return widget.pages[index];
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
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
