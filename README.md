<div dir="rtl">

<p align="center">
  <img src="branding/logo.svg" width="130" alt="شعار Blazma Boost">
</p>

<h1 align="center">Blazma Boost ⚡</h1>

<p align="center">
  أداة ويندوز عربية مخصصة للقيمرز: تثبيت البرامج، تحسين الأداء، وإعدادات الألعاب من واجهة وحدة.
</p>

<p align="center">
  <a href="https://github.com/mr-kateba/Blazma-Boost/releases/latest"><img src="https://img.shields.io/github/v/release/mr-kateba/Blazma-Boost?label=%D8%A7%D9%84%D8%A5%D8%B5%D8%AF%D8%A7%D8%B1&color=FF6D00" alt="الإصدار"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/mr-kateba/Blazma-Boost?label=%D8%A7%D9%84%D8%AA%D8%B1%D8%AE%D9%8A%D8%B5" alt="الترخيص"></a>
</p>

---

## ✨ المميزات

- 🇸🇦 **واجهة عربية بالكامل** مع اتجاه من اليمين لليسار
- 🎮 **تبويب مخصص للألعاب** فيه تحسينات مثل تعطيل التسجيل في الخلفية وتفعيل جدولة كرت الشاشة وتقليل البنق
- 📦 **تثبيت أكثر من 200 برنامج بضغطة** عن طريق WinGet أو Chocolatey، منها Steam وDiscord وValorant وOpera GX
- ⚙️ **تحسينات ويندوز** مع إمكانية التراجع عن أي تحسين
- 🔄 **إدارة تحديثات ويندوز** وإصلاح مشاكل النظام الشائعة

## 🚀 طريقة التشغيل

1. افتح **PowerShell كمسؤول**: كليك يمين على زر ابدأ واختر **Terminal (Admin)**
2. الصق الأمر التالي واضغط Enter:

```powershell
irm https://github.com/mr-kateba/Blazma-Boost/releases/latest/download/winutil.ps1 | iex
```

### تطبيق تحسينات الألعاب مباشرة بدون واجهة

```powershell
& ([ScriptBlock]::Create((irm https://github.com/mr-kateba/Blazma-Boost/releases/latest/download/winutil.ps1))) -Preset Gaming
```

| الإعداد | الوصف |
|---------|-------|
| `Gaming` | تحسينات الألعاب المقترحة |
| `GamerEssentials` | تثبيت Steam وDiscord وOBS وMSI Afterburner وDirectX وVisual C++ |
| `Standard` | إعدادات متوازنة لأغلب المستخدمين |
| `Minimal` | أقل قدر من التغييرات |
| `Advanced` | تحسينات عميقة للمستخدم المتقدم |

<a id="gaming"></a>

## 🎮 تبويب الألعاب

| التحسين | ماذا يفعل |
|---------|-----------|
| التسجيل في الخلفية (Game DVR) - تعطيل | يوقف تسجيل Xbox Game Bar في الخلفية |
| جدولة كرت الشاشة (HAGS) - تفعيل | قد يقلل تأخير الاستجابة (يحتاج إعادة تشغيل) |
| تقييد الشبكة - تعطيل | قد يخفف ارتفاعات البنق في الألعاب الأونلاين |
| أولوية الألعاب - عالية | يرفع أولوية المعالج والقرص للألعاب |
| تقييد الطاقة - تعطيل | يبقي البرامج في الخلفية بكامل سرعتها |
| كاش الشيدرز - مسح | قد يحل التقطيع بعد تحديث التعريف |
| تغيير DNS | مع خيار `Fastest` اللي يقيس ويختار الأسرع لك |
| وضع الألعاب وتسارع الماوس | مفاتيح تشغيل وإيقاف سريعة |

وفي التبويب كمان:
- **معلومات جهازك:** المعالج وكرت الشاشة وإصدار تعريفه والرام والنظام، مع زر يفتح صفحة تحميل التعريف الرسمية لكرتك
- **وضع الألعاب بضغطة:** ينشئ نقطة استعادة ويطبق التحسينات المقترحة مباشرة
- **أساسيات القيمر:** يحدد لك البرامج الأساسية في تبويب التثبيت

كل تحسين يمكن التراجع عنه من زر **"التراجع عن المحدد"**، والتراجع يرجع القيمة اللي كانت عندك قبل التحسين.

البرنامج ينبهك بشريط برتقالي في الأعلى لما ينزل إصدار جديد.

## ⚠️ تنبيه

- الأداة تعدل إعدادات النظام. **أنشئ نقطة استعادة** قبل تطبيق أي تحسين (الخيار موجود في تبويب التحسينات).
- الاستخدام على مسؤوليتك الشخصية.

## 🛠️ للمطورين

```powershell
git clone https://github.com/mr-kateba/Blazma-Boost.git
cd Blazma-Boost
.\Compile.ps1 -Run
```

| الملف | المحتوى |
|-------|---------|
| `xaml/inputXML.xaml` | تصميم الواجهة ونصوصها العربية |
| `config/translations.json` | ترجمة التحسينات والبرامج والفئات |
| `config/applications.json` | قائمة البرامج |
| `config/tweaks.json` | التحسينات، وتحسينات الألعاب فئتها `Gaming` |
| `config/preset.json` | الإعدادات الجاهزة مثل `Gaming` |

**التحديث من المشروع الأصلي:**

```powershell
git remote add upstream https://github.com/ChrisTitusTech/winutil.git   # مرة وحدة فقط
git fetch upstream
git merge upstream/main
```

الترجمات موجودة في ملف منفصل (`config/translations.json`) عشان تقل التعارضات عند التحديث. وإذا غيّر المشروع الأصلي اسم أي تحسين، الاختبار `pester/translations.Tests.ps1` ينبهك.

**نشر إصدار جديد:** من تبويب **Actions** شغّل **Release Blazma Boost**. هو يبني `winutil.ps1` وينشره كإصدار جديد.

## 🙏 شكر وتقدير

هذا المشروع مبني على [WinUtil](https://github.com/ChrisTitusTech/winutil) من تطوير **Chris Titus Tech** والمساهمين فيه. كل الشكر لهم.
هذا المشروع **غير تابع رسمياً** للمشروع الأصلي.

## 📄 الترخيص

مرخّص تحت رخصة MIT. راجع ملف [LICENSE](LICENSE).

</div>
