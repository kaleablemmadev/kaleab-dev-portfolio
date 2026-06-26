import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import '../../core/theme.dart';
import 'add_event_sheet.dart';

class EventListItem extends ConsumerStatefulWidget {
  final Event event;

  const EventListItem({super.key, required this.event});

  @override
  ConsumerState<EventListItem> createState() => _EventListItemState();
}

class _EventListItemState extends ConsumerState<EventListItem> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.textPrimary),
      ),
      onDismissed: (_) {
        ref.read(allEventsProvider.notifier).deleteEvent(widget.event.id);
        HapticFeedback.mediumImpact();
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          final AnimationController controller = BottomSheet.createAnimationController(this);
          controller.duration = const Duration(milliseconds: 350);
          controller.drive(CurveTween(curve: Curves.easeOutCubic));

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            transitionAnimationController: controller,
            backgroundColor: Colors.transparent,
            builder: (context) => AddEventSheet(event: widget.event),
          ).whenComplete(() => controller.dispose());
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border(
                    left: const BorderSide(color: AppTheme.primaryViolet, width: 4),
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    right: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(allEventsProvider.notifier).toggleCompletion(widget.event);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.event.isCompleted ? AppTheme.secondaryMint : Colors.transparent,
                          border: Border.all(
                            color: widget.event.isCompleted ? AppTheme.secondaryMint : AppTheme.textHint,
                            width: 2,
                          ),
                        ),
                        child: widget.event.isCompleted
                            ? const Icon(Icons.check, size: 16, color: AppTheme.backgroundDark)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.event.title,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    decoration: widget.event.isCompleted ? TextDecoration.lineThrough : null,
                                    color: widget.event.isCompleted ? AppTheme.textHint : AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              if (widget.event.reminderEnabled && !widget.event.isCompleted)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.notifications_active_outlined, size: 14, color: AppTheme.primaryIndigo),
                                ),
                            ],
                          ),
                          if (widget.event.note != null && widget.event.note!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.event.note!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (widget.event.time != null)
                      Text(
                        DateFormat.jm().format(widget.event.time!),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: widget.event.isCompleted ? AppTheme.textHint : AppTheme.primaryIndigo,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
