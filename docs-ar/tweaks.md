<div dir="rtl">

# دليل التحسينات والميزات

هذه الصفحة يفتحها زر "(?)" بجانب كل خيار في Blazma Boost. لكل خيار: وش يسوي، ووش يغيّر في النظام بالضبط.

> هذا الملف يُنشأ تلقائياً بالأمر `.\tools\Build-ArabicGuide.ps1`، لا تعدله يدوياً.

## تخصيص التفضيلات

<a id="wpfmultiplaneoverlay"></a>

### Multiplane Overlay

ميزة تدمج عدة طبقات صورة وقد تسبب مشاكل مع بعض كروت الشاشة. التغيير يطبق فوراً.

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Microsoft\Windows\Dwm\OverlayTestMode` حسب الخيار المختار
- ريجستري: `HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\DisableOverlays` حسب الخيار المختار

<a id="wpftogglebatterypercentage"></a>

### نسبة البطارية في شريط المهام

يعرض نسبة البطارية بالأرقام بجانب أيقونتها.

**وش يغيّر:**

- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\IsBatteryPercentageEnabled`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)

<a id="wpftogglebingsearch"></a>

### بحث Bing في قائمة ابدأ

يظهر أو يخفي نتائج Bing في بحث ويندوز.

**وش يغيّر:**

- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Search\BingSearchEnabled`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)

<a id="wpftoggledarkmode"></a>

### الوضع الداكن لويندوز

الوضع الداكن للنظام والتطبيقات.

**وش يغيّر:**

- ريجستري: `HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize\AppsUseLightTheme`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize\SystemUsesLightTheme`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftoggledetailedbsod"></a>

### الشاشة الزرقاء المفصلة

يعرض معلومات أكثر عند ظهور الشاشة الزرقاء.

**وش يغيّر:**

- ريجستري: `HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl\DisplayParameters`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl\DisableEmoticon`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)

<a id="wpftoggledisablelockscreen"></a>

### شاشة القفل - تعطيل

يتخطى شاشة القفل ويروح مباشرة لشاشة تسجيل الدخول.

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization\NoLockScreen`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)

<a id="wpftogglehiddenfiles"></a>

### إظهار الملفات المخفية

يعرض الملفات المخفية في المستكشف.

**وش يغيّر:**

- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Hidden`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)
- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftogglehidesettingshome"></a>

### الصفحة الرئيسية في الإعدادات

يظهر أو يخفي الصفحة الرئيسية في تطبيق الإعدادات.

**وش يغيّر:**

- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\SettingsPageVisibility`: `show:home` (التراجع يرجع قيمتك السابقة، أو `hide:home` إذا ما كانت محفوظة)

<a id="wpftoggleloginblur"></a>

### ضبابية شاشة الدخول

يظهر أو يخفي تأثير الضبابية على خلفية شاشة الدخول.

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\DisableAcrylicBackgroundOnLogon`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)

<a id="wpftogglelongpaths"></a>

### المسارات الطويلة

يدعم مسارات الملفات الأطول من 260 حرفاً.

**وش يغيّر:**

- ريجستري: `HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)

<a id="wpftogglenewoutlook"></a>

### إصدار Outlook الجديد

يضمن استخدام تطبيق Outlook الجديد.

**وش يغيّر:**

- ريجستري: `HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences\UseNewOutlook`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General\HideNewOutlookToggle`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Policies\Microsoft\Office\16.0\Outlook\Options\General\DoNewOutlookAutoMigration`: `0` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Policies\Microsoft\Office\16.0\Outlook\Preferences\NewOutlookMigrationUserSetting`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)

<a id="wpftogglenumlock"></a>

### تفعيل Num Lock عند التشغيل

يتحكم بحالة زر Num Lock عند تشغيل الجهاز.

**وش يغيّر:**

- ريجستري: `HKU:\.Default\Control Panel\Keyboard\InitialKeyboardIndicators`: `2` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Control Panel\Keyboard\InitialKeyboardIndicators`: `2` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)

<a id="wpftoggles3sleep"></a>

### سكون S3

التبديل بين Modern Standby وسكون S3 الذي يفصل الطاقة عن المعالج مع إبقاء الذاكرة.

**وش يغيّر:**

- ريجستري: `HKLM:\SYSTEM\CurrentControlSet\Control\Power\PlatformAoAcOverride`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)

