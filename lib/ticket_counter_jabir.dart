import 'package:flutter/material.dart';

class TicketCounterJabir extends StatefulWidget {
  final int basePrice;
  final ValueChanged<int>? onTicketCountChanged; // Callback when ticket count changes

  const TicketCounterJabir({
    Key? key,
    required this.basePrice,
    this.onTicketCountChanged,
  }) : super(key: key);

  @override
  _TicketCounterJabirState createState() => _TicketCounterJabirState();
}

class _TicketCounterJabirState extends State<TicketCounterJabir> {
  int ticketCount = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jumlah Tiket',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, size: 18),
                    onPressed: () {
                      setState(() {
                        if (ticketCount > 1) ticketCount--;
                      });
                      // Call the callback when ticket count changes
                      if (widget.onTicketCountChanged != null) {
                        widget.onTicketCountChanged!(ticketCount);
                      }
                    },
                  ),
                  Text('$ticketCount'),
                  IconButton(
                    icon: Icon(Icons.add, size: 18),
                    onPressed: () {
                      setState(() {
                        if (ticketCount < 10) ticketCount++; // Max 10 tickets
                      });
                      // Call the callback when ticket count changes
                      if (widget.onTicketCountChanged != null) {
                        widget.onTicketCountChanged!(ticketCount);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Total: Rp ${(widget.basePrice * ticketCount).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{3})$|^(\d{3})(?=\d)', multiLine: true), (Match m) => '${m[0]},-')}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}