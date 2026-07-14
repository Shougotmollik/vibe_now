import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vibe_now/controller/wave_controller.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/env.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/incoming_wave.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/common/custom_time_picker.dart';
import 'package:vibe_now/views/home/widgets/google_map.dart';

class ResheduleMeetupScreen extends StatefulWidget {
  final IncomingWave wave;

  const ResheduleMeetupScreen({super.key, required this.wave});

  @override
  State<ResheduleMeetupScreen> createState() => _ResheduleMeetupScreenState();
}

class _ResheduleMeetupScreenState extends State<ResheduleMeetupScreen> {
  final WaveController _waveController = Get.find<WaveController>();
  bool _isProcessing = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  GoogleMapLocation? _selectedLocation;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(3100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickLocation() async {
    final senderLoc = widget.wave.sender.currentLocation;
    final initialPos = LatLng(
      senderLoc?.latitude ?? 50.937,
      senderLoc?.longitude ?? 6.953,
    );

    GoogleMapLocation? picked;

    await Navigator.push<GoogleMapLocation>(
      context,
      MaterialPageRoute(
        builder: (context) => GoogleMapScreen(
          apiKey: EnvHandler.google_map_api_key,
          initialPosition: initialPos,
          canSelectLocation: true,
          showDemoMarkers: false,
          onLocationSelect: (location) {
            picked = location;
          },
        ),
      ),
    );

    if (picked != null && mounted) {
      setState(() => _selectedLocation = picked);
    }
  }

  Future<void> _handleReschedule() async {
    if (_selectedLocation == null) {
      AppSnackbar.show(
        message:
            AppLocalizations.of(context).translate('pleaseSelectLocation'),
        type: SnackType.error,
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      AppSnackbar.show(
        message:
            AppLocalizations.of(context).translate('pleaseSelectDateAndTime'),
        type: SnackType.error,
      );
      return;
    }

    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final scheduledAt =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(scheduledDateTime);

    final success = await _waveController.meetupReschedule(
      waveId: widget.wave.waveId,
      meetupType: 'later',
      locationType: 'custom',
      latitude: _selectedLocation!.position.latitude.toString(),
      longitude: _selectedLocation!.position.longitude.toString(),
      address: _selectedLocation!.name,
      reason: 'Rescheduled by user',
      requestedAt: scheduledAt,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      AppSnackbar.show(
        message: AppLocalizations.of(context).translate('meetupRescheduled'),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      AppSnackbar.show(
        message: AppLocalizations.of(context).translate('failedToReschedule'),
        type: SnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SafeArea(
              child: CustomAppBar(
                title: loc.translate('rescheduleMeetup'),
                canBack: true,
              ),
            ),
            SizedBox(height: 38.h),
            _buildSelectLocation(loc),
            const SizedBox(height: 16),
            _buildDateTimeRow(loc),
            const Spacer(),
            Row(
              spacing: 8.w,
              children: [
                Expanded(
                  child: PrimaryButton.text(
                    onPressed: _handleReschedule,
                    isEnabled: !_isProcessing,
                    isLoading: _isProcessing,
                    text: loc.translate('meetReschedule'),
                  ),
                ),
                Expanded(
                  child: CustomElevatedButton(
                    onTap: () => Navigator.pop(context),
                    buttonText: loc.translate('cancel'),
                    btnColor: Theme.of(context).colorScheme.surfaceVariant,
                    textColor: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectLocation(AppLocalizations loc) {
    final hasLocation = _selectedLocation != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('selectLocation'),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickLocation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  hasLocation
                      ? Icons.check_circle
                      : Icons.location_on_outlined,
                  color: hasLocation
                      ? Colors.green
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    hasLocation
                        ? _selectedLocation!.name
                        : loc.translate('selectAddress'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!hasLocation)
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeRow(AppLocalizations loc) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('communityDate'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          _selectedDate == null
                              ? loc.translate('select')
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('communityTime'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showTimePicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          _selectedTime == null
                              ? loc.translate('select')
                              : _selectedTime!.format(context),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomTimePicker(
        onTimeSelected: (time) {
          setState(() => _selectedTime = time);
        },
      ),
    );
  }
}