<a id="wpftogglescrollbars"></a>

### أشرطة التمرير ظاهرة دائماً

إذا فعلته تبقى أشرطة التمرير ظاهرة، وإذا عطلته يخفيها ويندوز عند عدم الاستخدام.

**وش يغيّر:**

- ريجستري: `HKCU:\Control Panel\Accessibility\DynamicScrollbars`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)

<a id="wpftoggleshowext"></a>

### إظهار امتدادات الملفات

يعرض امتدادات الملفات في المستكشف (.exe و.png وغيرها).

**وش يغيّر:**

- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideFileExt`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftogglestandbyfix"></a>

### اتصال الشبكة أثناء سكون S0

يتحكم باتصال الشبكة أثناء وضع السكون منخفض الطاقة في اللابتوبات الحديثة.

**وش يغيّر:**

- ريجستري: `HKCU:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9\ACSettingIndex`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)

<a id="wpftogglestartmenurecommendations"></a>

### اقتراحات قائمة ابدأ

يظهر أو يخفي قسم المقترحات في قائمة ابدأ. تحذير: يعطل أيضاً Windows Spotlight في شاشة القفل.

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start\HideRecommendedSection`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Education\IsEducationEnvironment`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer\HideRecommendedSection`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftogglestickykeys"></a>

### المفاتيح الثابتة

تتفعل عند الضغط على Shift عدة مرات بسرعة، ومزعجة جداً وقت اللعب.

**وش يغيّر:**

- ريجستري: `HKCU:\Control Panel\Accessibility\StickyKeys\Flags`: `506` (التراجع يرجع قيمتك السابقة، أو `58` إذا ما كانت محفوظة)

<a id="wpftoggletaskbaralignment"></a>

### توسيط أيقونات شريط المهام

محاذاة أيقونات شريط المهام في الوسط أو على الطرف.

**وش يغيّر:**

- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarAl`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)
- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftoggletaskbarsearch"></a>

### أيقونة البحث في شريط المهام

يظهر أو يخفي زر البحث في شريط المهام.

**وش يغيّر:**

- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Search\SearchboxTaskbarMode`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)

<a id="wpftoggletaskview"></a>

### أيقونة عرض المهام

يظهر أو يخفي زر عرض المهام في شريط المهام.

**وش يغيّر:**

- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ShowTaskViewButton`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)

<a id="wpftoggleverboselogon"></a>

### رسائل تسجيل الدخول المفصلة

يعرض رسائل مفصلة أثناء التشغيل والإيقاف.

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\VerboseStatus`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)

<a id="wpftogglewindowsnapping"></a>

### محاذاة النوافذ

يفعل أو يعطل التصاق النوافذ عند سحبها.

**وش يغيّر:**

- ريجستري: `HKCU:\Control Panel\Desktop\WindowArrangementActive`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)

## تحسينات أساسية

<a id="wpftweaksactivity"></a>

### سجل النشاط - تعطيل

يمنع ويندوز من نشر أو رفع سجل نشاطاتك مع الإبقاء على سجل الحافظة.

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\EnableActivityFeed`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\PublishUserActivities`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\UploadUserActivities`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)

<a id="wpftweaksconsumerfeatures"></a>

### ميزات المستهلك - تعطيل

يمنع تثبيت التطبيقات المروجة ويقلل اقتراحات متجر مايكروسوفت.

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent\DisableWindowsConsumerFeatures`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)

<a id="wpftweaksdeletetempfiles"></a>

### الملفات المؤقتة - حذف

يمسح مجلدات TEMP.

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpftweaksdeliveryoptimization"></a>

### تحسين التوصيل - تعطيل

