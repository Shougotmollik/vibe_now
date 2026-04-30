import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/views/home/home_screen.dart';
import 'package:vibe_now/model/google_map_location.dart';

import 'package:http/http.dart' as http;

class MapSearchScreen extends StatefulWidget {
  final void Function(GoogleMapSearchModel)? onSearchSelect;
  final String apiKey;

  const MapSearchScreen({super.key, required this.apiKey, this.onSearchSelect});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  final _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _searchDelayTimer;
  Color textColor = Color(0xff181818);
  Color surfaceColor = AppColors.backgroundVariant;

  List<GoogleMapSearchModel> _searchResults = [];
  List<GoogleMapSearchModel> _searchHistory = [];

  @override
  void initState() {
    super.initState();

    _loadHistory();

    Future.delayed(Duration(milliseconds: 20), () {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDelayTimer?.cancel();
    super.dispose();
  }

  String _searchIcon() {
    return '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M18.031 16.6166L22.3137 20.8993L20.8995 22.3135L16.6168 18.0308C15.0769 19.2628 13.124 19.9998 11 19.9998C6.032 19.9998 2 15.9678 2 10.9998C2 6.03176 6.032 1.99976 11 1.99976C15.968 1.99976 20 6.03176 20 10.9998C20 13.1238 19.263 15.0767 18.031 16.6166ZM16.0247 15.8746C17.2475 14.6144 18 12.8954 18 10.9998C18 7.13226 14.8675 3.99976 11 3.99976C7.1325 3.99976 4 7.13226 4 10.9998C4 14.8673 7.1325 17.9998 11 17.9998C12.8956 17.9998 14.6146 17.2473 15.8748 16.0245L16.0247 15.8746Z" fill="white"/></svg>';
  }

  String _searchLocationIcon() {
    return '<?xml version="1.0" ?><svg viewBox="0 0 384 512" xmlns="http://www.w3.org/2000/svg"><path fill="#6750A4" d="M192 0C85.97 0 0 85.97 0 192c0 77.41 26.97 99.03 172.3 309.7c9.531 13.77 29.91 13.77 39.44 0C357 291 384 269.4 384 192C384 85.97 298 0 192 0zM192 271.1c-44.13 0-80-35.88-80-80S147.9 111.1 192 111.1s80 35.88 80 80S236.1 271.1 192 271.1z"/></svg>';
  }

  Future<void> _saveToHistory(GoogleMapSearchModel item) async {
    final SharedPreferences localStorage =
        await SharedPreferences.getInstance();

    List<dynamic> str = jsonDecode(
      localStorage.getString('google-map-location-search-history') ?? '[]',
    );

    List<Map<String, dynamic>> history = List<Map<String, dynamic>>.from(str);

    history.removeWhere((element) => element['placeId'] == item.placeId);
    history.add({'placeId': item.placeId, 'description': item.description});

    localStorage.setString(
      'google-map-location-search-history',
      jsonEncode(history),
    );

    return null;
  }

  Widget _searchHistoryItemWidget(GoogleMapSearchModel item, int index) {
    return GestureDetector(
      onTap: () {
        widget.onSearchSelect?.call(item);
        Navigator.of(context).pop();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 18.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12.w,
          children: [
            Icon(
              Icons.history,
              size: 20.w,
              color: textColor.withValues(alpha: 0.8),
            ),
            Expanded(
              child: Text(
                item.description,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.8),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () {
                _removeHistoryItem(item);
              },
              child: Icon(Icons.close, color: Color(0xFF181818), size: 20.w),
            ),
          ],
        ),
      ),
    );
  }

  void _loadHistory() async {
    final SharedPreferences localStorage =
        await SharedPreferences.getInstance();

    List<dynamic> str = jsonDecode(
      localStorage.getString('google-map-location-search-history') ?? '[]',
    );

    List<GoogleMapSearchModel> history = str.map((item) {
      return GoogleMapSearchModel(
        description: item['description'],
        placeId: item['placeId'],
      );
    }).toList();

    setState(() {
      _searchHistory = history;
    });
    return;
  }

  void _handleSearch(String value) {
    _searchDelayTimer?.cancel();

    _searchDelayTimer = Timer(const Duration(milliseconds: 500), () async {
      if (value.isEmpty) {
        setState(() {
          _searchResults = [];
        });

        return;
      }

      final autoComplete = await fetchAutocompletePredictions(value);
      if (autoComplete == null) return;

      setState(() {
        _searchResults = autoComplete.map((item) {
          return GoogleMapSearchModel(
            description: item['description'],
            placeId: item['place_id'],
          );
        }).toList();
      });
    });
  }

  Future<List<Map<String, dynamic>>?> fetchAutocompletePredictions(
    String input,
  ) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=${widget.apiKey}&types=geocode',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        List<Map<String, dynamic>> predictions = [];
        for (var prediction in data['predictions']) {
          predictions.add(prediction);
        }

        return predictions; // List of predictions
      } else {
        debugPrint('API Error: ${data['status']}');
        return null;
      }
    } else {
      return null;
    }
  }

  Widget _searchWidget() {
    return SafeArea(
      bottom: false,
      child: Row(
        spacing: 8.w,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.background,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Theme.of(context).colorScheme.onSurface,
                size: 14.w,
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.string(
                    _searchIcon(),
                    width: 20.w,
                    height: 20.w,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      onChanged: (value) async {
                        _handleSearch(value);
                      },
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13.sp,
                        ),
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Search ...',
                        contentPadding: EdgeInsets.all(0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.background,
              ),
              child: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onSurface,
                size: 14.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchItemWidget(GoogleMapSearchModel item, int index) {
    return GestureDetector(
      onTap: () async {
        await _saveToHistory(item);
        widget.onSearchSelect?.call(item);
        Navigator.of(context).pop();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 18.h),
        padding: EdgeInsets.only(bottom: 18.h),
        decoration: BoxDecoration(
          border: index == _searchResults.length - 1
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                    width: 1.w,
                  ),
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12.w,
          children: [
            SvgPicture.string(_searchLocationIcon(), width: 18.w, height: 18.w),
            Expanded(
              child: Text(
                item.description,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14.sp,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeAllHistory() async {
    final SharedPreferences localStorage =
        await SharedPreferences.getInstance();

    setState(() {
      _searchHistory = [];
    });

    await localStorage.remove('google-map-location-search-history');
  }

  void _removeHistoryItem(GoogleMapSearchModel target) async {
    final SharedPreferences localStorage =
        await SharedPreferences.getInstance();

    setState(() {
      _searchHistory = _searchHistory
          .where((item) => item.placeId != target.placeId)
          .toList();
    });

    await localStorage.setString(
      'google-map-location-search-history',
      jsonEncode(
        _searchHistory.map((item) {
          return {'placeId': item.placeId, 'description': item.description};
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.surfaceVariant,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _searchWidget(),
              if (_searchResults.isNotEmpty) SizedBox(height: 36.h),
              if (_searchResults.isNotEmpty)
                ..._searchResults.asMap().entries.map((entry) {
                  int index = entry.key;
                  GoogleMapSearchModel item = entry.value;
                  return _searchItemWidget(item, index);
                }).toList(),
              if (_searchResults.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'History',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: _removeAllHistory,
                        child: Text(
                          'Clear All',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_searchResults.isEmpty)
                ..._searchHistory.asMap().entries.map((entry) {
                  int index = entry.key;
                  GoogleMapSearchModel item = entry.value;

                  return _searchHistoryItemWidget(item, index);
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
