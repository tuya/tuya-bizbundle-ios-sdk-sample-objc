#import "DemoAIRecomConfigViewController.h"
#import <ThingModuleServices/ThingAIRecomModuleProtocol.h>
#import <ThingSmartBizCore/ThingSmartBizCore.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const DemoAIRecomConfigurationDraftKey = @"DemoAIRecomConfiguration.v1";

static NSMutableDictionary *DemoAIRecomReadDraft(void) {
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:DemoAIRecomConfigurationDraftKey];
    // Keep drafts saved by the earlier demo page.
    if (!data) data = [[NSUserDefaults standardUserDefaults] dataForKey:@"DemoAIConversationConfiguration.v1"];
    id saved = data ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] : nil;
    NSMutableDictionary *draft = [saved isKindOfClass:NSDictionary.class] ? [saved mutableCopy] : [NSMutableDictionary dictionary];
    NSMutableDictionary *resources = [draft[@"resources"] isKindOfClass:NSDictionary.class] ? [draft[@"resources"] mutableCopy] : [NSMutableDictionary dictionary];
    // Preserve the former shared title image in both themes unless a theme already has an explicit value.
    for (NSString *key in @[@"chat_title_logo_light", @"chat_title_logo_dark"]) {
        if (!resources[key] && resources[@"chat_title_logo"]) resources[key] = resources[@"chat_title_logo"];
    }
    // Keep the unified logo; migrate a previous large-only selection when no logo was set.
    if (!resources[@"logo"]) resources[@"logo"] = resources[@"logo_large"] ?: resources[@"ai_assistant_icon_large"];
    [resources removeObjectForKey:@"logo_large"];
    [resources removeObjectForKey:@"ai_assistant_icon_large"];
    NSDictionary *legacy = @{@"logo": @"ai_assistant_icon_small", @"chat_title_logo_light": @"ai_assistant_logo_en_light", @"chat_title_logo_dark": @"ai_assistant_logo_en_dark", @"plus_badge_light": @"ai_assistant_plus_entry_light", @"plus_badge_dark": @"ai_assistant_plus_entry_dark", @"plus_star_badge": @"ai_assistant_plus_icon"};
    for (NSString *key in legacy) {
        if (!resources[key] && resources[legacy[key]]) resources[key] = resources[legacy[key]];
        [resources removeObjectForKey:legacy[key]];
    }
    [resources removeObjectForKey:@"chat_title_logo"];
    draft[@"resources"] = resources;
    return draft;
}

static NSDictionary *DemoAIRecomField(NSString *group, NSString *key, NSString *title, NSString *kind) {
    return @{@"group": group, @"key": key, @"title": title, @"kind": kind};
}

// Field help stays next to the title instead of occupying section footers.
static NSString *DemoAIRecomHelpText(NSString *key) {
    static NSDictionary<NSString *, NSString *> *notes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notes = @{
            @"welcome_content": @"Opening welcome animation language key. Blank uses the default; missing translations display the key. Tap Save configuration to apply.",
            @"input_placeholder": @"Input placeholder language key. Blank uses the default; missing translations display the key. Tap Save configuration to apply.",
            @"is_plus_open": @"Controls subscription entries in the conversation and settings pages. Defaults to enabled.",
            @"aibar": @"AIBar appears in device panels. Default: enabled, Append, no PID exceptions. Custom replaces the entire group.",
            @"is_support_aibar": @"Enables AIBar in device panels. Defaults to enabled; listed PID exceptions use the opposite value.",
            @"type": @"AIBar layout in device panels: Append or Float. Defaults to Append.",
            @"pid_blacklist": @"JSON array of nonempty product PIDs, e.g. [\"pid1\", \"pid2\"]. Listed PIDs invert the enable switch. Blank or [] means no exceptions.",
            @"logo": @"Shared assistant logo for all entries. Recommended @3x: 108x108. Tap to select the demo image; unchecked uses the default.",
            @"chat_title_logo_light": @"Centered conversation title logo in light mode. Use black artwork, recommended @3x: 285x60. Language-independent and scaled to fit; unchecked uses a placeholder.",
            @"chat_title_logo_dark": @"Centered conversation title logo in dark mode. Use white artwork, recommended @3x: 285x60. Language-independent and scaled to fit; unchecked uses a placeholder.",
            @"plus_badge_light": @"Top-right conversation subscription badge in light mode. Recommended @3x: 150x78. Tap to select the demo image; unchecked uses the default.",
            @"plus_badge_dark": @"Top-right conversation subscription badge in dark mode. Recommended @3x: 150x78. Tap to select the demo image; unchecked uses the default.",
            @"plus_star_badge": @"Membership badge on the settings page. Recommended @3x: 234x105. Tap to select the demo image; unchecked uses the default.",
            @"pid": @"Product PID for a device-panel entry, not a device ID. Leave blank for a general conversation.",
            @"content": @"Initial text prefilled in the input box, kept exactly as entered. Automatic sending is controlled by send.",
            @"send": @"Defaults to false. Automatically sends only when enabled and content contains nonblank text.",
            @"save_configuration": @"Saves and applies the settings and images above. Restored on app launch; newly opened views use them. Existing views are not refreshed.",
            @"open_page": @"Opens the conversation with the current pid, content and send. Does not save pending configuration changes.",
        };
    });
    NSString *note = notes[key];
    return note.length ? NSLocalizedString(note, nil) : nil;
}

