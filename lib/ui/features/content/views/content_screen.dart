import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsetsDirectional.only(
                start: AppTheme.spaceSm, end: AppTheme.spaceSm,
                top: AppTheme.spaceMd,
              ),
              child: Text(
                'المحتوى الشرعي',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
              child: Text(
                'أذكار وأدعية لتكون عوناً لك في قضاء الصلوات',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppTheme.spaceXl),
            _ContentCard(
              tag: 'أدعية',
              title: 'دعاء قضاء الصلاة الفائتة',
              body:
                  'اللهم إني أسألك بعظمتك أن تغفر لي تقصيري في صلواتي، '
                  'وتقبل مني قضائها، واجعلها خالصة لوجهك الكريم.',
            ),
            const SizedBox(height: AppTheme.spaceMd),
            _ContentCard(
              tag: 'آيات وأحاديث',
              title: 'فضل المحافظة على الصلوات',
              body:
                  'قال الله تعالى: "إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا" '
                  '(النساء: ١٠٣). وحث النبي ﷺ على تعجيل قضاء الفوائت.',
            ),
            const SizedBox(height: AppTheme.spaceMd),
            _ContentCard(
              tag: 'نصائح',
              title: 'كيف تبدأ في قضاء صلواتك',
              body:
                  'ابدأ بالصلوات الخمس الحاضرة أولاً، ثم أضف صلاة واحدة '
                  'مقضية مع كل صلاة. تدريجياً ستلاحظ الفرق.',
            ),
            const SizedBox(height: AppTheme.spaceMd),
            _ContentCard(
              tag: 'أذكار',
              title: 'أذكار الصباح والمساء',
              body:
                  'اللهم بك أصبحنا وبك أمسينا، وبك نحيا وبك نموت وإليك المصير. '
                  'اللهم أنت ربي لا إله إلا أنت خلقتني وأنا عبدك.',
            ),
            const SizedBox(height: AppTheme.spaceXl),
          ],
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final String tag;
  final String title;
  final String body;

  const _ContentCard({
    required this.tag,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMd,
                vertical: AppTheme.spaceXs,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
                letterSpacing: -0.2,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              body,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.onSurfaceVariant,
                height: 1.6,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 6,
            ),
          ],
        ),
      ),
    );
  }
}
