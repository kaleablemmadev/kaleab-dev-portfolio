import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/select_mode_service.dart';
import '../services/highlight_service.dart';
import 'event_card.dart';

class SwipeableEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const SwipeableEventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectMode = SelectModeService();
    final highlightService = HighlightService();

    return ListenableBuilder(
      listenable: Listenable.merge([selectMode, highlightService]),
      builder: (context, _) {
        final isSelected = selectMode.isSelected(event.id);
        final isSelectionMode = selectMode.isSelectionMode;

        return Dismissible(
          key: Key(event.id),
          direction: isSelectionMode ? DismissDirection.none : DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await _showDeleteConfirmation(context);
          },
          onDismissed: (direction) {
            EventService().deleteEvent(event);
            _showUndoSnackBar(context);
          },
          child: MouseRegion(
            // ✅ Desktop: Hover highlights
            onEnter: (_) {
              if (!isSelectionMode) {
                highlightService.highlightEvent(event.id, event.date);
              }
            },
            onExit: (_) {
              highlightService.clearHighlightedEvent();
            },
            child: GestureDetector(
              onTap: () {
                // ✅ Normal tap: Opens the event
                if (isSelectionMode) {
                  selectMode.toggleSelection(event.id);
                } else {
                  // Clear highlight when navigating
                  highlightService.clearHighlightedEvent();
                  onTap();
                }
              },
              onLongPress: () {
                // ✅ Long press: Highlights the day!
                if (!isSelectionMode) {
                  // Highlight the day
                  highlightService.highlightEvent(event.id, event.date);
                  
                  // Optional: Show a visual feedback (haptic feedback)
                  _triggerHapticFeedback(context);
                  
                  // Optional: Show a toast/snackbar
                  _showHighlightFeedback(context);
                } else {
                  // If in selection mode, toggle selection
                  selectMode.toggleSelection(event.id);
                }
              },
              child: EventCard(
                event: event,
                onTap: null, // Handled by GestureDetector
                onLongPress: null, // Handled by GestureDetector
                showCheckbox: isSelectionMode,
                isSelected: isSelected,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event?'),
        content: Text('${event.title} will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showUndoSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Event deleted'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => EventService().undoDelete(),
        ),
      ),
    );
  }

  void _triggerHapticFeedback(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS) {
      // Use haptic feedback package or native vibration
      // HapticFeedback.lightImpact();
    }
  }

  void _showHighlightFeedback(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📍 Highlighted: ${event.date.day} ${_getMonthName(event.date)}'),
        duration: const Duration(milliseconds: 800),
        backgroundColor: event.color.withOpacity(0.8),
      ),
    );
  }

  String _getMonthName(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }
}