static UIButton *DemoAIRecomHelpButton(NSString *key, dispatch_block_t action) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImageSymbolConfiguration *symbol = [UIImageSymbolConfiguration configurationWithPointSize:15 weight:UIImageSymbolWeightRegular];
    [button setImage:[UIImage systemImageNamed:@"questionmark.circle" withConfiguration:symbol] forState:UIControlStateNormal];
    button.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Help for %@", nil), key];
    button.accessibilityIdentifier = [@"ai_recom_help_" stringByAppendingString:key];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [button.widthAnchor constraintEqualToConstant:32],
        [button.heightAnchor constraintEqualToConstant:32],
    ]];
    [button bk_whenTapped:action];
    return button;
}

static UIStackView *DemoAIRecomHelpRow(NSString *text, UIFontTextStyle textStyle, UIColor *textColor, UIButton *helpButton) {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont preferredFontForTextStyle:textStyle];
    label.adjustsFontForContentSizeCategory = YES;
    label.textColor = textColor;
    label.numberOfLines = 1;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    [label setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    UIView *spacer = [[UIView alloc] init];
    [spacer setContentHuggingPriority:UILayoutPriorityDefaultLow - 1 forAxis:UILayoutConstraintAxisHorizontal];
    NSArray *views = helpButton ? @[label, helpButton, spacer] : @[label, spacer];
    UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:views];
    row.axis = UILayoutConstraintAxisHorizontal;
    row.alignment = UIStackViewAlignmentCenter;
    row.spacing = 2;
    return row;
}

static NSString *DemoAIRecomJSONString(id value) {
    NSData *data = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys error:nil];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"{}";
}

// One editor serves both plain text and JSON. Invalid JSON stays in the editor.
@interface DemoAIRecomConfigurationEditor : UIViewController
@property (nonatomic, copy) NSString *initialText;
@property (nonatomic, copy) NSString *hint;
@property (nonatomic, copy) NSString *fieldKey;
@property (nonatomic, assign) BOOL JSONMode;
@property (nonatomic, copy) NSString * _Nullable (^saveText)(NSString *text);
@property (nonatomic, strong) UITextView *textView;
@end

