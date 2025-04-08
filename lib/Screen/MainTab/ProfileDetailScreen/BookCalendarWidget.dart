import 'package:book_nexus/Constant/colors.dart';
import 'package:book_nexus/model/Book/ReadingHistoryEntry.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import 'BookCalendarController.dart';

class BookCalendarWidget extends StatelessWidget {
  final BookCalendarController controller = Get.put(BookCalendarController());

  BookCalendarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: AppColors.green,
          ),
        );
      }

      if (controller.hasError.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: controller.loadReadingHistory,
                child: Text('Try Again'),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          _buildCalendar(),
          SizedBox(height: 2.h),
          _buildEventList(),
          SizedBox(height: 2.h),
          _buildEventDetails(),
        ],
      );
    });
  }

  Widget _buildCalendar() {
    return Obx(() => TableCalendar<ReadingHistoryEntry>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: controller.focusedDay.value,
          selectedDayPredicate: (day) =>
              isSameDay(controller.selectedDay.value, day),
          calendarFormat: CalendarFormat.month,
          eventLoader: controller.getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            markersMaxCount: 3,
            markerDecoration: BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              color: AppColors.white100Color,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: AppColors.white100Color,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: AppColors.white100Color,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: AppColors.white100Color),
            weekendStyle: TextStyle(color: AppColors.white100Color),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, date, _) {
              return Container(
                margin: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey4,
                ),
                child: Text(
                  date.day.toString(),
                  style: TextStyle(color: AppColors.white100Color),
                ),
              );
            },
          ),
          onDaySelected: controller.onDaySelected,
        ));
  }

  Widget _buildEventList() {
    return Obx(() {
      final events = controller.getEventsForDay(controller.selectedDay.value);
      
      if (events.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Text(
            'No books read on this day',
            style: TextStyle(
              color: AppColors.white100Color,
              fontSize: 16.sp,
            ),
          ),
        );
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(
              'Books read on ${controller.formatDate(controller.selectedDay.value)}:',
              style: TextStyle(
                color: AppColors.white100Color,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            height: 15.h,
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return InkWell(
                  onTap: () => controller.onEventSelected(event),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 2.w),
                    padding: EdgeInsets.all(1.h),
                    decoration: BoxDecoration(
                      color: AppColors.grey4,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: controller.selectedEvent.value?.id == event.id
                            ? AppColors.green
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (event.bookCoverUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              event.bookCoverUrl!,
                              height: 10.h,
                              width: 15.w,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 10.h,
                                  width: 15.w,
                                  color: Colors.grey,
                                  child: Icon(Icons.book, color: Colors.white),
                                );
                              },
                            ),
                          )
                        else
                          Container(
                            height: 10.h,
                            width: 15.w,
                            color: Colors.grey,
                            child: Icon(Icons.book, color: Colors.white),
                          ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                event.bookTitle,
                                style: TextStyle(
                                  color: AppColors.white100Color,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                'Read at: ${controller.formatTime(event.readDate.toDate())}',
                                style: TextStyle(
                                  color: AppColors.white100Color,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEventDetails() {
    return Obx(() {
      final event = controller.selectedEvent.value;
      
      if (event == null) {
        return SizedBox.shrink();
      }
      
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        padding: EdgeInsets.all(2.h),
        decoration: BoxDecoration(
          color: AppColors.grey4,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Details',
              style: TextStyle(
                color: AppColors.white100Color,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                if (event.bookCoverUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                      event.bookCoverUrl!,
                      height: 15.h,
                      width: 20.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 15.h,
                          width: 20.w,
                          color: Colors.grey,
                          child: Icon(Icons.book, color: Colors.white),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 15.h,
                    width: 20.w,
                    color: Colors.grey,
                    child: Icon(Icons.book, color: Colors.white),
                  ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.bookTitle,
                        style: TextStyle(
                          color: AppColors.white100Color,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Date: ${controller.formatDate(event.readDate.toDate())}',
                        style: TextStyle(
                          color: AppColors.white100Color,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Time: ${controller.formatTime(event.readDate.toDate())}',
                        style: TextStyle(
                          color: AppColors.white100Color,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Progress: ${(event.progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: AppColors.white100Color,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}