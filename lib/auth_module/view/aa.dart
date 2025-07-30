// class _UnitHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final String title;
//   final String description;
//   final bool isActive;
//   final Color unitColor;
//
//   _UnitHeaderDelegate({
//     required this.title,
//     required this.description,
//     required this.isActive,
//     required this.unitColor,
//   });
//
//   @override
//   double get maxExtent => 100.0;
//
//   @override
//   double get minExtent => 100.0;
//
//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       margin: const EdgeInsets.all(12),
//       alignment: Alignment.centerLeft,
//       decoration: AppBoxDecoration.getBoxDecoration(
//         color: unitColor,
//         borderRadius: 16,
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Icon(
//               isActive ? Icons.play_arrow : Icons.lock,
//               color: Colors.white,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold)),
//                 Text(description,
//                     style: TextStyle(
//                         color: Colors.white.withOpacity(0.8), fontSize: 14)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   bool shouldRebuild(covariant _UnitHeaderDelegate oldDelegate) {
//     return title != oldDelegate.title ||
//         description != oldDelegate.description ||
//         isActive != oldDelegate.isActive ||
//         unitColor != oldDelegate.unitColor;
//   }
// }