@implementation DemoAIRecomConfigurationEditor

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];

    __weak typeof(self) weakSelf = self;
    UIButton *helpButton = DemoAIRecomHelpButton(self.fieldKey, ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (self) [SVProgressHUD showInfoWithStatus:self.hint];
    });
    UIStackView *keyRow = DemoAIRecomHelpRow(self.fieldKey, UIFontTextStyleCaption1, UIColor.secondaryLabelColor, helpButton);
    keyRow.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:keyRow];

    self.textView = [[UITextView alloc] init];
    self.textView.text = self.initialText;
    self.textView.font = self.JSONMode ? [[UIFontMetrics metricsForTextStyle:UIFontTextStyleBody] scaledFontForFont:[UIFont monospacedSystemFontOfSize:17 weight:UIFontWeightRegular]] : [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.textView.adjustsFontForContentSizeCategory = YES;
    self.textView.textColor = UIColor.labelColor;
    self.textView.backgroundColor = UIColor.secondarySystemBackgroundColor;
    self.textView.layer.cornerRadius = 12;
    self.textView.textContainerInset = UIEdgeInsetsMake(12, 8, 12, 8);
    self.textView.accessibilityIdentifier = @"ai_recom_configuration_editor";
    if (self.JSONMode) {
        self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textView.smartQuotesType = UITextSmartQuotesTypeNo;
        self.textView.smartDashesType = UITextSmartDashesTypeNo;
        self.textView.spellCheckingType = UITextSpellCheckingTypeNo;
    }
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.textView];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [keyRow.topAnchor constraintEqualToAnchor:safe.topAnchor constant:12],
        [keyRow.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:20],
        [keyRow.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-20],
        [self.textView.topAnchor constraintEqualToAnchor:keyRow.bottomAnchor constant:8],
        [self.textView.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:16],
        [self.textView.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
        [self.textView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-16],
    ]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardChanged:(NSNotification *)notification {
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    frame = [self.view convertRect:frame fromView:nil];
    CGFloat overlap = CGRectGetHeight(CGRectIntersection(self.textView.frame, frame));
    UIEdgeInsets inset = UIEdgeInsetsMake(12, 8, MAX(12, overlap), 8);
    self.textView.contentInset = UIEdgeInsetsMake(0, 0, inset.bottom - 12, 0);
    self.textView.scrollIndicatorInsets = self.textView.contentInset;
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)save {
    NSString *errorMessage = self.saveText ? self.saveText(self.textView.text ?: @"") : nil;
    if (errorMessage.length > 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Invalid configuration", nil) message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

@interface DemoAIRecomConfigViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *configuration;
@property (nonatomic, copy) NSArray<NSArray<NSDictionary *> *> *sections;
@end

@implementation DemoAIRecomConfigViewController

+ (ThingAIRecomBizConfig *)configFromDraft:(NSDictionary *)draft {
    NSDictionary *startup = [draft[@"startup"] isKindOfClass:NSDictionary.class] ? draft[@"startup"] : @{};
    NSDictionary *values = startup[@"AIRecomConfig"];
    if (![values isKindOfClass:NSDictionary.class]) values = @{};
    ThingAIRecomBizConfig *config = [ThingAIRecomBizConfig new];
    config.welcome_content = [values[@"welcome_content"] isKindOfClass:NSString.class] ? values[@"welcome_content"] : nil;
    config.input_placeholder = [values[@"input_placeholder"] isKindOfClass:NSString.class] ? values[@"input_placeholder"] : nil;
    config.is_plus_open = [values[@"is_plus_open"] isKindOfClass:NSNumber.class] ? values[@"is_plus_open"] : nil;
    NSDictionary *bar = [values[@"aibar"] isKindOfClass:NSDictionary.class] ? values[@"aibar"] : nil;
    if (bar) {
        ThingAIRecomAIBarConfig *barConfig = [ThingAIRecomAIBarConfig new];
        if ([bar[@"is_support_aibar"] isKindOfClass:NSNumber.class]) barConfig.is_support_aibar = [bar[@"is_support_aibar"] boolValue];
        barConfig.type = [bar[@"type"] isEqual:@"float"] ? ThingAIRecomAIBarShowStyleFloat : ThingAIRecomAIBarShowStyleAppend;
        barConfig.pid_blacklist = [bar[@"pid_blacklist"] isKindOfClass:NSArray.class] ? bar[@"pid_blacklist"] : nil;
        config.aibar = barConfig;
    }
    NSDictionary *resources = [draft[@"resources"] isKindOfClass:NSDictionary.class] ? draft[@"resources"] : @{};
    for (NSString *key in @[@"logo", @"chat_title_logo_light", @"chat_title_logo_dark", @"plus_badge_light", @"plus_badge_dark", @"plus_star_badge"]) {
        NSString *name = [resources[key] isKindOfClass:NSString.class] ? resources[key] : nil;
        UIImage *image = name.length ? [UIImage imageNamed:name] : nil;
        if ([key isEqual:@"logo"]) config.logo = image;
        if ([key isEqual:@"chat_title_logo_light"]) config.chat_title_logo_light = image;
        if ([key isEqual:@"chat_title_logo_dark"]) config.chat_title_logo_dark = image;
        if ([key isEqual:@"plus_badge_light"]) config.plus_badge_light = image;
        if ([key isEqual:@"plus_badge_dark"]) config.plus_badge_dark = image;
        if ([key isEqual:@"plus_star_badge"]) config.plus_star_badge = image;
    }
    return config;
}

+ (BOOL)applyAIRecomConfigurationFromDraft:(NSDictionary *)draft {
    // 先完成业务包初始化和服务注册，再恢复配置；不能依赖用户先打开某个业务页面。
    id<ThingAIRecomModuleProtocol> service = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingAIRecomModuleProtocol)];
    if (![service respondsToSelector:@selector(configureAIRecomWithConfig:)]) {
        NSLog(@"[AIRecom Demo] Configuration not applied: AIRecom service is unavailable.");
        return NO;
    }
    [service configureAIRecomWithConfig:[self configFromDraft:draft]];
    return YES;
}

