import 'package:flutter/material.dart';
import 'package:prayer_times/models/api_pars.dart';
import 'package:prayer_times/models/prayer_models.dart';
import 'package:prayer_times/services/api_service.dart';
import 'package:prayer_times/utils/date_helper.dart';
import 'package:prayer_times/utils/string_extensions.dart';
import 'package:prayer_times/widgets/prayer_list_view.dart';

class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key, required this.apiPars});
  final ApiPars apiPars;

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  late Future<PrayerMonth> _future;
  DateTime _selectedDay = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  List<GlobalKey> _keys = [];
  late int monthLength;

  void assignPrayerMonth() {
    _future =
        ApiService.getPrayerMonth(date: _selectedDay, apiPars: widget.apiPars);
  }

  void _scrollToItem(int index) {
    // Use WidgetsBinding to wait for the build to finish
    final keyContext = _keys[index].currentContext;
    if (keyContext != null) {
      RenderBox renderBox = keyContext.findRenderObject() as RenderBox;
      Offset offset = renderBox.localToGlobal(Offset.zero);
      double itemPosition = offset.dy;

      _scrollController.animateTo(
        itemPosition,
        duration: const Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    } else {
      // Retry after a delay if the context is still null
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToItem(index);
      });
    }
  }

  @override
  void didUpdateWidget(covariant MonthlyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.apiPars.city != oldWidget.apiPars.city ||
        widget.apiPars.country != oldWidget.apiPars.country ||
        widget.apiPars.method != oldWidget.apiPars.method) assignPrayerMonth();
  }

  @override
  void initState() {
    super.initState();
    _keys = List.generate(31, (i) => GlobalKey());
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
          monthLength = prayerMonth.length;
          return Column(
            children: [
              AppBar(
                backgroundColor: Theme.of(ctx).colorScheme.onInverseSurface,
                centerTitle: true,
                title: SizedBox(
                  width: MediaQuery.sizeOf(context).width * .5,
                  child: ElevatedButton(
                    // key: _keys[7],
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
                        sameMonth && sameYear ? null : assignPrayerMonth();

                        // Update key to scroll to the selected day
                        int i = _selectedDay.day - 1;
                        debugPrint('Selected key: ${_keys[i]}');
                        debugPrint(
                            'Selected key context: ${_keys[i].currentContext}');
                        _scrollToItem(i);
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
                child: ListView.builder(
                  // shrinkWrap: true, // 'Expanded' overrides its functionality
                  controller: _scrollController,
                  itemCount: prayerMonth.length,
                  itemBuilder: (c, i) {
                    final prayerList = prayerMonth[i].prayers.prayerList;
                    final Hijri hijri = prayerMonth[i].date.hijri;
                    final Gregorian gregorian = prayerMonth[i].date.gregorian;
                    return Padding(
                      key: _keys[i],
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
                                is24H: widget.apiPars.is24H,
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