يمنع ويندوز من استخدام الإنترنت عندك لرفع التحديثات لأجهزة أخرى.

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization\DODownloadMode`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)

<a id="wpftweaksdisablebitlocker"></a>

### BitLocker - تعطيل

يعطل تشفير BitLocker.

**وش يغيّر:**

- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftweaksdisableexplorerautodiscovery"></a>

### اكتشاف نوع المجلد تلقائياً - تعطيل

المستكشف يحاول تخمين نوع كل مجلد من محتواه مما يبطئ التصفح. تحذير: سيعطل تجميع الملفات في المستكشف.

**وش يغيّر:**

- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftweaksdisablestoresearch"></a>

### اقتراحات متجر مايكروسوفت في البحث - تعطيل

لن تظهر تطبيقات المتجر المقترحة عند البحث في قائمة ابدأ.

**وش يغيّر:**

- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftweaksdiskcleanup"></a>

### تنظيف القرص - تشغيل

يشغل تنظيف القرص على C: ويحذف تحديثات ويندوز القديمة.

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpftweaksendtaskontaskbar"></a>

### إنهاء المهمة بالزر الأيمن - تفعيل

يضيف خيار إنهاء المهمة عند الضغط بالزر الأيمن على برنامج في شريط المهام.

**وش يغيّر:**

- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings\TaskbarEndTask`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)

<a id="wpftweakshiber"></a>

### السبات - تعطيل

السبات مخصص للابتوب لأنه يحفظ محتوى الذاكرة قبل إطفاء الجهاز، ولا يحتاجه أغلب المستخدمين.

**وش يغيّر:**

- ريجستري: `HKLM:\System\CurrentControlSet\Control\Session Manager\Power\HibernateEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings\ShowHibernateOption`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftweakslocation"></a>

### تتبع الموقع - تعطيل

يعطل تتبع الموقع الجغرافي.

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location\Value`: `Deny` (التراجع يرجع قيمتك السابقة، أو `Allow` إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}\SensorPermissionState`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SYSTEM\Maps\AutoUpdateEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- خدمة: `lfsvc` تصير `Disabled` (الأصل `Manual`)

<a id="wpftweakspreventdevicemetadatafromnetwork"></a>

### منع تطبيقات الأجهزة المرافقة

يمنع تثبيت برامج إضافية عند توصيل الأجهزة (مثل الإعلانات عند توصيل شاشة).

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata\PreventDeviceMetadataFromNetwork`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)

<a id="wpftweaksrestorepoint"></a>

### نقطة استعادة - إنشاء

ينشئ نقطة استعادة قبل التعديلات حتى تقدر ترجع لها لو احتجت.

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore\SystemRestorePointCreationFrequency`: `0` (التراجع يرجع قيمتك السابقة، أو `1440` إذا ما كانت محفوظة)
- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpftweaksrevertstartmenu"></a>

### قائمة ابدأ القديمة - تفعيل

يرجع شكل قائمة ابدأ القديم من قبل تحديث 25H2. لا يعمل في إصدارات ويندوز الأحدث!

**وش يغيّر:**

- ريجستري: `HKLM:\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\3036241548\EnabledState`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)

<a id="wpftweaksservices"></a>

### الخدمات - جعلها يدوية

يجعل بعض الخدمات تعمل يدوياً ويضبط قيمة SvcHostSplitThresholdInKB حسب الذاكرة، مما يقلل عدد عمليات svchost.exe بشكل ملحوظ.

**وش يغيّر:**

- خدمة: `CscService` تصير `Disabled` (الأصل `Manual`)
- خدمة: `DiagTrack` تصير `Disabled` (الأصل `Automatic`)
- خدمة: `MapsBroker` تصير `Manual` (الأصل `Automatic`)
- خدمة: `StorSvc` تصير `Manual` (الأصل `Automatic`)
- خدمة: `SharedAccess` تصير `Disabled` (الأصل `Automatic`)
- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpftweakstelemetry"></a>

### التتبع (Telemetry) - تعطيل

يعطل إرسال بيانات الاستخدام إلى مايكروسوفت.

**وش يغيّر:**

- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo\Enabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy\TailoredExperiencesWithDiagnosticDataEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy\HasAccepted`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Input\TIPC\Enabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\InputPersonalization\RestrictImplicitInkCollection`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\InputPersonalization\RestrictImplicitTextCollection`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore\HarvestContacts`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Personalization\Settings\AcceptedPrivacyPolicy`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection\AllowTelemetry`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_TrackProgs`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\PublishUserActivities`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Siuf\Rules\NumberOfSIUFInPeriod`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftweakswidget"></a>

### الأدوات المصغرة (Widgets) - إزالة

يزيل الأدوات المصغرة المزعجة من أسفل يسار شريط المهام.

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpftweakswpbt"></a>

### جدول WPBT - تعطيل

يمنع الشركة المصنعة من تشغيل وتثبيت برامج عند الإقلاع بدون موافقتك. قد يشكل خطراً أمنياً.

**وش يغيّر:**

- ريجستري: `HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\DisableWpbtExecution`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)

## تحسينات الألعاب

<a id="wpfchangedns"></a>

### تغيير DNS إلى (Fastest يختار الأسرع لك):

<a id="wpftogglegamemode"></a>

### وضع الألعاب (Game Mode)

يجعل ويندوز يعطي الأولوية للألعاب في موارد الجهاز.

**وش يغيّر:**

- ريجستري: `HKCU:\Software\Microsoft\GameBar\AllowAutoGameMode`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\GameBar\AutoGameModeEnabled`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)

