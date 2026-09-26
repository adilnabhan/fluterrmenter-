import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_client_detail_screen.dart';

class TrainerClientsTrainedScreen extends StatefulWidget {
  final String rangeType;
  final String? date;
  final String title;

  const TrainerClientsTrainedScreen({
    super.key,
    this.rangeType = 'daily',
    this.date,
    this.title = 'Clients Trained Today',
  });

  @override
  State<TrainerClientsTrainedScreen> createState() =>
      _TrainerClientsTrainedScreenState();
}

class _TrainerClientsTrainedScreenState
    extends State<TrainerClientsTrainedScreen> {
  List<Map<String, dynamic>> _clients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchClientsTrained();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchClientsTrained() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final Map<String, dynamic> queryParams = {
        'range_type': widget.rangeType,
        'date': widget.date ?? todayStr,
        'page_size': 500,
      };

      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerClientsTrained,
        queryParameters: queryParams,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> rawList = [];
        if (response.data is List) {
          rawList = response.data as List<dynamic>;
        } else if (response.data is Map) {
          final dataMap = response.data as Map<String, dynamic>;
          rawList = (dataMap['clients'] ??
                  dataMap['results'] ??
                  dataMap['data'] ??
                  []) as List<dynamic>;
        }

        if (mounted) {
          setState(() {
            _clients =
                rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredClients {
    var list = _clients;

    if (widget.rangeType == 'daily') {
      final targetDate = widget.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
      final dateFiltered = list.where((c) {
        final d = (c['date'] ??
                c['last_verified_workout_date'] ??
                c['workout_date'] ??
                c['trained_date'])
            ?.toString();
        if (d != null && d.isNotEmpty && d.length >= 10) {
          return d.startsWith(targetDate);
        }
        if (c['trained_today'] == true || c['is_trained_today'] == true) {
          return true;
        }
        return true;
      }).toList();
      if (dateFiltered.isNotEmpty) {
        list = dateFiltered;
      }
    }

    if (_searchQuery.trim().isEmpty) return list;
    final q = _searchQuery.toLowerCase().trim();
    return list.where((c) {
      final name = (c['name'] ??
              '${c['first_name'] ?? ''} ${c['last_name'] ?? ''}')
          .toString()
          .toLowerCase();
      final email = (c['email'] ?? '').toString().toLowerCase();
      final mobile = (c['mobile_number'] ?? c['mobile'] ?? '')
          .toString()
          .toLowerCase();
      final org = (c['organization_name'] ?? '').toString().toLowerCase();
      return name.contains(q) ||
          email.contains(q) ||
          mobile.contains(q) ||
          org.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: const PopButton().center,
        title: Text(
          widget.title,
          style: AppStyles.text18Px.poppins.w600.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: context.colors.fieldFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.border),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search clients...',
                  hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                    color: AppColors.textGrey,
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textGrey, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: AppStyles.text14Px.poppins.w400.dark,
              ),
            ),
          ),

          // Client List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredClients.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'No clients match your search'
                              : 'No trained clients found',
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchClientsTrained,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredClients.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _buildClientTile(_filteredClients[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientTile(Map<String, dynamic> client) {
    final customerId = client['customer_id'] as int? ??
        client['client_id'] as int? ??
        client['id'] as int? ??
        0;

    final rawFirstName = client['first_name']?.toString() ?? '';
    final rawLastName = client['last_name']?.toString() ?? '';
    final fullNameFromParts = '$rawFirstName $rawLastName'.trim();

    final name = (client['name']?.toString().isNotEmpty == true)
        ? client['name'].toString()
        : fullNameFromParts.isNotEmpty
            ? fullNameFromParts
            : 'Client';

    final avatarUrl = (client['profile_picture'] ?? client['avatar'])?.toString();
    final orgName = (client['organization_name'] ?? client['org_name'] ?? '')
        .toString();
    final verifiedCount = client['verified_workouts_count'] as int? ??
        client['total_completed_workouts'] as int? ??
        0;
    final lastVerifiedDate = client['last_verified_workout_date']?.toString();

    return InkWell(
      onTap: () {
        if (customerId != 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TrainerClientDetailScreen(customerId: customerId),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            ClipOval(
              child: ProfileImage(
                isEdit: false,
                url: avatarUrl,
                radius: 48,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: context.colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (orgName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      orgName,
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff486CC2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$verifiedCount Verified',
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                      color: const Color(0xff486CC2),
                    ),
                  ),
                ),
                if (lastVerifiedDate != null &&
                    lastVerifiedDate.isNotEmpty &&
                    lastVerifiedDate != 'null') ...[
                  const SizedBox(height: 4),
                  Text(
                    lastVerifiedDate,
                    style: AppStyles.text10Px.poppins.w400.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
