import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_client_detail_screen.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class TrainerCustomersScreen extends StatefulWidget {
  const TrainerCustomersScreen({super.key});

  @override
  State<TrainerCustomersScreen> createState() => _TrainerCustomersScreenState();
}

class _TrainerCustomersScreenState extends State<TrainerCustomersScreen> {
  List<Map<String, dynamic>> _clients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'active'; // 'active' or 'all'

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerCustomers,
        queryParameters: {
          'status': _statusFilter,
          if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = (response.data is Map)
            ? (response.data['results'] ?? [])
            : (response.data as List<dynamic>);
        setState(() {
          _clients = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load clients');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading clients: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        leading: const PopButton().center,
        title: Text(
          'My Clients',
          style: AppStyles.text18Px.poppins.w600.dark,
        ),
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                        EasyDebounce.debounce(
                          'clients-search',
                          const Duration(milliseconds: 400),
                          () => _fetchClients(),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name or mobile...',
                        hintStyle: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textGrey, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Status Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterTab(
                  label: 'Active Members',
                  value: 'active',
                ),
                const SizedBox(width: 10),
                _buildFilterTab(
                  label: 'All Assigned',
                  value: 'all',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Clients list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _clients.isEmpty
                    ? Center(
                        child: Text(
                          'No clients found!',
                          style: AppStyles.text14Px.poppins.w400.dark,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchClients,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          itemCount: _clients.length,
                          itemBuilder: (context, index) {
                            final client = _clients[index];
                            final isActiveMember = client['is_active_member'] ?? false;
                            final customerId = client['customer_id'] ?? 0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.iconBackground,
                                  ),
                                  child: ClipOval(
                                    child: client['profile_picture'] != null
                                        ? Image.network(
                                            client['profile_picture'] as String,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.person, color: AppColors.primary),
                                          )
                                        : const Icon(Icons.person, color: AppColors.primary),
                                  ),
                                ),
                                title: Text(
                                  client['name'] ?? 'N/A',
                                  style: AppStyles.text14Px.poppins.w600,
                                ),
                                subtitle: client['mobile'] != null
                                    ? Text(
                                        client['mobile'] as String,
                                        style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                      )
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isActiveMember
                                            ? const Color(0xffE8F5E9)
                                            : const Color(0xffFFEAEA),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isActiveMember ? 'Active' : 'Inactive',
                                        style: AppStyles.text12Px.poppins.w600.copyWith(
                                          color: isActiveMember
                                              ? const Color(0xFF43A047)
                                              : AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: AppColors.textGrey,
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  await Navigator.push<dynamic>(
                                    context,
                                    MaterialPageRoute<dynamic>(
                                      builder: (context) => TrainerClientDetailScreen(customerId: customerId),
                                    ),
                                  );
                                  _fetchClients();
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab({required String label, required String value}) {
    final isSelected = _statusFilter == value;
    return InkWell(
      onTap: () {
        if (!isSelected) {
          setState(() {
            _statusFilter = value;
          });
          _fetchClients();
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppStyles.text12Px.poppins.w600.copyWith(
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