+ (void)applySavedAIRecomConfiguration {
    [self applyAIRecomConfigurationFromDraft:DemoAIRecomReadDraft()];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"AIRecom conversation configuration", nil);
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    [self loadDraft];
    // Each section is one card containing both its parameters and its action.
    self.sections = @[
        @[
            DemoAIRecomField(@"config", @"welcome_content", @"Opening welcome language key", @"text"),
            DemoAIRecomField(@"config", @"input_placeholder", @"Input placeholder language key", @"text"),
            DemoAIRecomField(@"config", @"is_plus_open", @"Plus entries", @"optionalBool"),
            DemoAIRecomField(@"config", @"aibar", @"AIBar configuration", @"override"),
            DemoAIRecomField(@"aibar", @"is_support_aibar", @"Enable AIBar", @"bool"),
            DemoAIRecomField(@"aibar", @"type", @"AIBar style", @"style"),
            DemoAIRecomField(@"aibar", @"pid_blacklist", @"PID exceptions", @"pids"),
            DemoAIRecomField(@"resources", @"logo", @"Assistant logo", @"image"),
            DemoAIRecomField(@"resources", @"chat_title_logo_light", @"Title logo (light)", @"image"),
            DemoAIRecomField(@"resources", @"chat_title_logo_dark", @"Title logo (dark)", @"image"),
            DemoAIRecomField(@"resources", @"plus_badge_light", @"Subscription entry badge (light)", @"image"),
            DemoAIRecomField(@"resources", @"plus_badge_dark", @"Subscription entry badge (dark)", @"image"),
            DemoAIRecomField(@"resources", @"plus_star_badge", @"Settings membership badge", @"image"),
            DemoAIRecomField(@"actions", @"save_configuration", @"Save configuration", @"save"),
        ],
        @[
            DemoAIRecomField(@"parameters", @"content", @"content", @"text"),
            DemoAIRecomField(@"parameters", @"send", @"Send immediately", @"send"),
            DemoAIRecomField(@"parameters", @"pid", @"pid", @"text"),
            DemoAIRecomField(@"actions", @"open_page", @"Open page", @"open"),
        ],
    ];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 76;
    self.tableView.sectionFooterHeight = 8;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor],
    ]];

}

- (UIButton *)actionButtonWithTitle:(NSString *)title identifier:(NSString *)identifier {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:NSLocalizedString(title, nil) forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.backgroundColor = self.view.tintColor;
    button.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    button.titleLabel.adjustsFontForContentSizeCategory = YES;
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.contentEdgeInsets = UIEdgeInsetsMake(14, 16, 14, 16);
    button.layer.cornerRadius = 12;
    button.accessibilityIdentifier = identifier;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    return button;
}

- (UIButton *)helpButtonForKey:(NSString *)key {
    NSString *note = DemoAIRecomHelpText(key);
    if (!note.length) return nil;
    __weak typeof(self) weakSelf = self;
    return DemoAIRecomHelpButton(key, ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (self) [SVProgressHUD showInfoWithStatus:note];
    });
}

- (UIStackView *)actionRowWithButton:(UIButton *)button helpKey:(NSString *)key {
    UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[button, [self helpButtonForKey:key]]];
    row.axis = UILayoutConstraintAxisHorizontal;
    row.alignment = UIStackViewAlignmentCenter;
    row.spacing = 4;
    return row;
}

