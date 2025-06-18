
import 'package:flutter/material.dart';
import '../services/visited_spot_service.dart';

class ArrivalPopup extends StatefulWidget {
  final NearbySpot nearbySpot;
  final VoidCallback onVisitedAdded;

  const ArrivalPopup({
    Key? key,
    required this.nearbySpot,
    required this.onVisitedAdded,
  }) : super(key: key);

  @override
  _ArrivalPopupState createState() => _ArrivalPopupState();
}

class _ArrivalPopupState extends State<ArrivalPopup> {
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  Future<void> _markAsVisited() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await VisitedSpotService.addVisitedSpot(
        spotId: widget.nearbySpot.spotId,
        notes: _notesController.text,
      );
      
      widget.onVisitedAdded();
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.nearbySpot.title} marked as visited!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark as visited: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              size: 48,
              color: Color(0xFFDDA15E),
            ),
            SizedBox(height: 16),
            Text(
              'You\'ve arrived!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF283618),
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.nearbySpot.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF606C38),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Distance: ${widget.nearbySpot.distance.toStringAsFixed(0)}m',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Would you like to mark this spot as visited?',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF283618),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Add notes about your visit (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF606C38)),
                ),
              ),
              maxLines: 3,
              minLines: 1,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text(
                      'Not Now',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _markAsVisited,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF283618),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Mark Visited',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

// Helper function to show the arrival popup
void showArrivalPopup(BuildContext context, NearbySpot nearbySpot, VoidCallback onVisitedAdded) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ArrivalPopup(
      nearbySpot: nearbySpot,
      onVisitedAdded: onVisitedAdded,
    ),
  );
}