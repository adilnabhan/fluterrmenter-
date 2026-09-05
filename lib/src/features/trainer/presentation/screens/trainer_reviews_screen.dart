import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:intl/intl.dart';

class TrainerReviewsScreen extends StatefulWidget {
  final int? trainerId;
  final String? trainerName;

  const TrainerReviewsScreen({
    this.trainerId,
    this.trainerName,
    super.key,
  });

  @override
  State<TrainerReviewsScreen> createState() => _TrainerReviewsScreenState();
}

class _TrainerReviewsScreenState extends State<TrainerReviewsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allReviews = [];
  int _reviewsCount = 0;
  double _averageRating = 0.0;
  int? _selectedStarFilter; // null = all, 1..5 = specific star

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final uri = widget.trainerId != null
          ? '${ApiUris.trainerReviews}?trainer_id=${widget.trainerId}'
          : ApiUris.trainerReviews;

      final res = await DioClient().dio.get<dynamic>(uri);

      if (res.statusCode == 200 && res.data != null) {
        var data = res.data;
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (_) {}
        }

        List results = [];
        int count = 0;
        double? avgFromApi;

        if (data is Map) {
          if (data['results'] is List) {
            results = data['results'] as List;
          } else if (data['result'] is List) {
            results = data['result'] as List;
          } else if (data['reviews'] is List) {
            results = data['reviews'] as List;
          } else if (data['data'] is List) {
            results = data['data'] as List;
          }

          count = (data['count'] as int?) ?? results.length;
          final rawAvg = data['avg_rating'] ?? data['average_rating'] ?? data['rating'];
          if (rawAvg != null) {
            avgFromApi = (rawAvg is num) ? rawAvg.toDouble() : double.tryParse(rawAvg.toString());
          }
        } else if (data is List) {
          results = data;
          count = results.length;
        }

        final mappedReviews = results
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        double computedAvg = 0.0;
        if (mappedReviews.isNotEmpty) {
          double sum = 0.0;
          for (final r in mappedReviews) {
            final rate = (r['rating'] as num?)?.toDouble() ??
                double.tryParse(r['rating']?.toString() ?? '0') ??
                0.0;
            sum += rate;
          }
          computedAvg = sum / mappedReviews.length;
        }

        if (!mounted) return;
        setState(() {
          _allReviews = mappedReviews;
          _reviewsCount = count > 0 ? count : mappedReviews.length;
          _averageRating = avgFromApi ?? computedAvg;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('❌ Error fetching reviews: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Map<int, int> get _starCounts {
    final counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in _allReviews) {
      final rate = (r['rating'] as num?)?.toDouble() ??
          double.tryParse(r['rating']?.toString() ?? '0') ??
          0.0;
      final star = rate.round().clamp(1, 5);
      counts[star] = (counts[star] ?? 0) + 1;
    }
    return counts;
  }

  List<Map<String, dynamic>> get _filteredReviews {
    if (_selectedStarFilter == null) return _allReviews;
    return _allReviews.where((r) {
      final rate = (r['rating'] as num?)?.toDouble() ??
          double.tryParse(r['rating']?.toString() ?? '0') ??
          0.0;
      return rate.round() == _selectedStarFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.trainerName != null
              ? '${widget.trainerName} - Reviews'
              : 'Ratings & Reviews',
          style: AppStyles.text16Px.poppins.w600.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: context.colors.icon),
            onPressed: _fetchReviews,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingShimmer()
          : RefreshIndicator(
              onRefresh: _fetchReviews,
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCard(),
                          const SizedBox(height: 16),
                          _buildFilterChips(),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'User Reviews (${_filteredReviews.length})',
                                style: AppStyles.text14Px.poppins.w600.copyWith(
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              if (_selectedStarFilter != null)
                                GestureDetector(
                                  onTap: () => setState(() => _selectedStarFilter = null),
                                  child: Text(
                                    'Clear Filter',
                                    style: AppStyles.text12Px.poppins.w500.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_filteredReviews.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildReviewCard(_filteredReviews[index]),
                            );
                          },
                          childCount: _filteredReviews.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 32),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    final starCounts = _starCounts;
    final total = _allReviews.isEmpty ? 1 : _allReviews.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Big Rating + Stars + Count
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _averageRating.toStringAsFixed(1),
                  style: AppStyles.text36Px.poppins.w700.copyWith(
                    color: context.colors.textPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                _buildStarRow(_averageRating, starSize: 18),
                const SizedBox(height: 6),
                Text(
                  '$_reviewsCount ${_reviewsCount == 1 ? 'Review' : 'Reviews'}',
                  style: AppStyles.text12Px.poppins.w500.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 90,
            width: 1,
            color: context.colors.border.withOpacity(0.8),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          // Right side: Rating Distribution Progress Bars (5..1)
          Expanded(
            flex: 6,
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = starCounts[star] ?? 0;
                final ratio = count / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: AppStyles.text12Px.poppins.w600.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 6,
                            backgroundColor: context.colors.fieldFill,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              star >= 4
                                  ? const Color(0xFF16A34A)
                                  : (star == 3
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFFDC2626)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 20,
                        child: Text(
                          '$count',
                          textAlign: TextAlign.end,
                          style: AppStyles.text10Px.poppins.w500.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRow(double rating, {double starSize = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        if (rating >= starValue) {
          return Icon(Icons.star, color: Colors.amber, size: starSize);
        } else if (rating >= starValue - 0.5) {
          return Icon(Icons.star_half, color: Colors.amber, size: starSize);
        } else {
          return Icon(Icons.star_border, color: Colors.amber.withOpacity(0.5), size: starSize);
        }
      }),
    );
  }

  Widget _buildFilterChips() {
    final starCounts = _starCounts;
    final filters = <Map<String, dynamic>>[
      {'label': 'All (${_allReviews.length})', 'value': null},
      {'label': '5 ★ (${starCounts[5] ?? 0})', 'value': 5},
      {'label': '4 ★ (${starCounts[4] ?? 0})', 'value': 4},
      {'label': '3 ★ (${starCounts[3] ?? 0})', 'value': 3},
      {'label': '2 ★ (${starCounts[2] ?? 0})', 'value': 2},
      {'label': '1 ★ (${starCounts[1] ?? 0})', 'value': 1},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedStarFilter == f['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                f['label'] as String,
                style: AppStyles.text12Px.poppins.w600.copyWith(
                  color: isSelected ? Colors.white : context.colors.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedStarFilter = f['value'] as int?;
                });
              },
              selectedColor: AppColors.primary,
              backgroundColor: context.colors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : context.colors.border,
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final name = review['customer_name']?.toString() ??
        review['user_name']?.toString() ??
        review['name']?.toString() ??
        'User';

    String formattedDate = '';
    final rawDate = review['created_at'] ?? review['date'] ?? review['created_date'];
    if (rawDate != null) {
      try {
        final dt = DateTime.parse(rawDate.toString());
        formattedDate = DateFormat('dd MMM yyyy').format(dt);
      } catch (_) {
        formattedDate = rawDate.toString();
      }
    }

    final ratingVal = (review['rating'] as num?)?.toDouble() ??
        double.tryParse(review['rating']?.toString() ?? '0.0') ??
        0.0;
    final comment = review['comment']?.toString() ??
        review['review']?.toString() ??
        review['feedback']?.toString() ??
        '';
    final avatar = review['profile_picture']?.toString() ??
        review['avatar']?.toString() ??
        review['image']?.toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: (avatar != null && avatar.trim().isNotEmpty && avatar != 'null')
                    ? NetworkImage(avatar)
                    : null,
                child: (avatar == null || avatar.trim().isEmpty || avatar == 'null')
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: AppStyles.text14Px.poppins.w600.copyWith(
                          color: AppColors.primary,
                        ),
                      )
                    : null,
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
                    if (formattedDate.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: AppStyles.text10Px.poppins.w400.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Rating Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7), // soft gold
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Color(0xFFD97706), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      ratingVal.toStringAsFixed(1),
                      style: AppStyles.text12Px.poppins.w700.copyWith(
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _ExpandableCommentText(text: comment.trim()),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.fieldFill,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_outline_rounded,
                size: 48,
                color: AppColors.textGrey.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedStarFilter != null
                  ? 'No $_selectedStarFilter-star reviews yet'
                  : 'No reviews received yet',
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _selectedStarFilter != null
                  ? 'Try selecting "All" or a different star rating.'
                  : 'Client ratings and reviews will appear here once submitted.',
              textAlign: TextAlign.center,
              style: AppStyles.text12Px.poppins.w400.copyWith(
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              4,
              (index) => Container(
                width: 70,
                height: 32,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  height: 90,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: context.colors.card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableCommentText extends StatefulWidget {
  final String text;

  const _ExpandableCommentText({required this.text});

  @override
  State<_ExpandableCommentText> createState() => _ExpandableCommentTextState();
}

class _ExpandableCommentTextState extends State<_ExpandableCommentText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    const int maxChars = 140;
    final shouldTruncate = widget.text.length > maxChars;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (_isExpanded || !shouldTruncate)
              ? widget.text
              : '${widget.text.substring(0, maxChars)}...',
          style: AppStyles.text13Px.poppins.w400.copyWith(
            color: context.colors.textPrimary.withOpacity(0.85),
            height: 1.45,
          ),
        ),
        if (shouldTruncate)
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _isExpanded ? 'Read less' : 'Read more',
                style: AppStyles.text12Px.poppins.w600.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
