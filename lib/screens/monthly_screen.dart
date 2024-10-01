import 'package:flutter/material.dart';
import 'package:prayer_times/models/user_settings.dart';
import 'package:prayer_times/models/prayer_models.dart';
import 'package:prayer_times/services/api_service.dart';
import 'package:prayer_times/utils/date_helper.dart';
import 'package:prayer_times/utils/string_extensions.dart';
import 'package:prayer_times/widgets/prayer_list_view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key, required this.settings});
  final UserSettings settings;

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  late Future<PrayerMonth> _future;
  DateTime _selectedDay = DateTime.now();
  int _selectedIndex = DateTime.now().day - 1;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();

  Future<void> assignPrayerMonth() async {
    _future =
        ApiService.getPrayerMonth(date: _selectedDay, apiPars: widget.settings);
    await _future;

    _scrollToItem(_selectedIndex);
  }

  void _scrollToItem(int index) {
    // 'WidgetsBinding.instance.addPostFrameCallback' evades exception that occurs due to calling '_scrollToItem' method before 'ScrollablePositionedList' widget is fully built and ready to be scrolled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!itemScrollController.isAttached) return;

      itemScrollController.scrollTo(
          index: index,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOutCubic);
    });
  }

  @override
  void didUpdateWidget(covariant MonthlyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.settings.city != oldWidget.settings.city ||
        widget.settings.country != oldWidget.settings.country ||
        widget.settings.method != oldWidget.settings.method)
      assignPrayerMonth();
  }

  @override
  void initState() {
    super.initState();
    assignPrayerMonth();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Loading
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Error
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data received.')); // No data
        } else if (snapshot.hasData) {
          final prayerMonth = snapshot.data!.monthData;
          return Column(
            children: [
              AppBar(
                backgroundColor: Theme.of(ctx).colorScheme.onInverseSurface,
                centerTitle: true,
                title: SizedBox(
                  width: MediaQuery.sizeOf(context).width * .5,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                      Theme.of(ctx).colorScheme.primary.withOpacity(.7),
                    )),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDay,
                        firstDate: DateTime(DateTime.now().year),
                        lastDate: DateTime(DateTime.now().year + 62),
                      );
                      final sameDay = DateUtils.isSameDay(picked, _selectedDay);
                      if (picked != null && !sameDay) {
                        final sameMonth = _selectedDay.month == picked.month;
                        final sameYear = _selectedDay.year == picked.year;
                        setState(() => _selectedDay = picked);

                        // Update key to scroll to the selected day
                        _selectedIndex = _selectedDay.day - 1;
                        if (sameMonth && sameYear) {
                          _scrollToItem(_selectedIndex);
                        } else {
                          assignPrayerMonth();
                        }
                      }
                    },
                    child: Text(
                      '${DateHelper.monthsAr[_selectedDay.month - 1]} ${_selectedDay.year}',
                      style: TextStyle(
                        color: Theme.of(ctx).colorScheme.onInverseSurface,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ScrollablePositionedList.builder(
                  // shrinkWrap: true, // 'Expanded' overrides its functionality
                  itemScrollController: itemScrollController,
                  scrollOffsetController: scrollOffsetController,
                  itemPositionsListener: itemPositionsListener,
                  scrollOffsetListener: scrollOffsetListener,
                  itemCount: prayerMonth.length,
                  itemBuilder: (c, i) {
                    final prayerList = prayerMonth[i].prayers.prayerList;
                    final Hijri hijri = prayerMonth[i].date.hijri;
                    final Gregorian gregorian = prayerMonth[i].date.gregorian;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color:
                            Theme.of(ctx).colorScheme.outline.withOpacity(.27),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      '${hijri.day} ${hijri.monthAr} ${hijri.year}'
                                          .toArNums()),
                                  Text(hijri.weekdayAr),
                                  Text(gregorian.date.toArNums()),
                                ],
                              ),
                              PrayerListView(
                                prayerList: prayerList,
                                is24H: widget.settings.is24H,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return const Center(child: Text('Unexpected error.')); // Fallback
        }
      },
    );
  }
}