<a id="wpftogglemouseacceleration"></a>

### تسارع الماوس

يجعل حركة المؤشر تتأثر بسرعة تحريكك للماوس. أغلب لاعبي ألعاب التصويب يفضلون تعطيله.

**وش يغيّر:**

- ريجستري: `HKCU:\Control Panel\Mouse\MouseSpeed`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Control Panel\Mouse\MouseThreshold1`: `6` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Control Panel\Mouse\MouseThreshold2`: `10` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)

<a id="wpftweaksgaminggamedvr"></a>

### التسجيل في الخلفية (Game DVR) - تعطيل

يوقف تسجيل Xbox Game Bar للعب في الخلفية، والذي يستهلك من الفريمات ويكتب على القرص أثناء اللعب.

**وش يغيّر:**

- ريجستري: `HKCU:\System\GameConfigStore\GameDVR_Enabled`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR\AppCaptureEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR\AllowGameDVR`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)

<a id="wpftweaksgaminggamespriority"></a>

### أولوية الألعاب - عالية

يرفع أولوية المعالج والقرص التي يعطيها ويندوز للألعاب.

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games\Priority`: `6` (التراجع يرجع قيمتك السابقة، أو `2` إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games\Scheduling Category`: `High` (التراجع يرجع قيمتك السابقة، أو `Medium` إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games\SFIO Priority`: `High` (التراجع يرجع قيمتك السابقة، أو `Normal` إذا ما كانت محفوظة)

<a id="wpftweaksgaminghags"></a>

### جدولة كرت الشاشة بالعتاد (HAGS) - تفعيل

يخلي كرت الشاشة يدير جدولة ذاكرته بنفسه، وقد يقلل تأخير الاستجابة في الكروت المدعومة. يحتاج إعادة تشغيل.

**وش يغيّر:**

- ريجستري: `HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\HwSchMode`: `2` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)

<a id="wpftweaksgamingnetworkthrottling"></a>

### تقييد الشبكة - تعطيل

يلغي تقييد ويندوز للشبكة أثناء تشغيل الوسائط ويقلل الوقت المحجوز لمهام الخلفية، مما قد يخفف ارتفاعات البنق في الألعاب الأونلاين.

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\NetworkThrottlingIndex`: `-1` (التراجع يرجع قيمتك السابقة، أو `10` إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\SystemResponsiveness`: `10` (التراجع يرجع قيمتك السابقة، أو `20` إذا ما كانت محفوظة)

<a id="wpftweaksgamingpowerthrottling"></a>

### تقييد الطاقة - تعطيل

يمنع ويندوز من إبطاء العمليات في الخلفية لتوفير الطاقة، فتبقى المنصات والدردشة الصوتية والأوفرلاي بكامل سرعتها. لا ينصح به للابتوب على البطارية.

**وش يغيّر:**

- ريجستري: `HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling\PowerThrottlingOff`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)

<a id="wpftweaksgamingshadercache"></a>

### كاش الشيدرز - مسح

يحذف كاش الشيدرز الخاص بـ DirectX وNVIDIA وAMD. الألعاب تعيد بناءه عند التشغيل التالي، وهذا قد يحل التقطيع بعد تحديث التعريف ويوفر مساحة.

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

## خطط الطاقة - ليست للابتوب

<a id="wpfaddultperf"></a>

### خطة الأداء الأقصى - تفعيل

<a id="wpfremoveultperf"></a>

### خطة الأداء الأقصى - تعطيل

## تحسينات متقدمة - انتبه

<a id="wpfoosubutton"></a>

### تشغيل O&O ShutUp10++

<a id="wpftweaksblockadobenet"></a>

### حظر خوادم Adobe - تفعيل