- (void)addDetailsToCell:(UITableViewCell *)cell field:(NSDictionary *)field summary:(NSString *)summary enabled:(BOOL)enabled {
    UIColor *titleColor = enabled ? UIColor.labelColor : UIColor.secondaryLabelColor;
    UIStackView *titleRow = DemoAIRecomHelpRow(NSLocalizedString(field[@"title"], nil), UIFontTextStyleBody, titleColor, [self helpButtonForKey:field[@"key"]]);
    UILabel *title = (UILabel *)titleRow.arrangedSubviews.firstObject;
    title.accessibilityValue = cell.accessibilityValue;

    UILabel *key = [[UILabel alloc] init];
    key.text = field[@"key"];
    key.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    key.adjustsFontForContentSizeCategory = YES;
    key.textColor = UIColor.secondaryLabelColor;
    key.numberOfLines = 1;
    key.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [key setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [key setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh + 1 forAxis:UILayoutConstraintAxisHorizontal];

    // Place the accessory in the value line rather than centering it across the cell.
    UIView *accessory = cell.accessoryView;
    BOOL showsArrow = !accessory && cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    UIView *rightView;
    if (accessory) {
        accessory.translatesAutoresizingMaskIntoConstraints = NO;
        [accessory setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [accessory setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        if (![accessory isKindOfClass:UISwitch.class]) {
            [NSLayoutConstraint activateConstraints:@[
                [accessory.widthAnchor constraintEqualToConstant:CGRectGetWidth(accessory.bounds)],
                [accessory.heightAnchor constraintEqualToConstant:CGRectGetHeight(accessory.bounds)],
            ]];
        }
        rightView = accessory;
    } else {
        UILabel *value = [[UILabel alloc] init];
        value.text = summary;
        value.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        value.adjustsFontForContentSizeCategory = YES;
        value.textColor = UIColor.secondaryLabelColor;
        value.textAlignment = NSTextAlignmentRight;
        value.numberOfLines = 1;
        value.lineBreakMode = NSLineBreakByTruncatingTail;
        [value setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        UIStackView *valueRow = [[UIStackView alloc] initWithArrangedSubviews:@[value]];
        valueRow.axis = UILayoutConstraintAxisHorizontal;
        valueRow.alignment = UIStackViewAlignmentCenter;
        valueRow.spacing = 6;
        if (showsArrow) {
            UIImageSymbolConfiguration *symbol = [UIImageSymbolConfiguration configurationWithPointSize:11 weight:UIImageSymbolWeightSemibold];
            UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right" withConfiguration:symbol]];
            arrow.tintColor = UIColor.tertiaryLabelColor;
            [arrow setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
            [valueRow addArrangedSubview:arrow];
        }
        rightView = valueRow;
    }
    UIView *spacer = [[UIView alloc] init];
    [spacer setContentHuggingPriority:UILayoutPriorityDefaultLow - 1 forAxis:UILayoutConstraintAxisHorizontal];
    UIStackView *valueLine = [[UIStackView alloc] initWithArrangedSubviews:@[key, spacer, rightView]];
    valueLine.axis = UILayoutConstraintAxisHorizontal;
    valueLine.alignment = UIStackViewAlignmentCenter;
    valueLine.spacing = 8;

    UIStackView *details = [[UIStackView alloc] initWithArrangedSubviews:@[titleRow, valueLine]];
    details.axis = UILayoutConstraintAxisVertical;
    details.spacing = 2;
    details.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:details];
    UILayoutGuide *margins = cell.contentView.layoutMarginsGuide;
    [NSLayoutConstraint activateConstraints:@[
        [details.topAnchor constraintEqualToAnchor:margins.topAnchor],
        [details.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor],
        [details.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor],
        [details.bottomAnchor constraintEqualToAnchor:margins.bottomAnchor],
    ]];
    cell.isAccessibilityElement = NO;
}

- (void)loadDraft {
    self.configuration = DemoAIRecomReadDraft();
    for (NSString *group in @[@"startup", @"resources", @"localizations", @"parameters"]) {
        id value = self.configuration[group];
        self.configuration[group] = [value isKindOfClass:NSDictionary.class] ? [value mutableCopy] : [NSMutableDictionary dictionary];
    }
    if (![self.configuration[@"startup"][@"AIRecomConfig"] isKindOfClass:NSDictionary.class]) {
        self.configuration[@"startup"][@"AIRecomConfig"] = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary *config = [self.configuration[@"startup"][@"AIRecomConfig"] mutableCopy];
    if ([config[@"aibar"] isKindOfClass:NSDictionary.class]) config[@"aibar"] = [config[@"aibar"] mutableCopy];
    self.configuration[@"startup"][@"AIRecomConfig"] = config;
    NSMutableDictionary *parameters = self.configuration[@"parameters"];
    if (![parameters[@"send"] isKindOfClass:NSNumber.class]) parameters[@"send"] = @NO;

}

- (void)saveEntryParameters {
    // 仅记住入口参数，不能把尚未点击“保存配置”的业务草稿一起写入。
    NSMutableDictionary *saved = DemoAIRecomReadDraft();
    saved[@"parameters"] = self.configuration[@"parameters"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:saved options:0 error:nil];
    if (data) [[NSUserDefaults standardUserDefaults] setObject:data forKey:DemoAIRecomConfigurationDraftKey];
}

- (void)saveAIRecomConfiguration {
    NSMutableDictionary *saved = DemoAIRecomReadDraft();
    saved[@"startup"] = self.configuration[@"startup"];
    saved[@"resources"] = self.configuration[@"resources"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:saved options:0 error:nil];
    if (!data) {
        [self showConfigurationMessage:NSLocalizedString(@"The configuration could not be saved. Please try again.", nil)
                                title:NSLocalizedString(@"Unable to save configuration", nil)];
        return;
    }
    if (![self.class applyAIRecomConfigurationFromDraft:saved]) {
        [self showConfigurationMessage:NSLocalizedString(@"The AIRecom service is not available in this build.", nil)
                                title:NSLocalizedString(@"Unable to save configuration", nil)];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:DemoAIRecomConfigurationDraftKey];
    [self showConfigurationMessage:NSLocalizedString(@"Saved settings apply to newly opened conversations and device panels, and will be restored on the next app launch.", nil)
                            title:NSLocalizedString(@"Configuration saved", nil)];
}

- (void)showConfigurationMessage:(NSString *)message title:(NSString *)title {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSMutableDictionary *)groupForField:(NSDictionary *)field {
    NSMutableDictionary *config = self.configuration[@"startup"][@"AIRecomConfig"];
    if ([field[@"group"] isEqual:@"config"]) return config;
    if ([field[@"group"] isEqual:@"aibar"]) return config[@"aibar"];
    return self.configuration[field[@"group"]];
}

- (id)valueForField:(NSDictionary *)field {
    return [self groupForField:field][field[@"key"]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return self.sections.count; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return self.sections[section].count; }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *titles = @[@"Business configuration", @"Open page parameters"];
    return NSLocalizedString(titles[section], nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    NSDictionary *field = self.sections[indexPath.section][indexPath.row];
    NSString *kind = field[@"kind"];
    BOOL savesConfiguration = [kind isEqual:@"save"];
    if (savesConfiguration || [kind isEqual:@"open"]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *identifier = savesConfiguration ? @"save_ai_recom_configuration" : @"open_ai_recom_conversation";
        UIButton *button = [self actionButtonWithTitle:field[@"title"] identifier:identifier];
        __weak typeof(self) weakSelf = self;
        [button bk_whenTapped:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (savesConfiguration) [self saveAIRecomConfiguration];
            else [self openAIRecomConversation];
        }];
        UIStackView *actions = [self actionRowWithButton:button helpKey:field[@"key"]];
        actions.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:actions];
        [NSLayoutConstraint activateConstraints:@[
            [actions.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:12],
            [actions.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
            [actions.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
            [actions.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-16],
            [button.heightAnchor constraintGreaterThanOrEqualToConstant:50],
        ]];
        return cell;
    }
    id value = [self valueForField:field];
    cell.accessibilityIdentifier = [@"ai_recom_config_" stringByAppendingString:field[@"key"]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSString *summary = @"";
    if ([kind isEqual:@"image"]) {
        BOOL selected = [value isKindOfClass:NSString.class] && [value length] > 0;
        NSString *sampleName = [@"demo_airecom_" stringByAppendingString:field[@"key"]];
        UIImage *preview = [UIImage imageNamed:selected ? value : sampleName];
        UIView *accessory = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 104, 32)];
        UIImageView *previewView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 72, 32)];
        previewView.image = preview;
        previewView.contentMode = UIViewContentModeScaleAspectFit;
        previewView.backgroundColor = [field[@"key"] hasSuffix:@"_dark"] ? [UIColor colorWithWhite:0.12 alpha:1] : UIColor.whiteColor;
        previewView.layer.cornerRadius = 6;
        previewView.clipsToBounds = YES;
        [accessory addSubview:previewView];
        UIImageView *checkmark = [[UIImageView alloc] initWithFrame:CGRectMake(84, 6, 20, 20)];
        checkmark.image = [UIImage systemImageNamed:selected ? @"checkmark.square.fill" : @"square"];
        checkmark.tintColor = selected ? self.view.tintColor : UIColor.tertiaryLabelColor;
        [accessory addSubview:checkmark];
        cell.accessoryView = accessory;
        cell.accessibilityTraits = UIAccessibilityTraitButton | (selected ? UIAccessibilityTraitSelected : 0);
        cell.accessibilityValue = NSLocalizedString(selected ? @"Replacement image selected" : @"Default", nil);
        summary = @"";
    } else if ([kind isEqual:@"override"]) {
        summary = NSLocalizedString(value ? @"Custom (replace all)" : @"Default", nil);
    } else if ([kind isEqual:@"optionalBool"] || [kind isEqual:@"bool"]) {
        summary = NSLocalizedString(value ? ([value boolValue] ? @"Enabled" : @"Disabled") : ([kind isEqual:@"bool"] ? @"Enabled" : @"Default"), nil);
    } else if ([kind isEqual:@"style"]) {
        summary = NSLocalizedString([value isEqual:@"float"] ? @"Float" : @"Append", nil);
    } else if ([kind isEqual:@"pids"]) {
        summary = [value count] ? [value componentsJoinedByString:@", "] : NSLocalizedString(@"No PID exceptions", nil);
    } else if ([kind isEqualToString:@"send"]) {
        UISwitch *control = [[UISwitch alloc] init];
        control.on = [value boolValue];
        [control addTarget:self action:@selector(sendChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = control;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        summary = @"";
    } else {
        summary = [value isKindOfClass:NSString.class] && [value length] ? value : NSLocalizedString(@"Default", nil);
    }
    BOOL enabled = ![field[@"group"] isEqual:@"aibar"] || self.configuration[@"startup"][@"AIRecomConfig"][@"aibar"] != nil;
    if (!enabled) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (summary.length > 160) summary = [[summary substringToIndex:160] stringByAppendingString:@"…"];
    [self addDetailsToCell:cell field:field summary:summary enabled:enabled];
    return cell;
}

- (void)sendChanged:(UISwitch *)sender {
    self.configuration[@"parameters"][@"send"] = @(sender.isOn);
    [self saveEntryParameters];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *field = self.sections[indexPath.section][indexPath.row];
    NSString *kind = field[@"kind"];
    if ([@[@"send", @"save", @"open"] containsObject:kind]) return;
    if ([kind isEqual:@"image"]) {
        NSMutableDictionary *resources = self.configuration[@"resources"];
        NSString *key = field[@"key"];
        if ([resources[key] isKindOfClass:NSString.class] && [resources[key] length]) {
            [resources removeObjectForKey:key];
        } else {
            resources[key] = [@"demo_airecom_" stringByAppendingString:key];
        }
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    if ([field[@"group"] isEqual:@"aibar"] && !self.configuration[@"startup"][@"AIRecomConfig"][@"aibar"]) return;
    if ([@[@"override", @"optionalBool", @"bool", @"style"] containsObject:kind]) {
        [self selectValueForField:field atIndexPath:indexPath];
        return;
    }
    DemoAIRecomConfigurationEditor *editor = [[DemoAIRecomConfigurationEditor alloc] init];
    editor.title = NSLocalizedString(field[@"title"], nil);
    editor.JSONMode = [kind isEqualToString:@"pids"];
    id value = [self valueForField:field];
    editor.initialText = editor.JSONMode ? DemoAIRecomJSONString(value ?: @[]) : ([value isKindOfClass:NSString.class] ? value : @"");
    editor.fieldKey = field[@"key"];
    editor.hint = DemoAIRecomHelpText(field[@"key"]);
    __weak typeof(self) weakSelf = self;
    editor.saveText = ^NSString *(NSString *text) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return nil;
        return [self updateField:field text:text];
    };
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:editor];
    [self presentViewController:navigation animated:YES completion:nil];
}

- (void)selectValueForField:(NSDictionary *)field atIndexPath:(NSIndexPath *)indexPath {
    NSString *kind = field[@"kind"];
    NSArray *titles;
    NSArray *values;
    if ([kind isEqual:@"override"]) {
        titles = @[@"Default", @"Custom (replace all)"];
        values = @[NSNull.null, @{}];
    } else if ([kind isEqual:@"style"]) {
        titles = @[@"Append", @"Float"];
        values = @[@"append", @"float"];
    } else if ([kind isEqual:@"optionalBool"]) {
        titles = @[@"Default", @"Enabled", @"Disabled"];
        values = @[NSNull.null, @YES, @NO];
    } else {
        titles = @[@"Enabled", @"Disabled"];
        values = @[@YES, @NO];
    }
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(field[@"title"], nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        [sheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(title, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            NSMutableDictionary *group = [self groupForField:field];
            id value = values[idx];
            if (value == NSNull.null) {
                [group removeObjectForKey:field[@"key"]];
            } else if ([kind isEqual:@"override"]) {
                // Selecting Custom again must not erase the existing custom values.
                if (!group[field[@"key"]]) group[field[@"key"]] = [NSMutableDictionary dictionary];
            } else {
                group[field[@"key"]] = value;
            }
            [self.tableView reloadData];
        }]];
    }];
    [sheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    sheet.popoverPresentationController.sourceView = [self.tableView cellForRowAtIndexPath:indexPath];
    sheet.popoverPresentationController.sourceRect = sheet.popoverPresentationController.sourceView.bounds;
    [self presentViewController:sheet animated:YES completion:nil];
}

- (NSString *)updateField:(NSDictionary *)field text:(NSString *)text {
    NSMutableDictionary *group = [self groupForField:field];
    NSString *kind = field[@"kind"];
    NSString *trimmed = [text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if ([kind isEqualToString:@"pids"]) {
        id value = trimmed.length ? [NSJSONSerialization JSONObjectWithData:[text dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil] : @[];
        if (![value isKindOfClass:NSArray.class]) return NSLocalizedString(@"PID exceptions must be a JSON array of nonempty strings.", nil);
        for (id pid in value) {
            if (![pid isKindOfClass:NSString.class] || ![pid stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length) {
                return NSLocalizedString(@"PID exceptions must be a JSON array of nonempty strings.", nil);
            }
        }
        group[field[@"key"]] = value;
    } else {
        NSString *value = [field[@"key"] isEqualToString:@"content"] ? text : trimmed;
        if (value.length) group[field[@"key"]] = value;
        else [group removeObjectForKey:field[@"key"]];
    }
    if ([field[@"group"] isEqualToString:@"parameters"]) [self saveEntryParameters];
    [self.tableView reloadData];
    return nil;
}

- (void)openAIRecomConversation {
    id<ThingAIRecomModuleProtocol> service = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingAIRecomModuleProtocol)];
    if (![service respondsToSelector:@selector(gotoAIRecomPageWithOptions:)]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"AIRecom conversation unavailable", nil) message:NSLocalizedString(@"The AIRecom service is not available in this build.", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    NSDictionary *parameters = self.configuration[@"parameters"];
    ThingAIRecomPageOptions *options = [ThingAIRecomPageOptions new];
    options.pid = [parameters[@"pid"] isKindOfClass:NSString.class] ? parameters[@"pid"] : nil;
    options.content = [parameters[@"content"] isKindOfClass:NSString.class] ? parameters[@"content"] : nil;
    options.send = [parameters[@"send"] boolValue];
    [service gotoAIRecomPageWithOptions:options];
}

@end
