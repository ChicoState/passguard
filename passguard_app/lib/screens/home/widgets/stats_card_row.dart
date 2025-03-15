// lib/screens/home/widgets/stats_card_row.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:passguard_app/theme.dart';

class StatsCardRow extends StatelessWidget {
  final String userId;
  const StatsCardRow({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: collectionRef,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final totalAccounts = docs.length;
        final compromisedAccounts = docs
            .where((doc) => (doc.data() as Map<String, dynamic>)['isCompromised'] == true)
            .length;
        final safeAccounts = totalAccounts - compromisedAccounts;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //"cards" row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Total Accounts",
                    "$totalAccounts",
                    Icons.folder,
                  ),
                ),
                const SizedBox(width: kDefaultPadding),
                Expanded(
                  child: _buildStatCard(
                    "Compromised",
                    "$compromisedAccounts",
                    Icons.warning_amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: kDefaultPadding),

            //chart
            Container(
              padding: const EdgeInsets.all(kDefaultPadding),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: const Offset(0, 5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: totalAccounts == 0
                  ? const Center(
                      child: Text(
                        'No chart to display (0 accounts).',
                        style: TextStyle(color: kTextColor),
                      ),
                    )
                  : SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 50,
                          startDegreeOffset: -90,
                          sections: [
                            PieChartSectionData(
                              color: Colors.redAccent,
                              value: compromisedAccounts.toDouble(),
                              showTitle: false,
                              radius: 25,
                            ),
                            PieChartSectionData(
                              color: kPrimaryColor,
                              value: safeAccounts.toDouble(),
                              showTitle: false,
                              radius: 25,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: const Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: kPrimaryColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: kTextColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: kTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