يقلل الإزعاج بحظر اتصالات Adobe بخوادم التفعيل والتتبع. بفضل: Ruddernation-Designs

**وش يغيّر:**

- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftweaksbravedebloat"></a>

### متصفح Brave - تنظيف

يعطل الإضافات المزعجة مثل Brave Rewards وLeo AI ومحفظة العملات الرقمية وVPN.

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\BraveRewardsDisabled`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\BraveWalletDisabled`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\BraveVPNDisabled`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\BraveAIChatEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\BraveStatsPingEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\BraveNewsDisabled`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\BraveTalkDisabled`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\TorDisabled`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\BraveP3AEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\UrlKeyedAnonymizedDataCollectionEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\SafeBrowsingExtendedReportingEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\MetricsReportingEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)

<a id="wpftweaksdisablebgapps"></a>

### تطبيقات الخلفية - تعطيل

يمنع كل تطبيقات متجر مايكروسوفت من العمل في الخلفية.

**وش يغيّر:**

- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\GlobalUserDisabled`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)

<a id="wpftweaksdisableipv6"></a>

### IPv6 - تعطيل

يعطل IPv6.

**وش يغيّر:**

- ريجستري: `HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\DisabledComponents`: `255` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)
- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftweaksdisablenotifications"></a>

### الإشعارات والتقويم - تعطيل

يعطل كل الإشعارات بما فيها التقويم.

**وش يغيّر:**

- ريجستري: `HKCU:\Software\Policies\Microsoft\Windows\Explorer\DisableNotificationCenter`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications\ToastEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)

<a id="wpftweaksdisablewarningforunsignedrdp"></a>

### تحذيرات ملفات RDP غير الموقعة - تعطيل

يعطل التحذيرات التي تظهر عند فتح ملفات RDP غير الموقعة في آخر تحديثات ويندوز 10 و11.

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client\RedirectionWarningDialogVersion`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKCU:\SOFTWARE\Microsoft\Terminal Server Client\RdpLaunchConsentAccepted`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)

<a id="wpftweaksdisplay"></a>

### المؤثرات المرئية - أفضل أداء

يضبط إعدادات النظام على الأداء بدل الشكل. تقدر تسويها يدوياً من sysdm.cpl.

**وش يغيّر:**

- ريجستري: `HKCU:\Control Panel\Desktop\DragFullWindows`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Control Panel\Desktop\MenuShowDelay`: `200` (التراجع يرجع قيمتك السابقة، أو `400` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Control Panel\Desktop\WindowMetrics\MinAnimate`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Control Panel\Keyboard\KeyboardDelay`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ListviewAlphaSelect`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ListviewShadow`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarAnimations`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\VisualFXSetting`: `3` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Windows\DWM\EnableAeroPeek`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarMn`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ShowTaskViewButton`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Search\SearchboxTaskbarMode`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftweaksedgedebloat"></a>

### متصفح Edge - تنظيف

يعطل خيارات التتبع والنوافذ المنبثقة والإزعاجات الأخرى في Edge.

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate\CreateDesktopShortcutDefault`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Edge\PersonalizationReportingEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallBlocklist\1`: `ofefcgjbeghpigppfmkologfjadafddi` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Edge\ShowRecommendationsEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Edge\HideFirstRunExperience`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Edge\UserFeedbackAllowed`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Edge\ConfigureDoNotTrack`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Edge\AlternateErrorPagesEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Edge\EdgeCollectionsEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Edge\EdgeShoppingAssistantEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Edge\MicrosoftEdgeInsiderPromotionEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Edge\ShowMicrosoftRewards`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Edge\WebWidgetAllowed`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Edge\DiagnosticData`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Edge\EdgeAssetDeliveryServiceEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Edge\WalletDonationEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\Microsoft\Edge\DefaultBrowserSettingsCampaignEnabled`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)

<a id="wpftweaksipv46"></a>

### IPv6 - تفضيل IPv4

تفضيل IPv4 قد يحسن الاستجابة والأمان في الشبكات المنزلية التي لا تستخدم IPv6.

**وش يغيّر:**

- ريجستري: `HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\DisabledComponents`: `32` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)

<a id="wpftweakslogiblock"></a>

### التثبيت التلقائي لمساعد Logitech - تعطيل

يمنع Logi Download Assistant الذي يعيد تحديث ويندوز تثبيته. أجهزة Logitech تشتغل بدونه.

**وش يغيّر:**

- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftweaksrazerblock"></a>

### التثبيت التلقائي لبرامج Razer - تعطيل

يمنع تثبيت كل برامج Razer. الأجهزة تشتغل عادي بدونها.

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching\SearchOrderConfig`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer\DisableCoInstallers`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)
- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftweaksremoveedge"></a>

### متصفح Edge - إزالة

يحذف متصفح Edge من النظام باستخدام أداة الإزالة الرسمية بعد فتحها.

**وش يغيّر:**

- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftweaksremovehomeandgallery"></a>

### الرئيسية والمعرض في المستكشف - تعطيل

يحذف الرئيسية والمعرض من مستكشف الملفات ويجعل "هذا الكمبيوتر" هو الافتراضي.

**وش يغيّر:**

- ريجستري: `HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}\System.IsPinnedToNameSpaceTree`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}\System.IsPinnedToNameSpaceTree`: `0` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\LaunchTo`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)

<a id="wpftweaksremoveonedrive"></a>

### OneDrive - إزالة

يزيل OneDrive باستخدام أداة الإزالة الخاصة به مع حماية ملفاتك من الحذف.

**وش يغيّر:**

- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftweaksreservedstorage"></a>

### التخزين المحجوز - تعطيل

يعطل المساحة المحجوزة للتحديثات (7-10 جيجا). مفيد للأقراص الصغيرة فقط، وأعد تفعيله قبل تحديثات ويندوز الكبيرة.

**وش يغيّر:**

- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftweaksrightclickmenu"></a>

### قائمة الزر الأيمن القديمة - تفعيل

يرجع قائمة الزر الأيمن الكلاسيكية في مستكشف الملفات بدل قائمة ويندوز 11 المختصرة.

**وش يغيّر:**

- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftweaksstorage"></a>

### مستشعر التخزين - تعطيل

مستشعر التخزين يحذف الملفات المؤقتة تلقائياً.

**وش يغيّر:**

- ريجستري: `HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\01`: `0` (التراجع يرجع قيمتك السابقة، أو `1` إذا ما كانت محفوظة)

<a id="wpftweaksteredo"></a>

### Teredo - تعطيل

Teredo ميزة نفق لـ IPv6 قد تزيد التأخير، لكن تعطيلها قد يسبب مشاكل في بعض الألعاب.

**وش يغيّر:**

- ريجستري: `HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\DisabledComponents`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)
- يشغّل سكربت PowerShell وله سكربت تراجع

<a id="wpftweaksutc"></a>

### الوقت - ضبطه على UTC

ضروري للأجهزة التي عليها ويندوز ولينكس معاً، يصلح اختلاف الوقت بينهما.

**وش يغيّر:**

- ريجستري: `HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation\RealTimeIsUniversal`: `1` (التراجع يرجع قيمتك السابقة، أو `0` إذا ما كانت محفوظة)

<a id="wpftweakswindowsai"></a>

### ذكاء ويندوز الاصطناعي - تعطيل وإزالة

يزيل ويعطل كل ميزات وحزم الذكاء الاصطناعي.

**وش يغيّر:**

- ريجستري: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\SettingsPageVisibility`: `hide:aicomponents` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- ريجستري: `HKLM:\SOFTWARE\Policies\WindowsNotepad\DisableAIFeatures`: `1` (التراجع يرجع قيمتك السابقة، أو حذف القيمة إذا ما كانت محفوظة)
- يشغّل سكربت PowerShell وما له سكربت تراجع

