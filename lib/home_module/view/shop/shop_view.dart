import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/controller/shop/shop_controller.dart';
import 'package:lingolearn/home_module/models/shop/shop_model.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

final shopController = Get.put(ShopController());

class ShopView extends StatefulWidget {
  const ShopView({super.key});

  @override
  State<ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends State<ShopView> {
  @override
  void initState() {
    super.initState();
    shopController.getShopItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Expanded(
                child: shopController.obx(
                  (shop) {
                    final data = shop?.data;
                    if (data == null) return const _EmptyState();

                    return ListView(
                      children: [
                        if ((data.gems?.isNotEmpty ?? false))
                          _Section(
                            title: 'Gems',
                            subtitle: 'Boost progress with premium gems',
                            icon: Icons.diamond_outlined,
                            colorA: kPrimary,
                            colorB: kSecondary,
                            items: data.gems!,
                          ),
                        if ((data.hearts?.isNotEmpty ?? false))
                          _Section(
                            title: 'Hearts',
                            subtitle: 'Refill lives and keep learning',
                            icon: Icons.favorite_outline,
                            colorA: kAccent,
                            colorB: kPrimary,
                            items: data.hearts!,
                          ),
                        if ((data.subscription?.isNotEmpty ?? false))
                          _Section(
                            title: 'Membership',
                            subtitle: 'Unlock unlimited hearts & perks',
                            icon: Icons.star_border_rounded,
                            colorA: kSecondary,
                            colorB: kPrimary,
                            items: data.subscription!,
                          ),
                        if ((data.gems?.isEmpty ?? true) &&
                            (data.hearts?.isEmpty ?? true) &&
                            (data.subscription?.isEmpty ?? true))
                          const _EmptyState(),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                  onLoading: const Center(child: CircularProgressIndicator()),
                  onEmpty: const _EmptyState(),
                  onError: (err) => _ErrorState(
                    message: err ?? 'Something went wrong',
                    onRetry: shopController.getShopItems,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color colorA;
  final Color colorB;
  final List<Datas> items;

  const _Section({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colorA,
    required this.colorB,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = MediaQuery.of(context).size.width >= 720 ? 3 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
            title: title,
            subtitle: subtitle,
            icon: icon,
            colorA: colorA,
            colorB: colorB),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) =>
              _ProductCard(item: items[i], colorA: colorA, colorB: colorB),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color colorA;
  final Color colorB;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colorA,
    required this.colorB,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBadge(icon: icon, colorA: colorA, colorB: colorB),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: kOnSurface, fontWeight: FontWeight.w800)),
              Text(subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: kMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color colorA;
  final Color colorB;

  const _IconBadge(
      {required this.icon, required this.colorA, required this.colorB});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colorA, colorB]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Datas item;
  final Color colorA;
  final Color colorB;

  const _ProductCard(
      {required this.item, required this.colorA, required this.colorB});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String title = item.title?.toString() ?? '';
    final String desc = item.description?.toString() ?? '';
    final int pricePaise =
        (item.priceInr is num) ? (item.priceInr as num).toInt() : 0;

    return Container(
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title + optional description
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: kOnSurface, fontWeight: FontWeight.w700),
          ),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: kMuted)),
          ],
          const Spacer(),
          Row(
            children: [
              Text(
                _inr(pricePaise),
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: kOnSurface, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              _BuyButton(
                label: 'Buy',
                colorA: colorA,
                colorB: colorB,
                onTap: () async {
                  // final iap = Get.put(IAPService());
                  // await iap.purchase(item);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BuyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color colorA;
  final Color colorB;

  const _BuyButton(
      {required this.label,
      required this.onTap,
      required this.colorA,
      required this.colorB});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [colorA, colorB]),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          label,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: infoBackground,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('Nothing to show'),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: errorBackground,
          border: Border.all(color: errorBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: errorMain),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: onSurface)),
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              backgroundColor: errorMain,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ]),
      ),
    );
  }
}

// ---------- tiny helpers ----------
String _inr(int paise) => '₹${(paise / 100).toStringAsFixed(2)}';
