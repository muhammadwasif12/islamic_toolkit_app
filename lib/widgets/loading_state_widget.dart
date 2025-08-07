import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(62, 180, 137, 1),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Date and Location Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Shimmer.fromColors(
                baseColor: Colors.white.withOpacity(0.4),
                highlightColor: Colors.white.withOpacity(0.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 180,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Time (04:41) Placeholder
            Center(
              child: Shimmer.fromColors(
                baseColor: Colors.white.withOpacity(0.4),
                highlightColor: Colors.white.withOpacity(0.8),
                child: Container(
                  width: 120,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Countdown Placeholder
            Center(
              child: Shimmer.fromColors(
                baseColor: Colors.white.withOpacity(0.3),
                highlightColor: Colors.white.withOpacity(0.6),
                child: Container(
                  width: 160,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Horizontal Prayer Times
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.white.withOpacity(0.4),
                      highlightColor: Colors.white.withOpacity(0.8),
                      child: Container(
                        width: 80,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Zikr Card Placeholder (Bottom White Box)
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 0),
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(6, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Container(
                            height: 12,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      ...List.generate(4, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Container(
                            height: 12,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