## الميزات

<a id="wpffeaturedisablelegacyrecovery"></a>

### استرداد F8 القديم - تعطيل

يعطل شاشة خيارات الإقلاع المتقدمة.

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpffeatureenablelegacyrecovery"></a>

### استرداد F8 القديم - تفعيل

يفعل شاشة خيارات الإقلاع المتقدمة لتشغيل ويندوز في أوضاع إصلاح الأعطال.

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpffeatureinstall"></a>

### تثبيت الميزات

<a id="wpffeaturenfs"></a>

### نظام ملفات الشبكة (NFS) - تفعيل

آلية لتخزين الملفات والوصول لها عبر الشبكة.

**وش يغيّر:**

- ميزة ويندوز: `ServicesForNFS-ClientOnly`
- ميزة ويندوز: `ClientForNFS-Infrastructure`
- ميزة ويندوز: `NFS-Administration`
- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpffeatureregbackup"></a>

### نسخ احتياطي للريجستري (يومياً 12:30 ص) - تفعيل

يفعل النسخ الاحتياطي اليومي للريجستري الذي عطلته مايكروسوفت منذ ويندوز 10 إصدار 1803.

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpffeaturesdotnet"></a>

### .NET Framework (الإصدارات 2 و3 و4) - تفعيل

منصة مطورين تحتاجها كثير من البرامج والألعاب القديمة لتعمل.

