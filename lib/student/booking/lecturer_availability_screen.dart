import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import './slot_booking_screen.dart';

class LecturerAvailabilityScreen extends StatelessWidget {
  const LecturerAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lecturerId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: AppColors.availabilitybg,
      appBar: AppBar(
        backgroundColor: AppColors.availabilitybg,
        elevation: 0,
        leading: const BackButton(),
        centerTitle: true,
        title: const Text(
          "Availability",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(lecturerId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Lecturer not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final status = data['status'] ?? 'away';

          Color statusColor;
          String statusText;
          IconData statusIcon;

          switch (status) {
            case 'available':
              statusColor = AppColors.green;
              statusText = "Available at Cabin";
              statusIcon = Icons.check_circle;
              break;

            case 'leave':
              statusColor = AppColors.red;
              statusText = "On Leave";
              statusIcon = Icons.block;
              break;

            default:
              statusColor = AppColors.yellow;
              statusText = "Temporary Away";
              statusIcon = Icons.hourglass_empty;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),

                
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage:
                      (data['photoUrl'] != null &&
                              data['photoUrl'].toString().isNotEmpty)
                          ? NetworkImage(data['photoUrl'])
                          : null,
                  child:
                      (data['photoUrl'] == null ||
                              data['photoUrl'].toString().isEmpty)
                          ? const Icon(Icons.person, size: 40)
                          : null,
                ),

                const SizedBox(height: 12),

                
                Text(
                  data['name'] ?? "",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                
                Text(
                  data['department'] ?? "",
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.subtitleText,
                  ),
                ),

                const SizedBox(height: 22),

                
                _infoBox(
                  title: "Cabin Location",
                  value:
                      "${data['faculty'] ?? ''}, ${data['cabinLocation'] ?? ''}",
                ),

                const SizedBox(height: 12),

                // 📧 CONTACT
                _infoBox(
                  title: "Contact",
                  value: data['email'] ?? "Not available",
                ),

                const SizedBox(height: 22),

               
                SizedBox(
  width: double.infinity,
  height: 48,
  child: OutlinedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SlotBookingScreen(
            lecturerId: lecturerId, // ✅ pass lecturer id
          ),
        ),
      );
    },
    icon: const Icon(Icons.add, color: AppColors.black),
    label: const Text(
      "Book a Meeting",
      style: TextStyle(color: AppColors.black),
    ),
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      side: const BorderSide(color: AppColors.blue),
    ),
  ),
),

                const SizedBox(height: 14),

                
                Container(
                  width: double.infinity,
                  height: 99, 
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(statusIcon, color: AppColors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  
  Widget _infoBox({required String title, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.black, 
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.black, 
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}