**وش يغيّر:**

- ميزة ويندوز: `NetFx4-AdvSrvs`
- ميزة ويندوز: `NetFx3`

<a id="wpffeatureshyperv"></a>

### Hyper-V - تفعيل

تقنية المحاكاة من مايكروسوفت لإنشاء وإدارة الأجهزة الافتراضية.

**وش يغيّر:**

- ميزة ويندوز: `Microsoft-Hyper-V-All`

<a id="wpffeatureslegacymedia"></a>

### مكونات الوسائط القديمة (WMP وDirectPlay) - تفعيل

يفعل مكونات قديمة تحتاجها بعض الألعاب والبرامج القديمة.

**وش يغيّر:**

- ميزة ويندوز: `WindowsMediaPlayer`
- ميزة ويندوز: `MediaPlayback`
- ميزة ويندوز: `DirectPlay`
- ميزة ويندوز: `LegacyComponents`

<a id="wpffeaturessandbox"></a>

### Windows Sandbox - تفعيل

جهاز افتراضي خفيف لتجربة البرامج بأمان وبشكل معزول ومؤقت.

**وش يغيّر:**

- ميزة ويندوز: `Containers-DisposableClientVM`

<a id="wpffeaturewsl"></a>

### نظام لينكس الفرعي (WSL) - تفعيل

يسمح بتشغيل برامج لينكس على ويندوز مباشرة بدون جهاز افتراضي.

**وش يغيّر:**

- ميزة ويندوز: `VirtualMachinePlatform`
- ميزة ويندوز: `Microsoft-Windows-Subsystem-Linux`

## الإصلاحات

<a id="wpffixesnetwork"></a>

### الشبكة - إعادة ضبط

<a id="wpffixesntppool"></a>

### خادم الوقت NTP - تفعيل

يستبدل خادم الوقت الافتراضي (time.windows.com) بـ pool.ntp.org لمزامنة وقت أدق.

<a id="wpffixesupdate"></a>

### تحديثات ويندوز - إعادة ضبط

<a id="wpffixeswinget"></a>

### WinGet - إعادة تثبيت

<a id="wpfpanelautologin"></a>

### الدخول التلقائي - تشغيل

<a id="wpfpaneldism"></a>

### فحص تلف النظام - تشغيل

## لوحات ويندوز الكلاسيكية

<a id="wpfpanelcomputer"></a>

### إدارة الكمبيوتر

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpfpanelcontrol"></a>

### لوحة التحكم

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpfpanelfirewall"></a>

### جدار حماية ويندوز

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpfpanelmouse"></a>

### خصائص الماوس

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpfpanelnetwork"></a>

### اتصالات الشبكة

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpfpanelpower"></a>

### خيارات الطاقة

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpfpanelprinter"></a>

### الطابعات

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpfpanelprograms"></a>

### البرامج والميزات

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpfpanelregion"></a>

### المنطقة

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpfpanelrestore"></a>

### استعادة النظام

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpfpanelsecurity"></a>

### الأمان والصيانة

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpfpanelsound"></a>

### إعدادات الصوت

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpfpanelsystem"></a>

### خصائص النظام

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

<a id="wpfpaneltimedate"></a>

### التاريخ والوقت

**وش يغيّر:**

- يشغّل سكربت PowerShell وما له سكربت تراجع

## ملف تعريف PowerShell (لإصدار 7 فأعلى)

<a id="wpfwinutilinstallpsprofile"></a>

### ملف PowerShell من CTT - تثبيت

<a id="wpfwinutiluninstallpsprofile"></a>

### ملف PowerShell من CTT - إزالة

## الوصول عن بعد

<a id="wpfwinutilsshserver"></a>

### خادم OpenSSH - تفعيل

</div>
