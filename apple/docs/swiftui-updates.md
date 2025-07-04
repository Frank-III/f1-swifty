<!--
Downloaded via https://llm.codes by @steipete on July 3, 2025 at 09:31 AM
Source URL: https://developer.apple.com/documentation/updates/swiftui
Total pages processed: 157
URLs filtered: Yes
Content de-duplicated: Yes
Availability strings filtered: Yes
Code blocks only: No
-->

# https://developer.apple.com/documentation/updates/swiftui

- Updates
- SwiftUI updates

Article

# SwiftUI updates

Learn about important changes to SwiftUI.

## Overview

Browse notable changes in SwiftUI.

## June 2025

### General

- Apply Liquid Glass effects to views using `glassEffect(_:in:isEnabled:)`.

- Use `glass` with the `buttonStyle(_:)` modifier to apply Liquid Glass to instances of `Button`.

- `ToolbarSpacer` creates a visual break between items in toolbars containing Liquid Glass.

- Use `scrollEdgeEffectStyle(_:for:)` to configure the scroll edge effect style for scroll views.

- `backgroundExtensionEffect()` duplicates, mirrors, and blurs views placed around edges with available safe areas.

- Set behavior for tab bar minimization with `tabBarMinimizeBehavior(_:)`.

- Set the `search` role on a tab to take someone to a search tab and have a search field take the place of the tab bar.

- Adjust the content of accessory views based on the placement in a tab view with `TabViewBottomAccessoryPlacement`.

- Connect a `WebView` with a `WebPage` to fully control the browsing experience in your app.

- Drag multiple items using the `draggable(_:_:)` modifier. Make a view a container for draggable views using the `dragContainer(for:id:in:selection:_:)` modifier.

- Use the `Animatable()` macro to have SwiftUI synthesize custom animatable data properties.

- `Slider` now supports tick marks. Tick marks appear automatically when initializing a `Slider` with the `step` parameter.

- Use `windowResizeAnchor(_:)` to set the window anchor point when a window must resize.

### Text

- `TextEditor` now supports `AttributedString`.

- Handle text selection with attributed text using `AttributedTextSelection`.

- `AttributedTextFormattingDefinition` defines how text can be styled in specific contexts.

- Use `FindContext` to create a find navigator in views that support text editing.

### Accessibility

- Support Assistive Access in iOS and iPadOS scenes with `AssistiveAccess`.

### HDR

- `Color.ResolvedHDR` is a set of RGBA values that represent a color that can be shown, including HDR headroom information.

### UIKit and AppKit integration

- Host and present SwiftUI scenes in UIKit with `UIHostingSceneDelegate` and in AppKit with `NSHostingSceneRepresentation`.

- Incorporate gesture recognizers in SwiftUI views from AppKit with `NSGestureRecognizerRepresentable`.

### Immersive spaces

- Manipulate views using common hand gestures with `manipulable(coordinateSpace:operations:inertia:isEnabled:onChanged:)`.

- Snap volumes to horizontal surfaces and windows to vertical surfaces using `SurfaceSnappingInfo`.

- Use `RemoteImmersiveSpace` to render stereo content from your Mac app on Apple Vision Pro.

- Use `SpatialContainer` to create a layout container that aligns overlapping content in 3D space.

- Depth-based variants of modifiers allow easier volumetric layouts in SwiftUI. For example, `aspectRatio3D(_:contentMode:)`, `rotation3DLayout(_:)`, and `depthAlignment(_:)`.

## June 2024

### Volumes

- Specify the alignment of a volume when moved in the world using the `volumeWorldAlignment(_:)` scene modifier.

- Specify the default world scaling behavior of your scene using the `defaultWorldScaling(_:)` scene modifier.

- Adjust the visibilty of a volume’s baseplate using the `volumeBaseplateVisibility(_:)` view modifier.

- Define a custom action to execute when the viewpoint of a volume changes using the `onVolumeViewpointChange(updateStrategy:initial:_:)` view modifier.

### Windows

- Change the default initial size and position of a window using the `defaultWindowPlacement(_:)` modifier.

- Change the default behavior for how windows behave when performing a zoom using `WindowIdealSize` and provide the placement for the zoomed window with the `windowIdealPlacement(_:)` modifier.

- Create utility windows in SwiftUI using the new `UtilityWindow` scene type and toggle the window’s visibility using the `WindowVisibilityToggle`.

- Customize the style of a window using the new `window` container background placement, the `toolbar(removing:)` view modifier, and the `plain` window style.

- Set the default launch behavior for a scene using the `defaultLaunchBehavior(_:)` modifier.

- Replace one scene with another using the `pushWindow` method.

### Immersive spaces

- Add an action to perform when the state of the immersion changes using the `onImmersionChange(_:)` modifier.

- Apply a custom color or dim a passthrough video in an immersive space using the `colorMultiply(_:)` and `dim(intensity:)` initializers.

### Documents

- Customize the launch experience of document-based applications using `DocumentGroupLaunchScene` and `NewDocumentButton`.

### Navigation

- Specify the appearance and interaction of `TabView` with the `tabViewStyle(_:)` modifier using values like `sidebarAdaptable`, `tabBarOnly`, and `grouped`.

- Build hierarchy by nesting tabs as a tab item within `TabSection`.

- Enable people to customize a `TabView` using the `tabViewCustomization(_:)` modifier and persist customization state in `AppStorage` with `TabViewCustomization`.

### Modal presentations

- Use built-in presentation sizes for sheets like `form` or `page` with the `presentationSizing(_:)` modifier or create custom sized sheets using the `PresentationSizing` protocol.

### Toolbars

- Specify the display mode of toolbars in macOS using the `ToolbarLabelStyle` type.

- Configure the foreground style in the toolbar environment in watchOS using the `toolbarForegroundStyle(_:for:)` view modifier.

- Anchor ornaments relative to the depth of your volume — in addition to the height and width — using the `scene(_:)` method that takes a `UnitPoint3D`.

### Views

- Create custom container views like `Picker`, `List`, and `TabView` using new `Group` and `ForEach` initializers, like `init(subviews:transform:)` and `init(subviews:content:)`, respectively.

- Declare a custom container value by defining a key that conforms to the `ContainerValueKey` protocol, and set the container value for a view using the `containerValue(_:_:)` modifier.

- Create `EnvironmentValues`, `Transaction`, `ContainerValues`, and `FocusedValues` entries by using the `Entry()` macro to the variable declaration.

### Animation

- Customize the transition when pushing a view onto a navigation stack or presenting a view with the `navigationTransition(_:)` view modifier.

- Add new symbols effects and configurations like `wiggle`, `rotate`, and `breathe` using the `symbolEffect(_:options:value:)` modifier.

### Text input and output

- Add text suggestions support to any text field using `textInputSuggestions(_:)` and `textInputCompletion(_:)` view modifiers.

- Access and modify selected text using a new `TextSelection` binding for `TextField` and `TextEditor`.

- Bind to the focus state of an app’s search field using the `searchFocused(_:equals:)` view modifier.

### Drawing and graphics

- Precompile shaders at build time using the `compile(as:)` method.

- Create mesh gradients with a grid of points and colors using the new `MeshGradient` type.

- Extend SwiftUI Text views with custom rendering effects and interaction behaviors using `TextAttribute`, `Text.Layout`, and `TextRenderer`.

- Create a new `Color` by mixing two colors using the `mix(with:by:in:)` method.

### Layout

- Enable custom spacing between views in a `ZStack` along the depth axis with the `init(alignment:spacing:content:)` initializer.

### Scrolling

- Scroll to a view, offset, or edge in a scroll view using the `scrollPosition(_:anchor:)` view modifier and specifying one of the `ScrollPosition` values.

- Limit the number of views that can be scrolled by a single interaction using the limit behavior value `alwaysByFew` or `alwaysByOne`.

- Add an action to be called when a view crosses a provided threshold using the `onScrollVisibilityChange(threshold:_:)` modifier.

- Access both the old and new values when a scroll view’s phase changes by using the `onScrollPhaseChange(_:)` modifier.

### Gestures

- Conditionally disable a gesture using the `isEnabled` parameter in a modifier like `gesture(_:isEnabled:)`.

- Create extra drag areas of a window in macOS when you add a `WindowDragGesture` gesture.

- Create a hand gesture shortcut for Double Tap in watchOS using the `HandGestureShortcut` structure.

- Enable whether gestures can handle events that activate the containing window using the `allowsWindowActivationEvents(_:)` view modifier.

### Input events

- Create a group of hover effects that activate together using `HoverEffectGroup` and apply them to a view using the `hoverEffect(in:isEnabled:body:)` view modifier.

- Customize the appearance of the system pointer in macOS, iPadOS, and visionOS with new pointer styles using `pointerStyle(_:)` or the visibility with the `pointerVisibility(_:)` modifier.

- Access keyboard modifier flags using the `onModifierKeysChanged(mask:initial:_:)`.

- Replace the primary view with one or more alternative views when pressing a specified set of modifier keys using the `modifierKeyAlternate(_:_:)` view modifier.

- Enable the hand pointer for custom drawing and markup applications using the `handPointerBehavior(_:)` modifier.

### Previews in Xcode

- Write dynamic properties inline in previews using the new `Previewable()` macro.

- Inject shared environment objects, model containers, or other dependencies into previews using the `PreviewModifier` protocol.

### Accessibility

- Specify that your accessibility element behaves as a tab bar using the `isTabBar` accessibility trait with the `accessibilityAddTraits(_:)` modifier. In UIKit, use `tabBar`.

- Generate a localized description of a color in a string interpolation by adding `accessibilityName:`, such as `"\(accessibilityName: myColor)"`. Pass that string to any accessibility modifier.

### Framework interoperability

- Reuse existing UIKit gesture recognizer code in SwiftUI. In SwiftUI, create UIKit gesture recognizers using `UIGestureRecognizerRepresentable`. In UIKit, refer to SwiftUI gestures by name using `name`.

- Share menu content definitions between SwiftUI and AppKit by using the `NSHostingMenu` in your AppKit view hierarchy.

* * *

## June 2023, visionOS

### Scenes

- Create a volume that can display 3D models by applying the `volumetric` window style to an app’s window.

- Make use of a Full Space by opening an `ImmersiveSpace` scene. You can use the `mixed` immersion style to place objects in a person’s surroundings, or the `full` style to completely control the visual experience.

- Display 3D models in a volume or a Full Space using RealityKit entities that you load with that framework’s `Model3D` or `RealityView` structure.

### Toolbars and ornaments

- Display a toolbar item in an ornament using the `bottomOrnament` toolbar item placement.

- Add an ornament to a window directly using the `ornament(visibility:attachmentAnchor:contentAlignment:ornament:)` view modifier.

### Drawing and graphics

- Detect view geometry in three dimensions using a `GeometryReader3D`.

- Add a 3D visual effect using the `visualEffect3D(_:)` view modifier.

- Rotate or scale in three dimensions with view modifiers like `rotation3DEffect(_:anchor:)` and `scaleEffect(x:y:z:anchor:)`, respectively.

- Convert between display points and physical distances using a `PhysicalMetricsConverter`.

### View configuration

- Add a glass background effect to a view using the `glassBackgroundEffect(displayMode:)` view modifier.

- Dim passthrough when appropriate by applying a `preferredSurroundingsEffect(_:)` modifier.

### View layout

- Make 3D adjustments to layout with view modifiers like `offset(z:)`, `padding3D(_:)`, and `frame(depth:alignment:)`.

### Gestures

- Enable people to rotate objects in three dimensions when you add a `RotateGesture3D` gesture.

## June 2023

### Scenes

- Close windows by their identifier using the `dismissWindow` action stored in the environment.

- Enable people to open a settings window by presenting a `SettingsLink` button.

### Navigation

- Control views of a navigation split view or stack using a new overload of the `navigationDestination(item:destination:)` view modifier.

- Manage column visibility of a navigation split view using new overloads of the view’s initializer, like `init(columnVisibility:preferredCompactColumn:sidebar:content:detail:)`.

### Modal presentations

- Use new overloads of the file export, import, and move modifiers, like `fileExporter(isPresented:document:contentTypes:defaultFilename:onCompletion:onCancellation:)`, to access new file management features. For example, you can:

- Configure a file import or export dialog to open on a default directory, enable only certain file types, display hidden files, and so on.

- Retain file interface configuration that a person chooses from one presentation to the next.

- Export types that conform to the `Transferable` protocol.
- Specify a dialog severity using the `dialogSeverity(_:)` view modifier.

- Provide a custom icon for a dialog using the `dialogIcon(_:)` modifier.

- Enable people to suppress dialogs using one of the dialog suppression modifiers, like `dialogSuppressionToggle(isSuppressed:)`.

### Toolbars

- Configure the toolbar title display size using the `toolbarTitleDisplayMode(_:)` modifier.

### Search

- Present search programmatically using a binding to a new `isPresented` parameter available in some searchable view modifiers, like `searchable(text:isPresented:placement:prompt:)`.

- Create mutable search tokens by providing a binding to the input of the `token` closure in the applicable searchable view modifiers, like `searchable(text:editableTokens:isPresented:placement:prompt:token:)`.

### Data and storage

- Bridge between SwiftUI environment keys and UIKit traits more easily using the `UITraitBridgedEnvironmentKey` protocol.

- Get better performance when you share data throughout your app by using the new `Observable()` macro.

- Access both the old and new values of a value that changes when processing the completion closure of the `onChange(of:initial:_:)` view modifier.

### Views

- Display a standard interface when a resource, like search results or a network connection, isn’t available using the `ContentUnavailableView` view type.

- Display a standard inspector interface with a platform-appropriate appearance by applying the `inspector(isPresented:content:)` modifier.

### Animation

- Perform an action when an animation completes by specifying a completion closure to the `withAnimation(_:completionCriteria:_:completion:)` view modifier.

- Define custom animation behaviors by creating a type that conforms to the `CustomAnimation` protocol.

- Perform animations that progress through predefined phases using the `PhaseAnimator` structure, or according to a set of time-based keyframes by using the `Keyframes` protocol.

- Specify information about a change in state — for example, to request a particular animation — using custom `TransactionKey` instances.

- Design custom animation curves using `UnitCurve`.

- Apply streamlined spring parameters, now standardized across all Apple frameworks, using the new `spring(duration:bounce:blendDuration:)` animation. You can also use the `Spring` structure as a convenience to represent a spring’s motion.

### Text input and output

- Indicate the language that appears in a specific `Text` view so that SwiftUI can help to avoid clipping and collision of text, and perform proper line breaking and hyphenation using the `typesettingLanguage(_:isEnabled:)` view modifier.

- Scale text semantically, for example by labeling it as having a secondary text scale, using the `textScale(_:isEnabled:)` modifier.

### Shapes

- Apply more than one `fill(_:style:)` or `stroke(_:style:antialiased:)` modifier to a single `Shape`.

- Apply Boolean operations to both shapes and paths, like `intersection(_:eoFill:)` and `union(_:eoFill:)`.

- Use predefined shape styles, like `rect`, to simplify your code.

- Create rounded rectangles with uneven corners using `rect(topLeadingRadius:bottomLeadingRadius:bottomTrailingRadius:topTrailingRadius:style:)`.

### Drawing and graphics

- Create fully customizable, high-performance graphics by drawing with Metal shaders inside a SwiftUI app using a `Shader` structure.

- Configure an image with a specific dynamic range by applying the `allowedDynamicRange(_:)` view modifier.

- Compose effects that you apply to a view based on some aspect of the geometry of the view using the `visualEffect(_:)` modifier. For example, you can apply a blur that varies depending on the view’s position in the display.

### Layout

- Define custom coordinate spaces using the `CoordinateSpaceProtocol` with new `GeometryProxy` methods, like `bounds(of:)` and `frame(in:)`, to get the dimensions of containers.

- Create a frame for a view that lays out its content based on characteristics of the container view using `containerRelativeFrame(_:alignment:)`.

- Set the background of a container view using the `containerBackground(_:for:)` view modifier.

### Lists and tables

- Disable selectability of an item in a `List` or `Table` by applying the `selectionDisabled(_:)` modifier.

- Collapse or expand a `Section` of a list or table using the `isExpanded` binding in the section’s initializer.

- Configure row or section spacing using the `listRowSpacing(_:)` and `listSectionSpacing(_:)` modifiers, respectively.

- Set the prominence of a badge using the `badgeProminence(_:)` view modifier.

- Configure alternating row backgrounds using the `alternatingRowBackgrounds(_:)` modifier.

- Customize table column visibility and reordering using the `TableColumnCustomization` structure.

- Add hierarchical rows to a table using the `DisclosureTableRow` structure, or recursively hierarchical rows using the `OutlineGroup` structure.

- Hide table column headers using the `tableColumnHeaders(_:)` modifier.

### Scrolling

- Read the position of a scroll view using one of the scroll position modifiers, like `scrollPosition(id:anchor:)`.

- Flash scroll indicators programmatically using a view modifier, like `scrollIndicatorsFlash(onAppear:)`.

- Clip scroll views in custom ways after disabling default clipping using the `scrollClipDisabled(_:)` modifier.

- Create paged scroll views, aligned to either page or view boundaries, using the `scrollTargetBehavior(_:)` view modifier.

- Create custom scroll behaviors using the `ScrollTargetBehavior` protocol.

- Control the insets of scrollable views using the `safeAreaPadding(_:)` and `contentMargins(_:_:for:)` view modifiers.

- Add effects to views as they scroll on- and offscreen using one of the `scrollTransition(_:axis:transition:)` modifiers.

- Create a `TabView` that supports vertical paging in watchOS by applying the `verticalPage` tab view style.

### Gestures

- Make smoother transitions between gestures and animations by using a new `velocity` property on the values associated with certain gestures and a `tracksVelocity` property on `Transaction`.

- Gain access to more information, including both velocity and position, by migrating to the new `MagnifyGesture` and `RotateGesture`, which replace the now deprecated `MagnificationGesture` and `RotationGesture`.

### Input events

- Enable a view that’s in focus to react directly to keyboard input by applying one of the `onKeyPress(_:action:)` view modifiers.

- Enable people to choose from a compact collection of items in a `Menu` by styling a `Picker` with the `palette` style.

- Provide haptic or audio feedback in response to an event using one of the sensory feedback modifiers, like `sensoryFeedback(_:trigger:)`.

- Create buttons and toggles that perform an `AppIntent` in a widget, Live Activity, and other places using new initializers like `init(_:intent:)` and `init(_:isOn:intent:)`.

### Focus

- Distinguish between views for which focus serves different purposes, such as those that have a primary action like a button and those that take input like a text field, using the new `focusable(_:interactions:)` view modifier.

- Manage the effect that receiving focus has on a view using the `focusEffectDisabled(_:)` modifier.

### Previews in Xcode

- Reduce the amount of boilerplate that you need to create Xcode previews by using the new `Preview(_:traits:_:body:)` macro.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates

Featured

# Updates

View major documentation updates and highlights from WWDC, browse ongoing updates from a set of framework releases over time, and jump to the latest release notes.

## Topics

### WWDC

Highlights of new technologies introduced at WWDC25.

Highlights of new technologies introduced at WWDC24.

Highlights of new technologies introduced at WWDC23.

Highlights of new technologies introduced at WWDC22.

Highlights of new technologies introduced at WWDC21.

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

Background Tasks updates

Learn about important changes in Background Tasks.

Bundle Resources updates

Learn about important changes to Bundle Resources.

BrowserEngineKit updates

Learn about important changes in BrowserEngineKit.

CallKit updates

Learn about important changes to CallKit.

ContactsUI updates

Learn about important changes to ContactsUI.

Core Location updates

Learn about important changes to Core Location.

Core MIDI updates

Learn about important changes to Core MIDI.

Core ML updates

Learn about important changes to Core ML.

Core Motion updates

Learn about important changes to Core Motion.

Core Spotlight updates

Learn about important changes to Core Spotlight.

DataDetection updates

Learn about important changes in DataDetection.

Default apps updates

Learn about the latest changes to enabling your app to be the system default.

DockKit updates

Learn about important changes to DockKit.

File Provider updates

Learn about important changes to File Provider.

FinanceKit updates

Learn more about changes to FinanceKit.

Foundation updates

Learn about important changes to Foundation.

Game Controller updates

Learn about important changes to Game Controller.

GameKit updates

Learn about important changes to GameKit.

Group Activities updates

Learn about important changes to Group Activities.

HealthKit updates

Learn about important changes to HealthKit.

Hypervisor updates

Learn about important changes to Hypervisor.

Journaling Suggestions updates

Learn about important changes in Journaling Suggestions.

LightweightCodeRequirements updates

Learn about important changes to LightweightCodeRequirements.

LiveCommunicationKit updates

Learn about important changes to LiveCommunicationKit.

MapKit updates

Learn about important changes to MapKit.

MapKitJS updates

Learn about important changes to MapKitJS.

Matter updates

Learn about important changes to Matter.

Network updates

Learn about important changes to Network.

PassKit updates

Learn more about changes to PassKit.

PHASE updates

Learn about important changes to PHASE.

PhotoKit updates

Learn about important changes to PhotoKit and PhotosUI.

ProximityReader updates

Learn about important changes to ProximityReader.

RealityKit updates

Learn about important changes in RealityKit.

SafariServices updates

Learn about important changes in SafariServices.

ScreenCaptureKit updates

Learn about important changes to ScreenCaptureKit.

Security updates

Learn about important changes to Security.

SensorKit updates

Learn about important changes to SensorKit.

ShazamKit updates

Learn about important changes in ShazamKit.

SiriKit updates

Learn about important changes in SiriKit.

StoreKit updates

Learn about important changes in StoreKit.

Swift updates

Learn about important changes to Swift.

Swift Charts updates

Learn about important changes to Swift Charts.

SwiftData updates

Learn about important changes to SwiftData.

SwiftUI updates

Learn about important changes to SwiftUI.

Symbols updates

Learn about important changes to Symbols.

TipKit updates

Learn about important changes in TipKit.

ThreadNetwork updates

Learn about important changes in ThreadNetwork.

UIKit updates

Learn about important changes to UIKit.

User Notifications updates

Learn about important changes in User Notifications.

Video Subscriber Account updates

Learn about important changes in Video Subscriber Account.

Virtualization updates

Learn about important changes to Virtualization.

Vision updates

Learn about important changes in Vision.

watchOS updates

Learn about important changes to watchOS.

WeatherKit updates

Learn about important changes to WeatherKit.

WidgetKit updates

Learn about important changes in WidgetKit.

WorkoutKit updates

Learn about important changes to WorkoutKit.

Xcode updates

Learn about important changes to Xcode.

XPC updates

Learn about important changes to XPC.

### Release notes for SDKs, Xcode, and Safari

iOS & iPadOS Release Notes

Learn about changes to the iOS & iPadOS SDK.

macOS Release Notes

Learn about changes to the macOS SDK.

tvOS Release Notes

Learn about changes to the tvOS SDK.

watchOS Release Notes

Learn about changes to the watchOS SDK.

visionOS Release Notes

Learn about changes to the visionOS SDK.

Xcode Release Notes

Learn about changes to Xcode.

Safari Release Notes

Learn about changes for Safari and Safari View Controller for iOS, iPadOS, macOS, and in visionOS; WKWebView for iOS, iPadOS, macOS, watchOS, and in visionOS; and Web Inspector on macOS.

---

# https://developer.apple.com/documentation/updates/accelerate

- Updates
- Accelerate updates

Article

# Accelerate updates

Learn about important changes to Accelerate.

## Overview

Browse notable changes in Accelerate.

## June 2024

- Check out the updated BLAS and LAPACK libraries under the Accelerate framework, now in line with LAPACK 3.11.0.

- Discover BNNS Graph API added to the Basic Neural Network Subroutines library that consumes, optimizes, and executes an entire ML model. BNNS Graph is suited to real-time and latency-sensitive ML use cases.

- Add new half-precision vectors and matrices to the simd header.

- Define spherical coordinates in radial, inclination, azimuthal order with the `SphericalCoordinates3D` structure in Spatial.

- Contain a position, rotation, and scale with the `ScaledPose3D` structure in Spatial.

## See Also

### Technology updates

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

Background Tasks updates

Learn about important changes in Background Tasks.

---

# https://developer.apple.com/documentation/updates/accessibility

- Updates
- Accessibility updates

Article

# Accessibility updates

Learn about important changes to Accessibility.

## Overview

Browse notable changes in Accessibility.

## June 2025

- Add Accessibility Nutrition Labels to your App Store product page to indicate which accessibility features your app supports.

- Support Assistive Access in iOS and iPadOS scenes with `AssistiveAccess`.

- Use `AXBrailleTranslator` to translate print text to Braille and Braille to print text according to a given Braille table.

- Use `openSettings(for:)` to open the Settings app to new sections of Accessibility settings, including `AccessibilitySettings.Feature.assistiveTouch`, `AccessibilitySettings.Feature.assistiveTouchDevices`, and `AccessibilitySettings.Feature.dwellControl`.

## June 2024

### General

- Enhance music with tactile feedback for people who are deaf or hard of hearing by playing Apple-generated haptic tracks along with music tracks. Add the `MusicHapticsSupported` `Info.plist` key to notify the system that your app supports the Music Haptics feature. Specify which song is playing using the `MPNowPlayingInfoPropertyInternationalStandardRecordingCode`. Music Haptics uses the International Standard Recording Code (ISRC) to choose the correct Music Haptics track to play at the same time. Observe and respond to the status of the haptic track playback using `MAMusicHapticsManager`.

- Open the Settings app to a specific section of Accessibility settings using `openSettings(for:)`.

- Support people’s preference to reduce the blinking animation of the text insertion indicator for custom cursor implementations. Check the value of the preference with `prefersNonBlinkingTextInsertionIndicator`, and observe when people change that preference with `prefersNonBlinkingTextInsertionIndicatorDidChangeNotification`.

- Check if a device uses Assistive Access with `isAssistiveAccessEnabled` if you need to remove workflows or UI elements that aren’t appropriate in the context of Assistive Access.

### SwiftUI

- Specify that your accessibility element behaves as a tab bar using the `isTabBar` accessibility trait with the `accessibilityAddTraits(_:)` modifier. In UIKit, use `tabBar`.

- Enhance how you structure accessibility labels by appending custom content using `accessibilityLabel(content:)`.

- Generate a localized description of a color in a string interpolation by adding `accessibilityName:`, such as `"\(accessibilityName: myColor)"`. Pass that string to any accessibility modifier.

## June 2023

- Provide a great experience for your app in Assistive Access, an accessibility feature that tailors the iOS and iPadOS experience for people with cognitive disabilities. Adopt `UISupportsFullScreenInAssistiveAccess` to allow your app’s UI to expand into all the available space above the Back button in Assistive Access.

- Personalize your app with Personal Voice, a new feature that lets people record and recreate their voice directly on their iOS and macOS devices. Personal voices appear alongside system voices and are available for Live Speech, a type-to-speak feature that lets a person synthesize speech on the fly. Request access to synthesize speech with personal voices using a new request authorization API in `AVSpeechSynthesizer`.

- Detect and mitigate sequences of flashing effects in your video content when the Dim Flashing Lights setting is on. If your app performs custom video drawing instead of using AVFoundation APIs, implement this behavior using `MAFlashingLightsProcessor`.

- Pause animated images in your app when a person turns off the Animated Images setting on their device. Check the value of this setting using `accessibilityPlayAnimatedImages`.

- Send announcement, layout change, screen change, and page scroll accessibility notifications with greater ease in multiplatform apps using the new Swift type `AccessibilityNotification`. Make sure people receive the most important information first by specifying a default, low, or high priority for announcements.

- Enhance custom accessibility elements by specifying the combination of traits and behaviors that best characterizes the element. Add the new trait `isToggle` to controls that toggle on and off, and the new action `accessibilityZoomAction(_:)` to content that can zoom in and out.

- Configure new direct touch options through `accessibilityDirectTouch(_:options:)` to provide the best experience for elements that support direct touch interactions in your app. Specify the `silentOnTouch` option to ensure VoiceOver is silent when a person interacts with the direct touch area so your app can provide its own audio feedback. Specify the `requiresActivation` option to make the direct touch area require VoiceOver to activate the element before touch passthrough happens.

- Simplify how you maintain your UIKit accessibility code with block-based setters for accessibility attributes.

- Ensure robust testing of your app’s accessibility experience by performing accessibility audits using `XCUIApplication`.

- Assign automation elements to expose certain UI elements specifically for the purpose of automation without affecting the accessibility of those elements.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

Background Tasks updates

Learn about important changes in Background Tasks.

---

# https://developer.apple.com/documentation/updates/activitykit

- Updates
- ActivityKit updates

Article

# ActivityKit updates

Learn about important changes in ActivityKit.

## Overview

Browse notable changes in ActivityKit.

## June 2025

- Live Activities automatically appear on the Mac in the Menu bar and in CarPlay.

- Schedule Live Activities for a specific time using `request(attributes:content:pushType:style:alertConfiguration:start:)`.

## June 2024

- Support Live Activities in the Smart Stack in watchOS.

- Use broadcast capabilities to send Live Activity updates for people that subscribe to your channel.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

Background Tasks updates

Learn about important changes in Background Tasks.

---

# https://developer.apple.com/documentation/updates/adattributionkit

- Updates
- AdAttributionKit Updates

Article

# AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

## Overview

Browse notable changes in AdAttributionKit.

## June 2024

- Add support for re-engagement which allows you to measure the success of ad campaigns that lead people to re-engage with apps they’ve already installed, while respecting their privacy.

- Specify a re-engagement URL: At runtime, advertisements can present a universal link registered for your app to launch to display content inside of advertised apps and begin re-engagement measurement.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

Background Tasks updates

Learn about important changes in Background Tasks.

---

# https://developer.apple.com/documentation/updates/appclips

- Updates
- App Clips updates

Article

# App Clips updates

Learn about important changes in App Clips.

## Overview

Browse notable changes in App Clips.

## June 2025

- Make a demo version of your app or game available as an App Clip.

- Use the autogenerated demo URL to offer an App Clip that’s up to 100 MB in size and supports physical invocations.

- Download additional assets for your App Clip with Background Assets.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

Background Tasks updates

Learn about important changes in Background Tasks.

---

# https://developer.apple.com/documentation/updates/appintents

- Updates
- App Intents updates

Article

# App Intents updates

Learn about important changes in App Intents.

## Overview

Browse notable changes in App Intents.

## June 2025

- Create app intents that conform to `SnippetIntent` to display an interactive snippet.

- Make app entities available in Spotlight that conform to `IndexedEntity` and use the `@ComputedProperty(indexingKey:)` or `@Property(indexingKey:)` Swift macros for attributes you want to add to the Spotlight index.

- Integrate your app with visual intelligence by providing app entities to the system using an `IntentValueQuery`.

- Create an `AppEntity` that conforms to the `Transferable` protocol and associate the app entity with a `NSUserActivity` using the activity’s `appEntityIdentifier` property to make onscreen content available to Siri without adopting an assistant schema.

## November 2024

### Siri and Apple Intelligence

- Make onscreen content available to Siri and Apple Intelligence by describing it as an `AppEntity` and adopting an assistant schema. Additionally, adopt the `Transferable` protocol, and associate the app entity with a `NSUserActivity` using the activity’s `appEntityIdentifier` property.

## June 2024

### System integration

- Integrate your app with Siri and Apple Intelligence using App intent domains.

- Use `ControlConfigurationIntent` and WidgetKit to allow users to put controls on the Lock Screen or in Control Center.

- Create a locked camera capture extension for your app and implement a `CameraCaptureIntent` to allow people to capture photos and videos from controls or the Action button.

- Create app intents that capture audio by implementing `AudioRecordingIntent`.

- Allow people to find app entities in Spotlight by adopting the `IndexedEntity` protocol.

### Content sharing

- Make it possible to share and transfer data you describe as App entities by conforming to `Transferable`.

- Receive content other apps make available with app intents by using `IntentFile` for your app intent parameters.

- Describe the file that stores your app intent data using `FileEntity`.

### General

- Provide additional information about errors with `AppIntentError.PermissionRequired`, `AppIntentError.Unrecoverable`, and `AppIntentError.UserActionRequired`.

- Pass a condition to `requestConfirmation(conditions:actionName:dialog:)` to only require user confirmation if a person’s context meets the provided condition.

- Use `URLRepresentableIntent`, `URLRepresentableEntity`, and `URLRepresentableEnum` to represent your app intents, app entities, and app enums as universal links that you use to provide deep links to your app’s content.

- Define a set of types for an intent parameter using the `UnionValue()` macro to create flexible app intents because a parameter can be of one of several pre-defined union types.

- Create entities that have just one singular instance with `UniqueAppEntity` and the corresponding `UniqueAppEntityQuery`. For example, to provide an app intent for app settings that appear in your app or in System Settings, create a singleton entity that encapsulates all settings as properties. Use it in the app intent that offers actions to change your app’s settings.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

Background Tasks updates

Learn about important changes in Background Tasks.

---

# https://developer.apple.com/documentation/updates/appkit

- Updates
- AppKit updates

Article

# AppKit updates

Learn about important changes to AppKit.

## Overview

Browse notable changes in AppKit.

## June 2025

### General

- To use control metrics consistent with macOS 15 and earlier, use `prefersCompactControlSizeMetrics`.

- `NSControl.ControlSize` includes a new extra large size, `NSControl.ControlSize.extraLarge`.

- Provide seamless immersive visuals by using `NSBackgroundExtensionView` to extend a view’s content under sidebars and inspectors.

- Apply Liquid Glass effects to your custom views using `NSGlassEffectView`. Use `NSGlassEffectContainerView` to efficiently merge these views when they’re in proximity to one other.

- Configure buttons for Liquid Glass by setting `NSButton.BezelStyle` to `NSButton.BezelStyle.glass`.

### Split views

- Add top and bottom accessory views in split views by adding one or more `NSSplitViewItemAccessoryViewController` objects to the `topAlignedAccessoryViewControllers` and `bottomAlignedAccessoryViewControllers` properties.

### Toolbars

- Tint toolbar items to make them stand out and stand apart from other toolbar items by setting `NSToolbarItem.Style` to `NSToolbarItem.Style.prominent`, and setting `backgroundTintColor`.

## April 2025

## June 2024

### General

- Organize your windows’ display and layout with window tiling.

### Swift and SwiftUI

- Use SwiftUI menus in AppKit with the `NSHostingMenu`.

- Animate AppKit views using SwiftUI animations using `animate(_:changes:completion:)`.

### API refinements

- Use the keyboard to open context menus for UI elements on which you are focused currently.

- Add repeat, wiggle, bounce, and rotate effects to SF Symbols.

- Leverage predefined content types when saving files using the new format picker on `NSPanel`.

- Resize frames and zoom in and out with new `NSCursor` APIs such as `NSCursor.FrameResizeDirection` and `NSCursor.FrameResizePosition`.

- Control whether your toolbars display text as well as icons using the `allowsDisplayModeCustomization` property.

- Offer customized type-ahead suggestions in NSTextField using the `suggestionsDelegate`.

## June 2023

### Views and controls

- Use the new `userCanChangeVisibilityOf` delegate method on `NSTableView` to toggle the visibility of table columns.

- Use a new `NSProgressIndicator` property to observe progress of an ongoing task.

- Simplify how you display and style buttons with the new `.automatic` bezel style. This bezel style adapts to the most appropriate style based on the contents of the button, as well as its location in the view hierarchy.

- Display additional contextual information about currently selected documents with `NSSplitView` inspectors.

- New improvements to `NSPopover` enable you to anchor popovers from toolbar items, as well as support full-size popovers.

- Explore new UI elements in `NSMenu`. Group information more easily in section headers, lay out menu items in horizontal palettes, as well as display badge counts on menu items.

### Cooperative app activation

- App activation is now driven by the user, preventing unexpected switches between apps.

- Take advantage of Cooperative Activation, where your apps can yield and accept activation from other apps on the system without interrupting the user’s workflows. For more information, see the `activate()` function on `NSApp` and `NSRunningApplication`.

### Graphics

- `CGPath` and `NSBezierPath` are now interoperable. You can create a `CGPath` from a `NSBezierPath` and vice versa.

- Leverage `CADisplayLink` to synchronize your app’s ability to draw to the refresh of the display.

- Create consistent, great visuals for your controls by taking advantage of standard system fill `NSColor` ( `.systemFill`, `.secondarySystemFill`, `.tertiarySystemFill`, `.quaternarySystemFill`, and `.quinarySystemFill`).

- Views no longer clip their contents by default. This includes any drawing done by the view and its subviews. For more information, see the `clipsToBounds` property on `NSView`.

- Animate symbol images with the new `addSymbolEffect` function on ` NSImageView`. Symbol effects include: bounce, pulse, variable color, scale, appear, disappear, and replace.

- Display and manipulate high dynamic range (HDR) images.

### Swift and SwiftUI

- AppKit more fully integrates with Swift and SwiftUI with Sendable ( `NSColor`, `NSColorSpace`, `NSGradient`, `NSShadow`, `NSTouch`) and Transferable ( `NSImage`, `NSColor`, `NSSound`) types.

- Preview your views and view controllers alongside your code using the new `#Preview` Swift macro. Incrementally adopt SwiftUI into your AppKit life cycle by leveraging modifiers like toolbar and navigation title on `NSWindows`.

- Simplify your code with new attributes, `@ViewLoading` and `@WindowLoading`, to help with view and window loading.

### Text improvements

- Help people enter text more effectively with the `NSTextInsertionIndicator` that adapts to the current accent color of the app. Cursor accessories also help users visualize where and how to enter text.

- Simplify `NSTextField` entry by leveraging the new `.contentType` AutoFill feature, making it more convenient to enter types such as contact information, birthdays, names, credit cards, and street addresses.

- Adopt text styles like `.body`, `largeTitle`, and `headline` on `NSFont.preferredFont` to take advantage of enhancements to the font system, like improved hyphenation for non-English languages and dynamic line-height adjustments for languages that require more vertical space. Access localized variants of symbol images by specifying a locale.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

Background Tasks updates

Learn about important changes in Background Tasks.

---

# https://developer.apple.com/documentation/updates/apple-intelligence

- Updates
- Apple Intelligence updates

Article

# Apple Intelligence updates

Learn about important changes to Apple Intelligence.

## Overview

Browse notable changes in Apple Intelligence.

## February 2025

- Use `ImageCreator` to generate images programmatically from your app on devices that support the capability. The system’s generative models use your provided description to generate one or more images and return them to your code. The `ImagePlaygroundConcept` type includes text you use to describe the image you wish to create, and `ImagePlaygroundStyle` sets the style to apply to that image.

- Learn how to Enabling Apple Intelligence summarization and prioritization using a Spotlight delegate app extension in your app.

- Learn about Adopting Smart Reply in your messaging or email app to give Apple Intelligence the context of your messaging or mail thread, and insert the generated response back into your app’s UI. Use `UIMessageConversationContext` for messaging, and `UIMailConversationContext` for email.

## January 2025

Writing Tools in UIKit:

- Display a bar button item to launch Writing Tools using `UIBarButtonItem.SystemItem.writingTools`.

- Integrate Writing Tools into your custom text engine using the API in Writing Tools.

Writing Tools in AppKit:

- Display a toolbar item to launch Writing Tools using `writingToolsItemIdentifier`.

## November 2024

- Make onscreen content available to Siri and Apple Intelligence with App Intents. Describe content as an `AppEntity` and adopt an assistant schema. Conform the entity to the `Transferable` protocol, and associate it with a `NSUserActivity` using the activity’s `appEntityIdentifier` property.

## July 2024

### Writing Tools

- In SwiftUI, adjust the level of support for Writing Tools features using the `writingToolsBehavior(_:)` modifier on the `Text`, `TextField`, and `TextEditor` types.

- In UIKit, detect activity using new `UITextViewDelegate` methods. Set your text view’s level of support for Writing Tools features using the `writingToolsBehavior` property of `UITextInputTraits`.

- In AppKit, detect activity using new `NSTextViewDelegate` methods. Set your text view’s level of support for Writing Tools features using the `writingToolsBehavior` property of `NSTextInputTraits`.

### Genmoji

- Handle Genmoji in text content using `NSAdaptiveImageGlyph`.

### Siri and App Intents

- Conform your `AppIntent`, `AppEntity`, and `AppEnum` implementations to the assistant schemas by applying the relevant macros to your types.

### Core Spotlight

- Search your indexed content for items that are similar in meaning to the query string, but not necessarily a lexical match, using `CSUserQuery`. Disable this semantic search support using the `disableSemanticSearch` property of `CSUserQueryContext`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

Background Tasks updates

Learn about important changes in Background Tasks.

---

# https://developer.apple.com/documentation/updates/applemapsserverapi

- Updates
- AppleMapsServerAPI Updates

Article

# AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

## Overview

Browse notable changes in Apple Maps Server API.

## June 2025

- Request cycling directions and ETAs using the cycling transport type; see `Search for directions and estimated travel time between locations`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

Background Tasks updates

Learn about important changes in Background Tasks.

---

# https://developer.apple.com/documentation/updates/applepencil

- Updates
- Apple Pencil updates

Article

# Apple Pencil updates

Learn about important changes to Apple Pencil.

## Overview

Browse notable changes in Apple Pencil.

## June 2024

### UIKit

- Implement custom low-latency drawing if your app doesn’t use PencilKit. Participate in UI updates and influence UI update behavior using `UIUpdateLink`.

### PencilKit

- Offer a wider variety of marking tools by creating a configurable tool picker. Create a `PKToolPicker`, add standard system tools or define your own custom tools with `PKToolPickerCustomItem`, and specify which order the tools appear in. Include an optional `accessoryItem` in the tool picker to provide quick access to additional features directly from the picker.

## May 2024

### SwiftUI and UIKit

- Leverage the hover pose of Apple Pencil to support more complex interactions in response to a double tap or squeeze. Information about the hover pose — such as azimuth, altitude, and hover distance — is available when a person holds a supported model of Apple Pencil close to the screen during a double tap or squeeze. In SwiftUI, use `PencilHoverPose`. In UIKit, use `UIPencilHoverPose`.

- Provide tactile feedback on Apple Pencil Pro by playing haptics in response to certain actions, such as snapping objects to a grid. In SwiftUI, use `SensoryFeedback`. In UIKit, use `UIFeedbackGenerator`.

- Track the barrel-roll angle of Apple Pencil Pro to create more expressive drawing experiences and hover previews using `rollAngle`.

- Check the value of the hover tool preview preference from the Apple Pencil section of the Settings app using `prefersHoverToolPreview`.

### PencilKit

- Take advantage of barrel-roll tracking for Apple Pencil Pro when a person makes marker and fountain pen strokes. Support `PKContentVersion.version3`, which includes the version of the inks that incorporate barrel-roll data.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

Background Tasks updates

Learn about important changes in Background Tasks.

---

# https://developer.apple.com/documentation/updates/arkit

- Updates
- ARKit updates

Article

# ARKit updates

Learn about important changes to ARKit.

## Overview

Browse notable changes to ARKit.

## June 2024

- Detect physical objects and attach digital content to them with `ObjectTrackingProvider`.

- Use the `RoomTrackingProvider` to understand the shape and size of the room that people are in and detect when they enter a different room.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

Background Tasks updates

Learn about important changes in Background Tasks.

---

# https://developer.apple.com/documentation/updates/audiotoolbox

- Updates
- Audio Toolbox updates

Article

# Audio Toolbox updates

Learn about important changes to Audio Toolbox.

## Overview

Browse notable changes in Audio Toolbox.

## June 2024

### Spatial audio with AUSpatialMixer

- Adjust the spatial mixer orientation to match someone’s head pose via compatible AirPods by setting the new `kAudioUnitProperty_SpatialMixerEnableHeadTracking` property to `true`. The system requires your app to have the `com.apple.developer.coremotion.head-pose` entitlement to observe this property.

- Tailor spatial mixing output according to a person’s personalized spatial audio profile that they configure in Settings by adding the `com.apple.developer.spatial-audio.profile-access` entitlement to your app.

- Instruct spatial mixing to ignore the new system spatial audio toggle in Control Center by adding the `AVGameBypassSystemSpatialAudio` key to your app’s `Info.plist`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

Background Tasks updates

Learn about important changes in Background Tasks.

---

# https://developer.apple.com/documentation/updates/authenticationservices

- Updates
- AuthenticationServices updates

Article

# AuthenticationServices updates

Learn about important changes to AuthenticationServices.

## Overview

Browse notable changes in Authentication Services.

## June 2024

### Passkeys

- Automatically upgrade someone’s password to a passkey after your app supplies a password to AutoFill if they’re eligible, while still retaining their password in case they need it. To do this, call `createCredentialRegistrationRequest(clientData:name:userID:requestStyle:)`, passing `ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest.RequestStyle.conditional` for the `requestStyle` parameter.

- Use the `prf` WebAuthentication extension to generate a symmetric key from a passkey, which you use for encrypting and decrypting someone’s data. Each passkey generates its own symmetric keys, which you can retrieve any time a user signs in with that passkey, in apps or on the web.

### Credential providers

- Indicate to the system that your credential provider participates in OTP AutoFill by adding the key `ProvidesOneTimeCodes` with the value `true` to the `ASCredentialProviderExtensionCapabilities` dictionary in your app’s information property list. Implement `provideCredentialWithoutUserInteraction(for:)` and `prepareInterfaceToProvideCredential(for:)` to handle the `ASOneTimeCodeCredentialRequest` type. Use `completeOneTimeCodeRequest(using:completionHandler:)` to return the one time code to the system.

- Supply AutoFill for text in arbitrary text fields, for example to complete information about an account that someone manages in your credential provider, or AutoFill text in secure notes. Indicate to the system that your credential provider supplies AutoFill text by adding the key ProvidesTextToInsert with the value true to the `ASCredentialProviderExtensionCapabilities` dictionary in your app’s information property list, and implement `prepareInterfaceForUserChoosingTextToInsert()`. When the person chooses the text to AutoFill in your UI, call `completeRequest(withTextToInsert:completionHandler:)` to supply the text to the system.

- Use `ASPasskeyCredentialExtensionInput` to represent `largeBlob` and `prf` extension input data in a passkey credential request. Return output for these WebAuthentication extensions using `ASPasskeyAssertionCredentialExtensionOutput` and `ASPasskeyRegistrationCredentialExtensionOutput` as part of the `ASPasskeyAssertionCredential` and `ASPasskeyRegistrationCredential` objects you

- Support stronger encryption and signing options by specifying `supportedDeviceEncryptionAlgorithms`, `supportedDeviceSigningAlgorithms`, and `supportedUserSecureEnclaveKeySigningAlgorithms` in the SSO extension. You can now use Hybrid Public Key Encryption (HPKE) algorithms defined in `ASAuthorizationProviderExtensionEncryptionAlgorithm`: `ecdhe_A256GCM`, `hpke_P256_SHA256_AES_GCM_256`, `hpke_P384_SHA384_AES_GCM_256`, and `hpke_Curve25519_SHA256_ChachaPoly`.

- If you use HPKE, receive notifications when the system rotates the encryption key by implementing `keyWillRotate(for:newKey:loginManager:completion:)` in your SSO extension. The system automatically rotates the encryption key about once per week. This lets you register the new key on the server.

- Rotate the keys you use for platform SSO by calling the `ASAuthorizationProviderExtensionLoginManager` methods `beginKeyRotation(_:)` and `completeKeyRotation(_:)`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

Background Tasks updates

Learn about important changes in Background Tasks.

---

# https://developer.apple.com/documentation/updates/avfaudio

- Updates
- AVFAudio updates

Article

# AVFAudio updates

Learn about important changes to AVFAudio.

## Overview

Browse notable changes in AVFAudio.

## June 2024

### Spatial audio with AVAudioEngine

- Adjust the `AVAudioEnvironmentNode` orientation to match someone’s head pose via compatible AirPods by setting the new `isListenerHeadTrackingEnabled` property to `true`. The system requires your app to have the `com.apple.developer.coremotion.head-pose` entitlement to observe this property.

- Tailor `AVAudioEnvironmentNode` output according to a person’s personalized spatial audio profile that they configure in Settings by adding the `com.apple.developer.spatial-audio.profile-access` entitlement to your app.

- Instruct `AVAudioEnvironmentNode` to ignore the new system spatial audio toggle in Control Center by adding the `AVGameBypassSystemSpatialAudio` key to your app’s `Info.plist`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFoundation updates

Learn about important changes to AVFoundation.

Background Tasks updates

Learn about important changes in Background Tasks.

---

# https://developer.apple.com/documentation/updates/avfoundation

- Updates
- AVFoundation updates

Article

# AVFoundation updates

Learn about important changes to AVFoundation.

## Overview

Browse notable changes in AVFoundation.

## June 2024

### Assets

- Preserve HDR data when generating images with `AVAssetImageGenerator` by setting the value of its `dynamicRangePolicy` property to match the source video.

- Export media asynchronously using the `export(to:as:isolation:)` method of `AVAssetExportSession`. You can monitor the progress of an export by calling the `states(updateInterval:)` method and awaiting its results.

- Determine whether an `AVURLAsset` decodes its data using a Media Extension by inspecting its `mediaExtensionProperties` property.

### Camera

- Show your camera app on the Lock Screen by adopting the LockedCameraCapture framework.

- Capture photos in constant color by configuring a photo output’s `isConstantColorEnabled` property.

- Continue background audio playback while performing audio and video capture by enabling a capture session’s `configuresApplicationAudioSessionToMixWithOthers` property.

- Pause and resume video recording in iOS when using `AVCaptureFileOutput`.

- Support enhanced video stabilization using `AVCaptureVideoStabilizationMode.cinematicExtendedEnhanced`.

- Configure a capture device to automatically adjust its frame rate based on lighting conditions by enabling its `isAutoVideoFrameRateEnabled` property.

- Configure a capture device to replace background content in macOS by enabling its `isBackgroundReplacementEnabled` property.

### Playback

- Build playback apps using the latest Swift Concurrency features due to enhanced `Sendable` adoption throughout the playback APIs.

- Capture performance and playback metrics using `AVMetrics`.

- Receive rendered captions for the currently playing media using `AVPlayerItemRenderedLegibleOutput`.

- Simplify handling of interstitial content by using `AVPlayerItemIntegratedTimeline`.

- Send Common Media Client Data (CMCD) as HTTP headers by enabling the new `sendsCommonMediaClientDataAsHTTPHeaders` property on `AVAssetResourceLoader`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

Background Tasks updates

Learn about important changes in Background Tasks.

---

# https://developer.apple.com/documentation/updates/accelerate)



---

# https://developer.apple.com/documentation/updates/accessibility)



---

# https://developer.apple.com/documentation/updates/activitykit)



---

# https://developer.apple.com/documentation/updates/adattributionkit)



---

# https://developer.apple.com/documentation/updates/appclips)



---

# https://developer.apple.com/documentation/updates/appintents)



---

# https://developer.apple.com/documentation/updates/appkit)



---

# https://developer.apple.com/documentation/updates/apple-intelligence)



---

# https://developer.apple.com/documentation/updates/applemapsserverapi)



---

# https://developer.apple.com/documentation/updates/applepencil)



---

# https://developer.apple.com/documentation/updates/arkit)



---

# https://developer.apple.com/documentation/updates/audiotoolbox)



---

# https://developer.apple.com/documentation/updates/authenticationservices)



---

# https://developer.apple.com/documentation/updates/avfaudio)



---

# https://developer.apple.com/documentation/updates/avfoundation)



---

# https://developer.apple.com/documentation/updates/backgroundtasks

- Updates
- Background Tasks updates

Article

# Background Tasks updates

Learn about important changes in Background Tasks.

## Overview

Browse notable changes in Background Tasks.

## June 2025

### Continuous Background Tasks

- Execute long-running jobs using the Continuous Background Task ( `BGContinuedProcessingTask`), which enables your app’s critical work to complete in the background when a person sends your app to the background before the job completes. For more information, see Performing long-running tasks on iOS and iPadOS.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/backgroundtasks)



---

# https://developer.apple.com/documentation/updates/wwdc2025

- Updates
- WWDC25

# WWDC25

Highlights of new technologies introduced at WWDC25.

## Overview

Browse a selection of documentation for new technologies and frameworks introduced at WWDC25. Many existing frameworks have added significant functionality to enhance your apps when run on the latest platform releases.

## Topics

### Accessibility

Add Accessibility Nutrition Labels to your App Store product page to highlight features you support to give your app a greater reach. For instance, a person that requires reading glasses may search the store for apps that support Larger Text.

Accessibility

Make your apps accessible to everyone who uses Apple devices.

### App services

PaperKit

Add drawings, shapes, and a consistent markup experience to your app.

EnergyKit

Provide a grid forecast for your app to help people choose when to use electricity.

Beta

Performing long-running tasks on iOS and iPadOS

Use a continuous background task to do work that can complete as needed.

`final actor SpeechAnalyzer`

Analyzes spoken audio content in various ways and manages the analysis session.

Creating custom views for Live Activities

Create reusable custom views and layouts that support each Live Activity presentation.

Launching your app from a Live Activity

Use deep links to enable people to open your app’s scene that matches the data of you Live Activity.

Configuring App Clip experiences

Review how people launch your App Clip with invocation URLs, default and demo links, and advanced App Clip experiences.

### App Store distribution and marketing

Understanding StoreKit workflows

Implement an in-app store with several product types, using StoreKit views.

Configuring your Background Assets project

Edit your app and extension targets in your Xcode project to use Background Assets.

Background Assets

Schedule background downloads of large assets during or after app installation, when the app updates, and periodically while the app remains on-device.

Configuring attribution rules for your app

Tune aspects of attribution flow, including the time available to register impressions and the minimum time your app is willing to accept conversions.

Identifying the parameters in a postback

Interpret postback properties to understand the attribution report.

Receiving postbacks in multiple conversion windows

Learn about the data that postbacks can contain in each conversion window.

### Apple Intelligence and machine learning

Apple Intelligence and machine learning

Add intelligent features with Apple Intelligence, machine learning, and related technologies.

Foundation Models

Perform tasks with the on-device model that specializes in language understanding, structured output, and tool calling.

Improving safety from generative model output

Create generative experiences that appropriately handle sensitive inputs and respect people.

Integrating actions with Siri and Apple Intelligence

Create app intents, entities, and enumerations that conform to assistant schemas to tap into the enhanced action capabilities of Siri and Apple Intelligence.

Displaying static and interactive snippets

Enable people to view the outcome of an app intent and immediately perform follow-up actions.

Making app entities available in Spotlight

Allow people to find your app’s content in Spotlight by donating app entities to its semantic index.

Generating content and performing tasks with Foundation Models

Enhance the experience in your app by prompting an on-device large language model.

Visual Intelligence

Include your app’s content in search results that visual intelligence provides.

Integrating your app with visual intelligence

Enable people to find app content that matches their surroundings or objects onscreen with visual intelligence.

Recognizing tables within a document

Scan a document containing a contact table and extract the content within the table in a formatted way.

`struct DetectLensSmudgeRequest`

A request that detects a smudge on a lens from an image or video frame capture.

### Apple Pay and Wallet

Implementing as an identity document provider

Add your app as an option for mobile document web presentment.

IdentityDocumentServices

Share mobile documents using the Digital Credentials API.

IdentityDocumentServicesUI

Provide an interface so people can present mobile documents.

Setting up Tap to Pay on iPhone

Request and configure the required entitlement to support Tap to Pay on iPhone.

### Audio, Video, and Media

Signing people in to their media accounts automatically

Implement single sign-on for media-streaming apps by managing a sign-in token on a person’s Apple Account.

Video Subscriber Account

Support TV provider and Apple TV app functionality.

Automatic Sign-In API

Manage sign-in tokens that facilitate single sign-on across the devices of your media streaming service customers from your web server.

Capturing Spatial Audio in your iOS app

Enhance your app’s audio recording capabilities by supporting Spatial Audio capture.

Editing Spatial Audio with an audio mix

Add Spatial Audio editing capabilities with the Audio Mix API in the Cinematic framework.

Enhancing your app with machine learning-based video effects

Add powerful effects to your videos using the VideoToolbox VTFrameProcessor API.

Observing playback state in SwiftUI

Keep your user interface in sync with state changes from playback objects.

Anchoring sound to a window or volume

Provide unique app experiences by attaching sounds to windows and volumes in 3D space.

Creating a seamless multiview playback experience

Build advanced multiview playback experiences with the AVFoundation and AVRouting frameworks.

### Developer tools

Creating your app icon using Icon Composer

Use Icon Composer to stylize your app icon for different platforms and appearances.

Writing code with intelligence in Xcode

Generate code, fix bugs fast, and learn as you go with intelligence built directly into Xcode.

Running code snippets using the playground macro

Add playgrounds to your code that run and display results in the canvas.

Understanding and improving SwiftUI performance

Identify and address long-running view updates, and reduce the frequency of updates.

Analyzing the performance of your shipping app

View power and performance metrics for apps you distribute through the App Store.

Recording UI automation for testing

Capture and replay interaction sequences to verify your app’s behavior.

Downloading and installing additional Xcode components

Add more Simulator runtimes, optional features, and support for additional platforms.

Measuring your app’s power use with Power Profiler

Profile your app’s power impact whether or not your device is connected to Xcode.

### Graphics and games

Game technologies

Plan the creation of your game and incorporate the gameplay features people expect.

GameSave

Store and sync your application’s save files in iCloud.

Touch Controls

Integrate on-screen touch controls into your Metal-based games.

Discovering and tracking spatial game controllers and styli

Receive controller and stylus input to interact with content in your augmented reality app.

Creating activities for your game

Use activities to surface game content to players and encourage them to connect with each other.

`class GKGameActivity`

An object that represents a single instance of a game activity for the current game.

Choosing a leaderboard for your challenges

Understand what gameplay works well when configuring challenges in your game.

Creating engaging challenges from leaderboards

Encourage friendly competition by adding challenges to your game.

Building your macOS game remotely from your PC

Configure a Mac for remote builds, and use it to build your game from your PC and catch mistakes when porting your game to macOS.

### Maps and location

GeoToolbox

Determine place descriptor information for map coordinates.

`struct PlaceDescriptor`

A structure that contains identifying information about a place that a mapping service may use to attempt to find rich place information such as phone numbers, websites, and so on.

`interface mapkit.LookAround`

A view that allows someone to see a street level view of a place.

`interface mapkit.LookAroundPreview`

A class that renders a preview of a LookAround view.

### Metal

Understanding the Metal 4 core API

Discover the features and functionality in the Metal 4 foundational APIs.

Using the Metal 4 compilation API

Control when and how you compile an app’s shaders.

Using a Render Pipeline to Render Primitives

Render a colorful, 2D triangle by running a draw command on the GPU.

Processing a texture in a compute function

Create textures by running copy and dispatch commands in a compute pass on a GPU.

Machine-Learning Passes

Add machine-learning model inference to your Metal app’s GPU workflow.

Resource Synchronization

Prevent multiple commands that can access the same resources simultaneously by coordinating those accesses with barriers, fences, or events.

Synchronizing resource accesses within a single pass with an intrapass barrier

Resolve resource access conflicts between stages within a single pass by adding an intrapass barrier.

Synchronizing resource accesses between multiple passes with a fence

Resolve resource access conflicts between multiple passes within a single command queue by signaling a fence in one pass and waiting for it in another.

Synchronizing resource accesses with earlier passes with a consumer-based queue barrier

Resolve resource access conflicts between multiple passes within a single command queue by creating a consumer-based intraqueue barrier.

Synchronizing resource accesses with subsequent passes with a producer-based queue barrier

Resolve resource access conflicts between multiple passes within a single command queue by creating a producer-based intraqueue barrier.

### Parental controls and safety

PermissionKit

Create communication experiences between a child and their parent or guardian.

DeclaredAgeRange

Create age-appropriate experiences in your app by asking people to share their age range.

`class SCVideoStreamAnalyzer`

An object that monitors a stream of video by analyzing frames for sensitive content.

### Security and privacy

Enabling enhanced security for your app

Detect out-of-bounds memory access, use of freed memory, and other potential vulnerabilities.

Creating extensions with enhanced security

Reduce opportunities for an attacker to target your app through its extensions.

### Spatial computing with visionOS

Immersive Media Support

Read and write essential Apple Immersive Video metadata.

Authoring Apple Immersive Video

Prepare and package immersive video content for delivery.

Adopting best practices for persistent UI

Create persistent and contextually relevant spatial experiences by managing scene restoration, customizing window behaviors, and surface snapping data.

Presenting images in RealityKit

Create and display spatial scenes in RealityKit.

Tracking accessories in volumetric windows

Translate the position and velocity of tracked handheld accessories to throw virtual balls at a stack of cans.

Configure your visionOS app for sharing with people nearby

Create shared experiences for people wearing Vision Pro in the same room and those on FaceTime.

### SwiftUI, UIKit, and AppKit

Liquid Glass

Learn how to design and develop beautiful interfaces that leverage Liquid Glass.

Adopting Liquid Glass

Find out how to bring the new material to your app.

Landmarks: Building an app with Liquid Glass

Enhance your app experience with system-provided and custom Liquid Glass.

Landmarks: Displaying custom activity badges

Provide people with a way to mark their adventures by displaying animated custom activity badges.

Landmarks: Refining the system provided Liquid Glass effect in toolbars

Organize toolbars into related groupings to improve their appearance and utility.

Landmarks: Extending horizontal scrolling under a sidebar or inspector

Improve your horizontal scrollbar’s appearance by extending it under a sidebar or inspector.

Applying Liquid Glass to custom views

Configure, combine, and morph views using Liquid Glass effects.

Building and customizing the menu bar with SwiftUI

Provide a seamless, cross-platform user experience by building a native menu bar for iPadOS and macOS.

Populating SwiftUI menus with adaptive controls

Improve your app by populating menus with controls and organizing your content intuitively.

Building rich SwiftUI text experiences

Build an editor for formatted text using SwiftUI text editor views and attributed strings.

### System services

Wi-Fi Aware

Securely pair and connect to external devices over peer-to-peer Wi-Fi.

Connecting devices for peer-to-peer Wi-Fi

Make outgoing and accept incoming secure connections with paired devices.

Building peer-to-peer apps

Communicate with nearby devices over a secure, high-throughput, low-latency connection by using Wi-Fi Aware.

Adopting Wi-Fi Aware

Add entitlements and declare your app’s services.

AlarmKit

Schedule prominent alarms and countdowns to help people manage their time.

Scheduling an alarm with AlarmKit

Create prominent alerts at specified dates for your iOS app.

WirelessInsights

Receive notifications for anticipated changes in cellular data service conditions.

RelevanceKit

Provide on-device intelligence with contextual clues that increase your widget’s visibility on Apple Watch.

TelephonyMessagingKit

Send and receive standards-based messages over cellular networks.

## See Also

### WWDC

Highlights of new technologies introduced at WWDC24.

Highlights of new technologies introduced at WWDC23.

Highlights of new technologies introduced at WWDC22.

Highlights of new technologies introduced at WWDC21.

---

# https://developer.apple.com/documentation/updates/wwdc2024

- Updates
- WWDC24

# WWDC24

Highlights of new technologies introduced at WWDC24.

## Overview

Browse a selection of documentation for new technologies and frameworks introduced at WWDC24. Many existing frameworks have added significant functionality, and you’ll find new ways to enhance your apps targeting the latest platform release.

## Topics

### Accessibility and inclusion

Enhancing the accessibility of your SwiftUI app

Support advancements in SwiftUI accessibility to make your app accessible to everyone.

Optimizing your app for Assistive Access

Adjust your app’s UI to make sure it works well for people who use Assistive Access.

Music Haptics

Play haptic tracks along with known music tracks.

### App services

Building a guessing game for visionOS

Create a team-based guessing game for visionOS using Group Activities.

Discovering HID devices from Terminal

Identify devices connected to your Mac from the command line.

Creating virtual devices

Use and interact with a virtual human interface device for testing and development.

### Audio and video

Creating a MIDI device driver

Implement a configurable virtual MIDI driver as a driver extension that runs in user space in macOS and iPadOS.

### App Store distribution and marketing

Implementing Wallet Extensions

Support adding an issued card to Apple Pay from directly within Apple Wallet using Wallet Extensions.

Testing win-back offers in Xcode

Validate your app’s handling of win-back offers that you configure for the testing environment.

### Developer tools

Configuring your app icon using an asset catalog

Add app icon variations to an asset catalog that represents your app in places such as the App Store, the Home Screen, Settings, and search results.

Determining how much code your tests cover

Use code coverage to focus new test development on areas that lack adequate testing.

Adding tests to your Xcode project

Include test targets that build code to test the logic in your functions, check for integration issues, automate UI workflows, and measure performance.

Updating your existing codebase to accommodate unit tests

Remove coupling between components to increase test coverage and reliability.

Building your project with explicit module dependencies

Reduce compile times by eliminating unnecessary module variants using the Xcode build system.

### Graphics and games

Adding touch controls to games that support game controllers in iOS

Use touch input and virtual controllers to make your game available to players without controllers.

Improving the player experience for games with large downloads

Provide ample content in your base installation and then use on-demand resources and the Background Assets API to handle additional content.

Improving your game’s graphics performance and settings

Fix performance glitches and develop default settings for smooth experiences on Apple platforms using the powerful suite of Metal development tools.

Adapting your game interface for smaller screens

Make text legible on all devices the player chooses to run your game on.

Personalizing spatial audio in your app

Enhance the realism of spatial audio output by tracking a person’s head movement and accounting for their personal spatial audio profile.

### Health and fitness

Visualizing HealthKit State of Mind in visionOS

Incorporate HealthKit State of Mind into your app and visualize the data in visionOS.

Authorizing access to health data

Request permission to read and share data in your app.

### Maps and location

Creating a Maps token

Generate your token to access MapKit services with proper authorization.

Identifying unique locations with Place IDs

Obtain information about a point of interest that persists over its lifetime.

Displaying place information using the Maps Embed API

Show place information on a map using a URL.

Monitoring the user’s proximity to geographic regions

Use condition monitoring to determine when the user enters or leaves a geographic region.

### ML and Vision

Core ML

Integrate machine learning models into your app.

Vision

Apply computer vision algorithms to perform a variety of tasks on input images and videos.

### Photos and camera

Writing spatial photos

Create spatial photos for visionOS by packaging a pair of left- and right-eye images as a stereo HEIC file with related spatial metadata.

Creating spatial photos and videos with spatial metadata

Add spatial metadata to stereo photos and videos to create spatial media for viewing on Apple Vision Pro.

### Spatial computing

Interacting with your app in the visionOS simulator

Use your Mac to navigate spaces and control interactions with your visionOS apps in Simulator.

Understanding the visionOS render pipeline

Compare how visionOS handles events and manages its rendering loop differently from other Apple platforms.

### Swift

Creating a data visualization dashboard with Swift Charts

Visualize an entire data collection efficiently by instantiating a single vectorized plot in Swift Charts.

Traits

Annotate test functions and suites, and customize their behavior.

Running tests serially or in parallel

Control whether tests run serially or in parallel.

Testing asynchronous code

Validate whether your code causes expected events to happen.

Defining test functions

Define a test function to validate that code is working correctly.

Migrating a test from XCTest

Migrate an existing test method or test class written using XCTest.

### SwiftUI and UI frameworks

Creating visual effects with SwiftUI

Add scroll effects, rich color treatments, custom transitions, and advanced effects using shaders and a text renderer.

Elevating your iPad app with a tab bar and sidebar

Provide a compact, ergonomic tab bar for quick access to key parts of your app, and a sidebar for in-depth navigation.

Customizing a document-based app’s launch experience

Add unique elements to your app’s document launch scene.

Collaborating and sharing copies of your data

Share data and collaborate with people from your app.

### System services

Creating your first app intent

Create your first app intent that makes your app available in system experiences like Spotlight or the Shortcuts app.

Making actions and content discoverable and widely available

Adopt App Intents to make your app discoverable with Spotlight, controls, widgets, and the Action button.

Identifying and blocking calls

Create a Call Directory app extension to identify and block incoming callers by their phone number.

Getting up-to-date calling and blocking information for your app

Implement the Live Caller ID Lookup app extension to provide call-blocking and identity services.

Adding your app’s content to Spotlight indexes

Create a description for your app’s content and add it to a Spotlight index to make it searchable.

Building a search interface for your app

Add a search interface to your app to execute Spotlight queries and offer suggested text completions.

Searching for information in your app

Search for app-specific content and refine search results using predicates and filters.

Sending channel management requests to APNs

Manage channels that your application uses for broadcast push notifications.

Troubleshooting push notifications

Debug your server to send push notifications with device and broadcast push notifications.

Using iCloud with macOS virtual machines

Access iCloud from macOS guest virtual machines.

## See Also

### WWDC

Highlights of new technologies introduced at WWDC25.

Highlights of new technologies introduced at WWDC23.

Highlights of new technologies introduced at WWDC22.

Highlights of new technologies introduced at WWDC21.

---

# https://developer.apple.com/documentation/updates/wwdc2023

- Updates
- WWDC23

# WWDC23

Highlights of new technologies introduced at WWDC23.

## Overview

Browse a selection of documentation for new technologies, frameworks, and APIs introduced at WWDC23. Many existing frameworks have added significant functionality, and you’ll find new ways to enhance your apps targeting the latest platform release.

## Topics

### visionOS

visionOS is a brand new platform that allows you to build immersive apps and games for spatial computing that run on Apple Vision Pro. Create new apps using SwiftUI to take full advantage of the spectrum of immersion available in visionOS. If you have an existing iPad or iPhone app, add the visionOS destination to your app’s target to gain access to the standard system appearance, and add platform-specific features to create a compelling experience.

visionOS

Create a new universe of apps and games for Apple Vision Pro.

Hello World

Use windows, volumes, and immersive spaces to teach people about the Earth.

Creating your first visionOS app

Build a new visionOS app using SwiftUI and add platform-specific features.

Designing for visionOS

When people wear Apple Vision Pro, they enter an infinite 3D space where they can engage with your app or game while staying connected to their surroundings.

Adding 3D content to your app

Add depth and dimension to your visionOS app and discover how to incorporate your app’s content into a person’s surroundings.

Bringing your existing apps to visionOS

Build a version of your iPadOS or iOS app using the visionOS SDK, and update your code for platform differences.

### SwiftData

Use SwiftData with SwiftUI to create a seamless connection from your data model to user interface. Like SwiftUI, SwiftData focuses entirely on code, with no external file formats to manage. Instead, it uses Swift’s new macro system to offer a streamlined API. SwiftData uses the `Codable` protocol to understand structures and enumerations, so you can model your data with the tools you already know. These types are fully modeled in the underlying data store, enabling you to perform fast and efficient queries, even on complex structured data.

SwiftData

Write your model code declaratively to add managed persistence and efficient model fetching.

Building a document-based app using SwiftData

Code along with the WWDC presenter to transform an app with SwiftData.

### Widgets, Live Activities, and watchOS complications

Bring your widgets to new places like the macOS desktop, Standby, and the Lock Screen on iPad. And now many of your widgets also gain new interactive abilities using `Button` and `Toggle`. Support Live Activities to keep users updated with the latest data from your app. Add animations in your widget to respond to user action or data changes.

WidgetKit

Extend the reach of your app by creating widgets, watch complications, Live Activities, and controls.

Developing a WidgetKit strategy

Explore features, tasks, related frameworks, and constraints as you make a plan to implement widgets, controls, watch complications, and Live Activities.

Emoji Rangers: Supporting Live Activities, interactivity, and animations

Offer Live Activities, controls, animate data updates, and add interactivity to widgets.

Creating a widget extension

Display your app’s content in a convenient, informative widget on various devices.

Making network requests in a widget extension

Update your widget with new information you fetch with a network request.

Creating views for widgets, Live Activities, and watch complications

Implement glanceable views with WidgetKit and SwiftUI.

Creating accessory widgets and watch complications

Support accessory widgets that appear on the Lock Screen and as complications on Apple Watch.

Supporting additional widget sizes

Offer widgets in additional contexts by adding support for various widget sizes.

Preparing widgets for additional platforms, contexts, and appearances

Create widgets that support additional platforms and adapt to their context.

Adding interactivity to widgets and Live Activities

Include buttons or toggles in a widget or Live Activity to offer app functionality without launching the app.

Animating data updates in widgets and Live Activities

Use SwiftUI animations to indicate data updates in your widgets and Live Activities.

Linking to specific app scenes from your widget or Live Activity

Add deep links to your widgets and Live Activities that enable people to open a specific scene in your app.

Making a configurable widget

Give people the option to customize their widgets by adding a custom app intent to your project.

Migrating widgets from SiriKit Intents to App Intents

Configure your widgets for backward compatibility.

Keeping a widget up to date

Plan your widget’s timeline to show timely, relevant information using dynamic views, and update the timeline when things change.

Increasing the visibility of widgets in Smart Stacks

Provide contextual information and donate intents to the system to make sure your widget appears prominently in Smart Stacks.

ActivityKit

Share live updates from your app as Live Activities on iPhone, iPad, Apple Watch, and the Mac.

Displaying live data with Live Activities

Display up-to-date data and offer quick interactions in the Dynamic Island, on the Lock Screen, in CarPlay, and on a paired Mac or Apple Watch.

### SwiftUI

Use the ever-expanding SwiftUI API in your apps, with greater control over scroll and focus behavior, and more. Build sophisticated animations with advanced new capabilities, and even automatically match the speed of your animation to the velocity of user gestures. Share more SwiftUI code with your watchOS app using new `TabView`, `ToolbarItem`, and `NavigationSplitView`. And use `@Observable` with SwiftUI to automatically detect and update only the fields of your views that people access.

SwiftUI updates

Learn about important changes to SwiftUI.

Observation

Make responsive apps that update the presentation when underlying data changes.

Backyard Birds: Building an app with SwiftData and widgets

Create an app with persistent data, interactive widgets, and an all new in-app purchase experience.

An interface, consisting of a label and additional content, that you display when the content of your app is unavailable to users.

`@preconcurrency protocol CustomAnimation : Hashable, Sendable`

A type that defines how an animatable value changes over time.

A container that animates its content by automatically cycling through a collection of phases that you provide, each defining a discrete step within an animation.

A representation of the state of the columns in a table.

A structure that computes views and disclosure groups on demand from an underlying collection of tree-structured, identified data.

`@MainActor @preconcurrency struct SectorMark`

A sector of a pie or donut chart, which shows how individual categories make up a meaningful total.

### Xcode and developer tools

With the latest Xcode release, you can verify the origin of the frameworks your app depends upon, and add metadata to your own frameworks to ensure other developers about your privacy policies. Learn to install and use on-demand simulators. Enhance your Xcode Cloud build workflows to automate packaging up your app for distribution. And the new strings catalog feature right within Xcode gives even more control over how your UI text is handled in locales around the globe.

Xcode updates

Learn about important changes to Xcode.

Downloading and installing additional Xcode components

Add more Simulator runtimes, optional features, and support for additional platforms.

Localizing and varying text with a string catalog

Use a string catalog to translate text, handle plurals, and vary the text your app displays on specific devices.

Capabilities

Enable services that Apple provides, such as In-App Purchase, Push Notifications, Apple Pay, iCloud, and many others.

Verifying the origin of your XCFrameworks

Discover who signed a framework, and take action when that changes.

Configuring your project to use mergeable libraries

Use mergeable dynamic libraries to get app launch times similar to static linking in release builds, without losing dynamically linked build times in debug builds.

Describing data use in privacy manifests

Declare the data collected by your app or by third-party SDKs.

Distributing your app for beta testing and releases

Release your app to beta testers and users.

Creating a workflow that builds your app for distribution

Configure a workflow to build and sign your app for distribution to testers with TestFlight, in the App Store, or as a notarized app.

Debugging

Identify and address issues in your app using the Xcode debugger, Xcode Organizer, Metal debugger, and Instruments.

### watchOS

Add new capabilities to your watchOS apps, and update your interface to correspond to the latest interface guidance for watchOS 10. Adopt WidgetKit features with Apple Watch-specific experiences, or use WorkoutKit to build apps that support better health.

watchOS updates

Learn about important changes to watchOS.

Updating your app and widgets for watchOS 10

Integrate SwiftUI elements and watch-specific features, and build widgets for the Smart Stack.

Designing for watchOS

When people glance at their Apple Watch, they know they can access essential information and perform simple, timely tasks whether they’re stationary or in motion.

WorkoutKit

Create, preview, and sync workout compositions to the Workout app.

### Messages apps and stickers

Give your Messages app and stickers more power than ever before, with stickers available from the keyboard picker in apps all across the system.

Messages

Create app extensions that allow users to send text, stickers, media files, and interactive messages.

Adding Sticker packs and iMessage apps to the system Stickers app, Messages camera, and FaceTime

Enable your Sticker pack or iMessage app in the media context.

`enum MSMessagesAppPresentationContext`

Presentation contexts describing where your iMessage app appears.

### UIKit

Simplify spring animations by providing duration and bounce parameters for the new view method, `animate`. Take advantage of other new UI controls and behaviors, including improvements to the presentation of `UIStatusBar` using the new default option.

UIKit updates

Learn about important changes to UIKit.

`CFBundleDocumentTypes`

The document types supported by the bundle.

Animates changes to one or more views using a spring animation with the specified duration, bounce, initial velocity, delay, options, and completion handler.

`@MainActor func viewIsAppearing(_ animated: Bool)`

Notifies the view controller that the system is adding the view controller’s view to a view hierarchy.

`struct UIContentUnavailableConfiguration`

A content configuration for a content-unavailable view.

`@MainActor var allowsKeyboardScrolling: Bool { get set }`

A Boolean value that determines whether the scroll view allows scrolling its content with hardware keyboard input.

``case `default` ``

A style that automatically selects an appearance for the status bar and updates it dynamically to maintain contrast with the content below it.

### Audio, video, and media

Build entirely new Apple TV experiences with access to the Continuity Camera, enabling video conferencing and other types of apps on the biggest screen in your home or office. Use the Cinematic framework to add support for editing movies filmed in Cinematic mode from the Camera app.

Supporting Continuity Camera in your tvOS app

Capture high-quality photos, video, and audio in your Apple TV app by connecting an iPhone or iPad as a continuity device.

Cinematic

Integrate playback and editing of assets captured in Cinematic mode into your app.

SensitiveContentAnalysis

Provide a safer experience in your app by detecting and alerting users to nudity in images and videos before displaying them onscreen.

`@MainActor class AVContinuityDevicePickerViewController`

A view controller that provides an interface to a person so they can select and connect a continuity device to the system.

### Metal

With Metal debugging and performance analysis tools, you can make your apps and games perform their best.

Metal debugger

Debug and profile your Metal workload with a GPU trace.

Metal developer workflows

Locate and fix issues related to your app’s use of the Metal API and GPU functions.

MetalFX

Boost your Metal app’s performance by upscaling lower-resolution content to save GPU time.

### Maps and location

MapKit for SwiftUI

MapKit for SwiftUI allows you to build map-centric views and apps across Apple platforms. You can design expressive and highly interactive Maps with minimal code by composing views, using ViewBuilders and view modifiers.

Monitoring location changes with Core Location

Define boundaries and act on user location updates.

Core Location

Obtain the geographic location and orientation of a device.

### App Store and distribution

StoreKit

Support In-App Purchases and interactions with the App Store.

App Store Server API

Manage your customers’ App Store transactions from your server.

App Store Server Notifications changelog

Learn about changes to the App Store Server Notifications service.

App Store Connect API Release Notes

Learn about new features and updates in the App Store Connect API.

### Security and privacy

Improve your app and website security, while protecting your user’s privacy, using the latest SDK features. Autofill password fields to easily employ passkeys, as well as saved passwords. And interact with the user’s calendar store using the `EKEventStore` API.

`@MainActor class ASCredentialProviderViewController`

A view controller that a credential manager app uses to extend AutoFill.

Accessing files from the macOS App Sandbox

Read and write documents and supporting files while maintaining security protection.

Accessing the event store

Request access to a person’s calendar data through the event store.

`enum HPKE`

A container for hybrid public key encryption (HPKE) operations.

### Extensions and XPC

Use ExtensionKit for macOS, and now for your iOS and iPadOS apps, to create extensions that expose a secure method for other apps to interact and extend your app. And a new Swift-specific API for XPC can make your code even easier to manage.

XPC updates

Learn about important changes to XPC.

`class XPCListener`

A type that performs tasks for clients across process boundaries.

`class XPCSession`

A type that sends messages to a server process.

ExtensionKit

Create executable bundles to extend the functionality of other apps by presenting a user interface.

ExtensionFoundation

Create executable bundles to extend the functionality of other apps.

### Group activities and sharing

Use a `GroupSessionJournal` object to transfer files and other data objects between participants of a shared activity.

`final class GroupSessionJournal`

An object that manages file and data transfers between participants joined in a group session.

Drawing content in a group session

Invite your friends to draw on a shared canvas while on a FaceTime call.

Group Activities

Create app-specific activities your users can share and experience together.

### Machine learning

Creating an Image Classifier Model

Train a machine learning model to classify images, and add it to your Core ML app.

VisionKit

Identify and extract information in the environment using the device’s camera, or in images that your app displays.

### Health

Use HealthKit to securely and privately store user health data on their device, with new support for iPadOS.

HealthKit updates

Learn about important changes to HealthKit.

### Apple Pay and Wallet

ProximityReader

Read contactless physical and digital wallet cards using your iPhone.

Checking IDs with the Verifier API

Read and verify mobile driver’s license information without any additional hardware.

A view that displays the Apple Pay Later visual merchandising widget.

### Hardware and virtual machines

SensorKit

Retrieve data and derived metrics from sensors on an iPhone, or paired Apple Watch.

DockKit

Interact with accessories that track subjects on camera as they move around.

Virtualization

Create virtual machines and run macOS and Linux-based operating systems.

### Screen capture

ScreenCaptureKit updates

Learn about important changes to ScreenCaptureKit.

### Symbols

Symbols

Apply universal animations to symbol-based images.

## See Also

### WWDC

Highlights of new technologies introduced at WWDC25.

Highlights of new technologies introduced at WWDC24.

Highlights of new technologies introduced at WWDC22.

Highlights of new technologies introduced at WWDC21.

---

# https://developer.apple.com/documentation/updates/wwdc2022

- Updates
- WWDC22

# WWDC22

Highlights of new technologies introduced at WWDC22.

## Overview

Browse a selection of documentation for new technologies, frameworks, and APIs introduced at WWDC22. Many existing frameworks have added significant functionality, and you’ll find new ways to enhance your apps targeting the latest platform release.

## Topics

### SwiftUI

SwiftUI

Declare the user interface and behavior for your app on every platform.

Swift Charts

Construct and customize charts on every Apple platform.

Food Truck: Building a SwiftUI multiplatform app

Create a single codebase and app target for Mac, iPad, and iPhone.

Core Transferable

Declare a transfer representation for your model types to participate in system sharing and data transfer operations.

`@frozen struct Image`

A view that displays an image.

### UIKit

Supporting desktop-class features in your iPad app

Enhance your iPad app by adding desktop-class features and document support.

Building a desktop-class iPad app

Optimize your iPad app’s user experience by adopting desktop-class enhancements for multitasking with Stage Manager, document interactions, text editing, search, and more.

`@MainActor class UIFindInteraction`

An interaction that provides text finding and replacing operations using a system find panel.

`@MainActor class UIEditMenuInteraction`

An interaction that provides edit operations using a menu.

`@MainActor var interactionActivityTrackingBaseName: String? { get set }`

The base name the view controller uses for logging signposts that annotate user interactions.

Presenting content on a connected display

Fill connected displays with additional content from your app.

TextKit

Manage text storage and perform custom layout of text-based content in your app’s views.

`class UIImage`

An object that manages image data in your app.

`@MainActor class UIPageControl`

A control that displays a horizontal series of dots, each of which corresponds to a page in the app’s document or other data-model entity.

`@MainActor class UICalendarView`

A view that displays a calendar with date-specific decorations, and provides for user selection of a single date or multiple dates.

### AppKit

AppKit

Construct and manage a graphical, event-driven user interface for your macOS app.

`@MainActor class NSComboButton`

A button with a pull-down menu and a default action.

`protocol NSPreviewRepresentableActivityItem : NSObjectProtocol`

An interface you adopt in custom objects that you want to share using the macOS share sheet.

`class NSImage`

A high-level interface for manipulating image data.

### Xcode and Developer Tools

Configuring a multiplatform app

Share project settings and code across platforms in a single app target.

Configuring requirements for merging a pull request

Protect stable branches by requiring a successful Xcode Cloud build or action before it’s possible to merge a pull request.

Documenting apps, frameworks, and packages

Create developer documentation from in-source comments, add articles with code snippets, and add tutorials for a guided learning experience.

Enabling Developer Mode on a device

Grant or deny permission for locally installed apps to run on iOS, iPadOS, visionOS, and watchOS devices.

Xcode Cloud

Automatically build, test, and distribute your apps with Xcode Cloud to verify changes and create high-quality apps.

### Swift Programming Language

Swift

Build apps using a powerful open language.

### Widgets and Complications

Creating accessory widgets and watch complications

Support accessory widgets that appear on the Lock Screen and as complications on Apple Watch.

### App Intents

App Intents

Make your app’s content and actions discoverable with system experiences like Spotlight, widgets, and the Shortcuts app.

Making actions and content discoverable and widely available

Adopt App Intents to make your app discoverable with Spotlight, controls, widgets, and the Action button.

Integrating custom data types into your intents

Provide the system with information about the types your app uses to model its data so that your intents can use those types as parameters.

App intents

Define the custom actions your app exposes to the system, and incorporate support for existing SiriKit intents.

Focus

Adjust your app’s behavior and filter incoming notifications when the current Focus changes.

### Shared with You

Shared With You

Surface shared content and collaborate in your app.

`@MainActor class SWAttributionView`

A view that displays the sender who shares a highlight and provides related actions.

`class SWHighlight`

An object that represents a universal link to share by any number of contacts in one or more conversations.

`class SWHighlightCenter`

An object that contains a priority-ordered list of universal links to share with the current user.

`protocol SWHighlightCenterDelegate : NSObjectProtocol`

The protocol you use to notify the delegate when the list or rank order of surfaced highlights changes.

### Extensions

ExtensionKit

Create executable bundles to extend the functionality of other apps by presenting a user interface.

ExtensionFoundation

Create executable bundles to extend the functionality of other apps.

### Augmented Reality

RoomPlan

Create a 3D model of a room by interactively guiding people to scan their physical environment using a device’s camera.

`class ARPlaneExtent`

The size and y-axis rotation of a detected plane.

`class ARGeoTrackingConfiguration`

A configuration that tracks locations with GPS, map data, and a device’s compass.

`var isCameraAssistanceEnabled: Bool { get set }`

A Boolean value that combines the spatial awareness of ARKit with Nearby Interaction to improve the accuracy of a nearby object’s position.

### Metal

MetalFX

Boost your Metal app’s performance by upscaling lower-resolution content to save GPU time.

Resource Loading

Load assets in your games and apps quickly by running a dedicated input/output queue alongside your GPU tasks.

`protocol MTLDevice : NSObjectProtocol, Sendable`

The main Metal interface to a GPU that apps use to draw graphics and run computations in parallel.

Creates an input/output file handle instance that represents a compressed file at a URL.

Deprecated

Creates an input/output file handle instance that represents a file at a URL.

Creates an input/output command queue you use to submit commands that load assets from the file system into GPU resources or system memory.

### Audio, Video, and Media

ShazamKit

Find information about a specific audio recording when a segment of it’s part of captured sound in the Shazam catalog or your custom catalog.

AVKit

Create user interfaces for media playback, complete with transport controls, chapter navigation, picture-in-picture support, and display of subtitles and closed captions.

AVFoundation

Work with audiovisual assets, control device cameras, process audio, and configure system audio interactions.

Creating images from a video asset

Display images for specific times within the media timeline by generating images from a video’s frames.

Loading media data asynchronously

Build responsive apps by using language-level concurrency features to efficiently load media data.

Encoding and decoding audio

Convert audio formats to efficiently manage data and quality.

`class AVAudioSequencer`

An object that plays audio from a collection of MIDI events the system organizes into music tracks.

Creating a camera extension with Core Media I/O

Build high-performance camera drivers that are secure and simple to deploy.

Overriding the default USB video class extension

Create a simple DriverKit extension to override the default driver-matching behavior for USB devices.

Capturing screen content in macOS

Stream desktop content like displays, apps, and windows by adopting screen capture in your app.

### WatchKit

`class WKBluetoothAlertRefreshBackgroundTask`

A task for handling timely Bluetooth alerts in the background.

Using background tasks

Handle scheduled update tasks in the background, and respond to background system interactions including Siri intents and incoming Bluetooth messages.

### Web and Safari

Syncing Safari web extensions across devices and platforms

Let users install your extension on one device and then use and manage the extension on all their other iOS and macOS devices.

Sending web push notifications in web apps and browsers

Update your web server and website to send push notifications that work in Safari, other browsers, and web apps, following cross-browser standards.

### Spotlight Search

Core Spotlight

Add search capabilities to your app, and index your content so people can find it from Spotlight and Safari.

### Weather

WeatherKit

Deliver weather conditions and alerts to your users.

### Live Text

Enabling Live Text interactions with images

Add a Live Text interface that enables users to perform actions with text and QR codes that appear in images.

Scanning data with the camera

Enable Live Text data scanning of text and codes that appear in the camera’s viewfinder.

### Apple Maps

MapKit

Display map or satellite imagery within your app, call out points of interest, and determine placemark information for map coordinates.

MapKit JS

Embed interactive Apple Maps on your website, annotate points of interest, and perform georelated searches.

Apple Maps Server API

Reduce API calls and conserve device power by streamlining your app’s georelated searches.

Interacting with nearby points of interest

Provide automatic search completions for a partial search query, search the map for relevant locations nearby, and retrieve details for selected points of interest.

Explore a location with a highly detailed map and Look Around

Display a richly detailed map, and use Look Around to experience an interactive view of landmarks.

### Apple Pay and Wallet

Wallet

Manage tickets, boarding passes, payment cards and other passes in the Wallet app.

PassKit (Apple Pay and Wallet)

Process Apple Pay payments in your app, and create and distribute passes for the Wallet app.

Wallet Orders

Create, distribute, and update orders in Wallet.

Apple Pay Merchant Token Management API

Retrieve and manage payment life-cycle events for your Apple Pay merchant tokens.

Apple Pay on the Web

Support Apple Pay on your website with JavaScript-based APIs.

Payment token format reference

Verify an Apple Pay payment token and validate a transaction.

### App Store and Distribution

StoreKit

Support In-App Purchases and interactions with the App Store.

App Store Server API

Manage your customers’ App Store transactions from your server.

App Store Server Notifications

Monitor In-App Purchase events in real time and learn of unreported external purchase tokens, with server notifications from the App Store.

Notary API

Submit your macOS software for notarization through a web interface.

### Security and Privacy

Supporting passkeys

Eliminate passwords for your users when they sign in to apps and websites.

Connecting to a service with passkeys

Allow users to sign in to a service without typing a password.

Public-Private Key Authentication

Register and authenticate users with passkeys and security keys, without using passwords.

Service Management

Manage startup items, launch agents, and launch daemons from within an app.

`class LARight`

A grouped set of requirements that gate access to a resource or operation.

`class LAPersistedRight`

A right that gates access to a key and a secret.

A SwiftUI view that displays an authentication interface.

`class LARightStore`

A container for data protected by a right.

### Machine Learning

Create ML Components

Create more customizable machine learning models in your app.

### Communication

Push to Talk

Display the system user interface for your app’s Push to Talk services.

### Performance Analysis

MetricKit

Aggregate and analyze per-device reports on exception and crash diagnostics and on power and performance metrics.

`class MXMetricManager`

The shared object that registers you to receive metrics, creates logs for custom metrics, and gives access to past reports.

`class MXAppLaunchDiagnostic`

A diagnostic subclass that encapsulates app launch diagnostic reports.

`class MXAppLaunchMetric`

An object representing metrics about app launch time.

### Hardware and Virtual Machines

DriverKit

Develop device drivers that run in user space.

SCSIPeripheralsDriverKit

Develop drivers for peripherals that use SCSI Block Command and Multimedia Command protocols.

DeviceDiscoveryExtension

Stream media to a third-party device that a user selects in a system menu.

Virtualization

Create virtual machines and run macOS and Linux-based operating systems.

### Photos

`class PHPhotoLibrary`

An object that manages access and changes to the user’s photo library.

A view that displays a Photos picker for choosing assets from the photo library.

Supporting Continuity Camera in your macOS app

Enable high-quality photo and video capture by using an iPhone camera as an external capture device.

### Foundation

`struct Components`

A type that represents the components of a locale, for use when creating a locale with specific overrides.

`struct LocalizedStringResource`

A reference to a localizable string, accessible from another process.

### Backgrounds Assets

Background Assets

Schedule background downloads of large assets during or after app installation, when the app updates, and periodically while the app remains on-device.

### CarKey

CarKey

Access the remote keyless features of configured vehicles in the Wallet app.

### Apple School Manager

Roster API

Read information about people and classes from an Apple School Manager organization.

## See Also

### WWDC

Highlights of new technologies introduced at WWDC25.

Highlights of new technologies introduced at WWDC24.

Highlights of new technologies introduced at WWDC23.

Highlights of new technologies introduced at WWDC21.

---

# https://developer.apple.com/documentation/updates/wwdc2021

- Updates
- WWDC21

# WWDC21

Highlights of new technologies introduced at WWDC21.

## Overview

Newer documentation highlights are available in WWDC22. This page is an archive from WWDC21.

Check out a selection of documentation for new technologies, frameworks, and APIs introduced at WWDC21. Existing frameworks have added significant functionality, and you’ll find new ways to enhance your apps targeting the latest platform release.

## Topics

### Xcode Cloud

Xcode Cloud

Automatically build, test, and distribute your apps with Xcode Cloud to verify changes and create high-quality apps.

About continuous integration and delivery with Xcode Cloud

Learn how continuous integration and delivery with Xcode Cloud helps you create high-quality apps and frameworks.

Configuring your first Xcode Cloud workflow

Set up your project or workspace to use Xcode Cloud and adopt continuous integration and delivery.

### SwiftUI

Building a Great Mac App with SwiftUI

Create engaging SwiftUI Mac apps by incorporating side bars, tables, toolbars, and several other popular user interface elements.

Add Rich Graphics to Your SwiftUI App

Make your apps stand out by adding background materials, vibrancy, custom graphics, and animations.

A view that updates according to a schedule that you provide.

A view that asynchronously loads and displays an image.

A property wrapper type that can read and write a value that SwiftUI updates as the placement of focus within the scene changes.

A container that presents rows of data arranged in one or more columns, optionally providing the ability to select one or more members.

A view type that supports immediate mode drawing.

`struct Material`

A background material type.

`](https://developer.apple.com/documentation/SwiftUI/View/swipeActions(edge:allowsFullSwipe:content:))

Adds custom swipe actions to a row in a list.

`](https://developer.apple.com/documentation/SwiftUI/View/badge(_:)-84e43)

Generates a badge for the view from a localized string key.

`](https://developer.apple.com/documentation/SwiftUI/View/searchable(text:placement:prompt:)-18a8f)

Marks this view as searchable, which configures the display of a search field.

`](https://developer.apple.com/documentation/SwiftUI/View/listRowSeparatorTint(_:edges:))

Sets the tint color associated with a row.

`](https://developer.apple.com/documentation/SwiftUI/View/previewInterfaceOrientation(_:))

Overrides the orientation of the preview.

`](https://developer.apple.com/documentation/SwiftUI/View/symbolVariant(_:))

Makes symbols within the view show a particular variant.

`](https://developer.apple.com/documentation/SwiftUI/View/symbolRenderingMode(_:))

Sets the rendering mode for symbol images within this view.

### SharePlay and Group Activities

Group Activities

Create app-specific activities your users can share and experience together.

### DocC

DocC

Produce rich API reference documentation and interactive tutorials for your app, framework, or package.

### Notifications

User Notifications

Push user-facing notifications to the user’s device from a server, or generate them locally from your app.

### WatchKit

Interacting with Bluetooth peripherals during background app refresh

Keep your complications up-to-date by reading values from a Bluetooth peripheral while your app is running in the background.

### Accessibility

Audio graphs

Define an accessible representation of your chart for VoiceOver to generate an audio graph.

Hearing device support

Access information about paired hearing aid devices and streaming status.

### Extensions

MailKit

Secure, customize, and act on email messages that users send and receive.

Safari web extensions

Create web extensions that work in Safari and other browsers.

`class EKVirtualConferenceProvider`

An object that associates virtual conferencing details with an event object in a user’s calendar.

Network Extension

Customize and extend core networking features.

### App Store

StoreKit

Support In-App Purchases and interactions with the App Store.

In-App Purchase

Offer content and services in your app across Apple platforms using a Swift-based interface.

`struct Transaction`

Information that represents the customer’s purchase of a product in your app.

App Store Connect API

Automate the tasks you perform on the Apple Developer website and in App Store Connect.

App Store Server Notifications

Monitor In-App Purchase events in real time and learn of unreported external purchase tokens, with server notifications from the App Store.

App Store Server API

Manage your customers’ App Store transactions from your server.

### Graphics

Metal

Render advanced 3D graphics and compute data in parallel with graphics processors.

Media Player

Find and play songs, audio podcasts, audio books, and more from within your app.

`class AVCaption`

An object that represents text to present over a time range.

`class AVCaptureDevice`

An object that represents a hardware or virtual capture device like a camera or microphone.

Recording and Streaming Your macOS App

Share screen recordings, or broadcast live audio and video of your app, by adding ReplayKit to your macOS apps and games.

### Audio and Haptics

MusicKit

Integrate your app with Apple Music.

AudioDriverKit

Develop drivers for audio devices.

Classifying Live Audio Input with a Built-in Sound Classifier

Detect and identify hundreds of sounds by using a trained classifier.

Core Haptics

Compose and play haptic patterns to customize your iOS app’s haptic feedback.

### Screen Time API

ManagedSettings

Access and change settings with your app while maintaining user privacy and control.

ManagedSettingsUI

Define and configure the appearance of shielding views.

DeviceActivity

Monitor device activity with your app extension while maintaining user privacy.

FamilyControls

Authorize your app to provide parental controls on a device.

### AppKit

TextKit

Manage text storage and perform custom layout of text-based content in your app’s views.

### UIKit

Catalyst

`@MainActor class UISheetPresentationController`

A presentation controller that manages the appearance and behavior of a sheet.

`struct Configuration`

A configuration that specifies the appearance and behavior of a button and its contents.

Decodes an image asynchronously and provides a new one for display in views and animations.

Creates a thumbnail image at the specified size asynchronously on a background thread.

CoreLocationUI

Streamline access to users’ location data through a standard, secure UI.

`enum UIBehavioralStyle`

Constants that indicate how a control behaves in apps built with Mac Catalyst.

`UIApplicationSupportsPrintCommand`

A Boolean value that indicates whether the app supports the Command-P keyboard shortcut.

`UIApplicationSupportsTabbedSceneCollection`

A Boolean value indicating whether an app built with Mac Catalyst supports automatic tabbing mode.

`@MainActor var subtitle: String { get set }`

A string that the app displays in the title bar of a window when running in macOS.

### Security and Privacy

Public-Private Key Authentication

Register and authenticate users with passkeys and security keys, without using passwords.

Customizing the notarization workflow

Notarize your app from the command line to handle special distribution cases.

`@MainActor class LAAuthenticationView`

A graphical representation of the state of biometric authentication.

Exposure Notification

Implement a COVID-19 exposure notification system that protects user privacy.

### iCloud

Shared Records

Share one or more records with other iCloud users.

`@NSCopying var encryptedValues: any CKRecordKeyValueSetting & Sendable { get }`

An object that manages the record’s encrypted key-value pairs.

Integrating a Text-Based Schema into Your Workflow

Define and update your schema with the CloudKit Schema Language.

### Core Data

`class NSPersistentCloudKitContainer`

A container that encapsulates the Core Data stack in your app, and mirrors select persistent stores to a CloudKit private database.

`var allowsCloudEncryption: Bool { get set }`

A Boolean value that determines whether to encrypt the attribute’s value.

`class NSCoreDataCoreSpotlightDelegate`

A set of methods that enable integration with Core Spotlight.

A property wrapper type that retrieves entities, grouped into sections, from a Core Data persistent store.

### Machine Learning

TabularData

Import, organize, and prepare a table of data to train a machine learning model.

A machine learning collection type that stores scalar values in a multidimensional array.

Applying Matte Effects to People in Images and Video

Generate image masks for people automatically by using semantic person-segmentation.

`class VNGeneratePersonSegmentationRequest`

An object that produces a matte image for a person it finds in the input image.

### Foundation

`@dynamicMemberLookup struct AttributedString`

A value type for a string with associated attributes for portions of its text.

Data Formatting

Convert numbers, dates, measurements, and other values to and from locale-aware string representations.

`struct Morphology`

A description of the grammatical properties of a string.

### Developer Tools

MetricKit

Aggregate and analyze per-device reports on exception and crash diagnostics and on power and performance metrics.

### HealthKit

`class HKVerifiableClinicalRecord`

A sample that represents the contents of a SMART Health Card or EU Digital COVID Certificate.

### HomeKit

HomeKit

Configure, control, and communicate with home automation accessories.

### Siri

SiriKit

Empower users to interact with their devices through voice, intelligent suggestions, and personalized workflows.

### Games

GameKit

Enable players to interact with friends, compare leaderboard ranks, earn achievements, and participate in multiplayer games.

Game Controller

Support hardware game controllers in your game.

### Apple Pay

`dictionary ApplePayLineItem {\\
ApplePayLineItemType type;\\
DOMString label;\\
DOMString amount;\\
ApplePayPaymentTiming paymentTiming;\\
Date recurringPaymentStartDate;\\
ApplePayRecurringPaymentDateUnit recurringPaymentIntervalUnit;\\
long recurringPaymentIntervalCount;\\
Date recurringPaymentEndDate;\\
Date deferredPaymentDate;\\
DOMString automaticReloadPaymentThresholdAmount;\\
};`

A line item in a payment request—for example, total, tax, discount, or grand total.

`supportsCouponCode`

A Boolean value that determines whether the payment sheet displays the coupon code field.

`couponCode`

The initial coupon code for the payment request.

`shippingContactEditingMode`

A value that indicates whether the shipping mode prevents the user from editing the shipping address.

`attribute EventHandler oncouponcodechanged;`

An event handler called by the system when the user enters or updates a coupon code.

A value that indicates if the shipping mode prevents the user editing the shipping address.

`interface PaymentMethodChangeEvent`

The Apple Pay extensions to the Payment Request payment change event.

`dictionary ApplePayModifier {\\
ApplePayPaymentMethodType paymentMethodType;\\
ApplePayLineItem total;\\

ApplePayAutomaticReloadPaymentRequest automaticReloadPaymentRequest;\\
ApplePayRecurringPaymentRequest recurringPaymentRequest;\\
ApplePayDeferredPaymentRequest deferredPaymentRequest;\\
};`

A dictionary that defines the Apple Pay modifiers for a payment type in the W3C Payment Request API.

Offering Apple Pay in Your App

Collect payments with iPhone and Apple Watch using Apple Pay.

`class PKDeferredPaymentSummaryItem`

An object that defines a summary item for a payment that occurs at a later date, such as a pre-order.

`class PKRecurringPaymentSummaryItem`

An object that defines a summary item for a payment that occurs repeatedly at a specified interval, such as a subscription.

`var supportsCouponCode: Bool { get set }`

`var couponCode: String? { get set }`

`protocol PKPaymentAuthorizationControllerDelegate : NSObjectProtocol`

Methods that let you respond to user interactions with your payment authorization controller.

### Hardware

Nearby Interaction

Locate and interact with nearby devices using identifiers, distance, and direction.

Hypervisor

Build virtualization solutions on top of a lightweight hypervisor, without third-party kernel extensions.

SensorKit

Retrieve data and derived metrics from sensors on an iPhone, or paired Apple Watch.

DriverKit sample code

Explore projects that demonstrate how to write macOS device drivers with the DriverKit family of frameworks.

### ShazamKit

ShazamKit

Find information about a specific audio recording when a segment of it’s part of captured sound in the Shazam catalog or your custom catalog.

### Photos

Delivering an Enhanced Privacy Experience in Your Photos App

Adopt the latest privacy enhancements to deliver advanced user-privacy controls.

Selecting Photos and Videos in iOS

Improve the user experience of finding and selecting assets by using the Photos picker.

`struct PHPickerConfiguration`

An object that contains information about how to configure a picker view controller.

### Education

`class AEAssessmentConfiguration`

Configuration information for an assessment session.

### TVUIKit

TVUIKit

Show common user interface elements from Apple TV in your native app.

### WidgetKit

Increasing the visibility of widgets in Smart Stacks

Provide contextual information and donate intents to the system to make sure your widget appears prominently in Smart Stacks.

## See Also

### WWDC

Highlights of new technologies introduced at WWDC25.

Highlights of new technologies introduced at WWDC24.

Highlights of new technologies introduced at WWDC23.

Highlights of new technologies introduced at WWDC22.

---

# https://developer.apple.com/documentation/updates/bundleresources

- Updates
- Bundle Resources updates

Article

# Bundle Resources updates

Learn about important changes to Bundle Resources.

## Overview

Browse notable changes in Bundle Resources.

## June 2025

### New entitlements

- Include passthrough in screen capture on visionOS with the `Passthrough in screen capture` entitlement.

- Enable low-latency wireless networking for streaming game content on visionOS with the `Low-Latency Streaming` entitlement.

- Manage home device electricity usage with the `com.apple.developer.energykit` entitlement.

- Access the GPU from a background task with the `Background GPU Access` entitlement.

- Opt in to additional security checks with the `Hardened Process` entitlement.

- Enable security hardening protections with the `Enhanced Security` entitlement.

- Mark memory the system uses for internal platform state as read only with the `Enable Read-Only Platform Memory` entitlement.

- Protect memory you use for pointers by opting in to type-aware memory allocation with the `Hardened Heap` entitlement.

- Opt in to additional platform restrictions with the `Additional Runtime Platform Restrictions` entitlement.

- Access subscribable or publishable Wi-Fi Aware services with the `com.apple.developer.wifi-aware` entitlement.

- Indicate that your app is optimized for a carrier-constrained network with the `com.apple.developer.networking.carrier-constrained.app-optimized` entitlement.

- Define the category in which your app accesses a carrier-constrained network with the `com.apple.developer.networking.carrier-constrained.appcategory` entitlement.

- Report the types of identity documents your app provides with the `Digital Credentials API - Mobile Document Provider` entitlement.

- Indicate that your app can be the default dialer app on someone’s device with the `Default Dialer App` entitlement.

- Obtain wireless service predictions with the `Wireless Insights Service Predictions` entitlement.

- Indicate that your app can be the default carrier messaging app on someone’s device with the `Default Carrier Messaging App` entitlement.

- Access the camera region in your visionOS app with the `Camera Region access` entitlement.

- Share a coordinate space with other devices with the `Shared Coordinate Space access` entitlement.

- Stop the system from capturing your app’s content with the `App-Protected Content` entitlement.

- Lock your app’s windows in place relative to a person with the `Follow Mode for Windows` entitlement.

- Add custom adapters to the Foundation Models framework with the `com.apple.developer.foundation-model-adapter` entitlement.

### New information property list keys

- Describe why your app tracks an accessory’s position and location with `NSAccessoryTrackingUsageDescription`.

- Indicate that the system should automatically download your asset packs and keep them up to date with `BAHasManagedAssetPacks`.

- Use Apple’s service to host your asset packs with `BAUsesAppleHosting`.

- Identify the app group that your app and extension use to share asset packs with `BAAppGroupID`.

- Describe Wi-Fi Aware services your app publishes and subscribes to with `WiFiAwareServices`.

- Indicate that your app supports game mode with `LSSupportsGameMode`.

### Updated entitlements

- Add the `com.apple.developer.kernel.increased-memory-limit` entitlement to your visionOS app.

### Updated information property list keys

- Indicate that your visionOS app supports spatial gamepads with `GCSupportedGameControllers`.

## June 2024

### New entitlements

- Enable access to a Personalized Sound Profile to allow the app to use the information in the profile to render audio with `com.apple.developer.spatial-audio.profile-access`.

- Enable access to head tracking info to allow an app to render audio with head tracking with `com.apple.developer.coremotion.head-pose`.

- Allow CoreMIDI to match MIDIDriverKit drivers with devices that support MIDI with `com.apple.developer.driverkit.family.midi`.

### Updated entitlement

- Define the app category to enable Cellular Network Slicing with `5G Network Slicing App Category`. To set the application category for streaming apps, use `streaming-9001`. You can also set the category to `gaming-6014` for gaming apps, and `communication-9000` for communication apps.

### New Info.plist keys

- Indicate if the game app bypasses system spatial audio with `AVGameBypassSystemSpatialAudio`.

- Indicate to the system that your app receives copies of re-engagement postbacks, a type of postback introduced in iOS 17.5, with `EligibleForAdAttributionKitReengagementPostbackCopies`.

- Indicate to the system that your app supports the Music Haptics feature with `MusicHapticsSupported`.

- Indicate to the system the interfaces AccessorySetupKit uses to discover and configure accessories using Bluetooth or Wi-Fi with `NSAccessorySetupSupports`.

- Provide the company identifier for a Bluetooth accessory when enabling the use of AccessorySetupKit via `NSAccessorySetupKitEnabled` with `NSAccessorySetupBluetoothCompanyIdentifiers`.

- Provide the name for a Bluetooth accessory when enabling the use of AccessorySetupKit via `NSAccessorySetupKitEnabled` with `NSAccessorySetupBluetoothNames`.

- Provide the services for a Bluetooth accessory when enabling the use of AccessorySetupKit via `NSAccessorySetupKitEnabled` with `NSAccessorySetupBluetoothServices`.

- Provide a message that tells the user why the app requests access to financial data stored in Wallet with `NSFinancialDataUsageDescription`.

- Track “finished” consumable in-app purchases in StoreKit and return the transactions when iterating the `Transaction` APIs with `SKIncludeConsumableInAppPurchaseHistory`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/browserenginekit

- Updates
- BrowserEngineKit updates

Article

# BrowserEngineKit updates

Learn about important changes in BrowserEngineKit.

## Overview

Browse notable changes in BrowserEngineKit.

## June 2025

### Text selection views

Implement text selection in the `BETextInput` protocol by using a view below the text with `selectionContainerViewBelowText` or a view above the text with `selectionContainerViewAboveText`. As optional properties, you can leave the views unspecified and implement text selection using a subview of `textInputView`.

### Extension management

Create XPC connections for an extension process with the `BEExtensionProcess` protocol `makeLibXPCConnectionError()` method. Stop an extension process with `invalidate()`.

### Interprocess rendering

Render over raw mach messaging using the `LayerHierarchyHandle` methods, `init(port:data:)` and `encode(_:)`. Similarly for `LayerHierarchyHostingTransactionCoordinator`, use the methods, `init(port:data:)` and `encode(_:)`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/callkit

- Updates
- CallKit updates

Article

# CallKit updates

Learn about important changes to CallKit.

## Overview

Browse notable changes in CallKit.

## June 2025

- Configure a call to include an option to use the system’s translation capabilities with a `CXSetTranslatingCallAction`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/contactsui

- Updates
- ContactsUI updates

Article

# ContactsUI updates

Learn about important changes to ContactsUI.

## Overview

Browse notable changes in ContactsUI.

## June 2024

### Limited access to contacts

- Check your app’s authorization status for a new value, `CNAuthorizationStatus.limited`. This represents a new status in which a person can grant your app access to a limited subset of their contacts, rather than make an all-or-nothing choice. When your app first calls `CNContactStore.requestAccess(for:completionHandler:)`, an alert asks the person using the app whether to allow contacts access at all. If they allow access, they can choose either full access or choose which contacts to allow, which appears to your app as the `.limited` authorization status. They can revise their choices later in the Settings app.

- Allow someone to quickly add more contacts to this limited-access group by displaying a `ContactAccessButton` in your app’s contact search UI. You initialize this SwiftUI view with a search substring and sets of ignored emails and phone numbers. If a single person matches this query, the button shows the contact and offers to add them to the contacts your app can access. If there are multiple matches, tapping the button shows a separate view to select contacts.

- Use the SwiftUI view modifier `contactAccessPicker(isPresented:completionHandler:)` if you want to conditionally show a full-screen picker that adds contacts to your limited-access app. The `isPresented` parameter binds to a `Bool` value, and shows the picker when the bound value becomes `true`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/corelocation

- Updates
- Core Location updates

Article

# Core Location updates

Learn about important changes to Core Location.

## Overview

Browse notable changes in Core Location.

## June 2024

- Use `CLLocationUpdate` and `CLMonitor` without needing to explicitly request or verify authorization.

- Control and defer automated user authorization flows with `CLServiceSession`.

- Asynchronously stream diagnostic properties from `CLLocationUpdate` and `CLMonitor.Event` to understand why location updates and monitor events aren’t arriving.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/coremidi

- Updates
- Core MIDI updates

Article

# Core MIDI updates

Learn about important changes to Core MIDI.

## Overview

Browse notable changes in Core MIDI.

## June 2024

### General

- Add support for v1.2 MIDI-CI Specification that supports new compatible hardware.

- Add support for v1.1.1 UMP/MIDI 2.0 Protocol Specification that introduces new message types and features.

### MIDIDriverKit

- Add support for DriverKit-based MIDI device drivers using the new MIDIDriverKit framework.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/coreml

- Updates
- Core ML updates

Article

# Core ML updates

Learn about important changes to Core ML.

## Overview

Browse notable changes in Core ML.

## June 2024

- Stitch machine learning models and manipulate model inputs and outputs using the `MLTensor` type.

- Add efficient reshaping and transposing to `MLShapedArray`.

- Add `Sendable` conformance to `MLShapedArray` and `MLShapedArraySlice`.

- Improve performance with stateful predictions. Store and load state using the `MLState` class.

- Support efficient model adaptation with multifunction ML programs.

- Reduce model size while maintaining accuracy with new compression techniques added to Core ML Tools 8.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/coremotion

- Updates
- Core Motion updates

Article

# Core Motion updates

Learn about important changes to Core Motion.

## Overview

Browse notable changes in Core Motion.

## September 2024

- Apple Watch Series 10 supports the Shallow Depth and Pressure capability. Use `CMWaterSubmersionManager` to start a shallow dive session.

## June 2024

- Use the `CMHeadphoneActivityManager` class to access motion activity from connected headphones.

- Enable connect or disconnect monitoring outside of a motion session with the `CMHeadphoneMotionManager` class. You can also use `CMHeadphoneMotionManager` to support AirPods device motion data on watchOS.

## June 2023

- Use the `CMHighFrequencyHeartRateData` class to get heart rate data, including the confidence level.

- Use the `CMOdometerData` class to get odometer data from workouts, such as speed, slope, distances, and altitude.

- Use the `CMBatchedSensorManager` class to access batches of high-frequency accelerometer and device motion data during workouts, such as a golf swing or a baseball bat swing.

- Use the `CMWaterSubmersionManager` class to monitor shallow dives on Apple Watch Ultra.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/corespotlight

- Updates
- Core Spotlight updates

Article

# Core Spotlight updates

Learn about important changes to Core Spotlight.

## Overview

Browse notable changes in Core Spotlight.

## June 2024

- Search your indexed content for items that are similar in meaning to the query string, but not necessarily a lexical match, using `CSUserQuery`. Disable this semantic search support using the `disableSemanticSearch` property of `CSUserQueryContext`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/datadetection

- Updates
- DataDetection updates

Article

# DataDetection updates

Learn about important changes in DataDetection.

## Overview

Browse notable changes in DataDetection.

## June 2025

- Scan strings for semantic entities — such as email addresses, phone numbers, URLs, and flight information — with the new Swift `DataDetector` extension to the string protocol.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/defaultapps

- Updates
- Default apps updates

Article

# Default apps updates

Learn about the latest changes to enabling your app to be the system default.

## Overview

Build apps and extensions that people can configure as the default app for many common tasks. Browse entitlements that enable your apps to declare that they can be set as the system default.

- Use `openSettingsURLString` to link directly to your app’s settings, including the Default App option, where applicable. The new `openDefaultApplicationsSettingsURLString` option in `UIKit` opens the global Default Apps settings panel.

## June 2025

### Dialing apps

- New API in LiveCommunicationKit lets users choose your app as the default for initiating cellular carrier conversations. Read Preparing your app to be the default dialer app to see how to set this up using the `Default Dialer App` entitlement. Your app has access to conversation history that happened since it became the default, and no longer requires user confirmation to initiate a connection.

### SMS, RCS, and MMS messaging apps

- The new TelephonyMessagingKit framework enables your app send SMS, RCS, and MMS messages over the cellular carrier network. Use the `Default Carrier Messaging App` entitlement to declare your app as the default handler for these carrier messages.

## 2025

### Navigation apps

- Read Preparing your app to be the default navigation app to see how to register your app to be the default responder to navigation requests for users in the European Union. This article explains how to use the `geo-navigation://` URL scheme to handle navigation queries the user initiates from other apps.

### Translation apps

- Learn about Preparing your app to be the default translation app so that your translation app can respond to user requests to perform text translation.

## 2024

### Alternative app marketplaces

Alternative app marketplace apps for iOS or iPadOS enable users to install other third-party apps in the European Union. Developers can distribute their marketplace app on the web, and users can then select the alternative marketplace as their default, if desired. Apple provides the MarketplaceKit framework that facilitates the secure installation of apps that your marketplace distributes. Read Creating an alternative app marketplace to learn how to build your own marketplace.

- Learn about the `com.apple.developer.marketplace.app-installation` entitlement used by alternative app marketplaces.

- Read Distributing your app from your website to learn how to ship the alternative app marketplace.

### Calling apps

In iOS and iPadOS 18.2 and later, a user may select an app other than the Phone or FaceTime apps to place calls. If your app places phone calls, for instance using services such as Voice over IP (VoIP), and you wish to optionally become the default calling app, see Preparing your app to be the default calling app.

### Contactless NFC and SE platform apps

iOS 18.1 introduced APIs that support secure contactless transactions within compatible iOS apps using the NFC & SE Platform for in-store payments, car keys, closed-loop transit, corporate badges, student IDs, home keys, hotel keys, merchant loyalty and rewards, and event tickets, with government IDs to be available at a later date.

The NFC & SE Platform is a secure solution developed by Apple that enables authorized developers to provide capabilities, such as securely adding, storing, and presenting a contactless card for NFC use cases, from within their iOS app. Supported NFC and SE platform apps can be selected by users as their default handler for these transactions.

- To learn more about the NFC and SE Platform see

- Manage and employ Secure Element credentials with contactless transaction capabilities using SecureElementCredential

- Enable your app to be the default app for contactless NFC and SE Platform transactions with the `com.apple.developer.secure-element-credential.default-contactless-app` entitlement.

### HCE-based contactless transactions for apps

iOS 17.4 introduced APIs that support contactless transactions for in-store payments, car keys, tickets, and more uses from within compatible iOS apps using host card emulation (HCE) in the European Economic Area (EEA).

The `CardSession` API in the CoreNFC framework enables authorized developers to perform contactless transactions from within their app. Supported `CardSession` apps can be selected by users as their default handler for these transactions.

- Learn about host card emulation apps by reading

- Use `CardSession` to enable host card emulation (HCE) transactions in your app.

- Enable your app to be the default app for HCE-based contactless NFC with the `com.apple.developer.nfc.hce.default-contactless-app` entitlement.

### Messaging apps

In iOS and iPadOS 18.2 and later, a user may select an app other than the Messages app to send instant messages. The system launches the default messaging app to handle when a user taps an `im:` link from another app. Preparing your app to be the default messaging app describes how to enable your app to optionally be selected as the default.

## 2023 and earlier

### Call Directory app extensions

Build a Call Directory app extension so a user’s device can automatically use your app to look up incoming callers, present useful caller ID information, or block unwanted callers. Read Identifying and blocking calls for more information on creating these app extensions.

- You can specify that your Call Directory app extension adds identification and blocks phone numbers in its implementation of `beginRequest(with:)`.

- To block incoming calls for a specific phone number, use the `addBlockingEntry(withNextSequentialPhoneNumber:)` method in the implementation of `beginRequest(with:)`.

### Keyboard apps

Use custom keyboard apps and extensions to replace the system keyboard for users that want different text-entry capabilities, such as a novel input method. People can choose to have this custom keyboard available systemwide, and select the default keyboard used in text fields. Read Creating a custom keyboard for information on how to build and configure your custom keyboard app and extension project.

- For more information on handling expected system behaviors in your custom keyboard, see Configuring a custom keyboard interface

### Mail apps

The system launches the default mail client whenever a user opens a `mailto:` link. Signal your app’s intent to be available as a default mail client by using the `com.apple.developer.mail-client` entitlement.

### Password, credential, and verification code apps

Password managers, verification code providers, and other secure credential apps can include a Password AutoFill app extension to enable their app to automatically fill in a name and password within Safari and other apps.

- Register the `otpauth://` or `otpauth-migration://` URL scheme within your app to enable setup of verification codes.

- Use Xcode to add a new extension target of type `AutoFill Credential Provider` to your app’s project to enable AutoFill for secure credentials throughout the system.

- For your app and app extension, use `AutoFill Credential Provider Entitlement` to ask someone for permission to fill in the credentials.

### Web browser apps

Users can select an app to be their default web browser. To make your app available as the default browser app, confirm that your app meets the requirements below, then request a managed entitlement. See Preparing your app to be the default web browser to learn more.

- In iOS 18.2 and iPadOS 18.2, the `isDefault(_:)` API allows a browser app to check if it is currently the default browser app. To reduce the likelihood that users will face continuous requests to set a browser as their default, this API will only tell the browser app if it is the default once per year.

- See Importing data exported from Safari to see how your browser app can import data the user exported from Safari.

- Use the `com.apple.developer.web-browser` entitlement to enable your app to be the default web browser.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/dockkit

- Updates
- DockKit updates

Article

# DockKit updates

Learn about important changes to DockKit.

## Overview

Browse notable changes in DockKit.

## June 2024

- Use `accessoryEvents` to acquire button events, including special ones such as shutter, flip and zoom, and custom events, along with their identifier and pressed state.

- Obtain a summary of each tracked subject. A summary consists of an identifier, face bounding box, saliency rank, speaking confidence, and looking at camera confidence.

- Pass an array of identifiers to select multiple subjects.

- Obtain information about the battery of a DockKit accessory, including battery name, battery percentage, and charging state.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/fileprovider

- Updates
- File Provider updates

Article

# File Provider updates

Learn about important changes to File Provider.

## Overview

Browse notable changes in File Provider.

## June 2024

- Offer people the ability to sync their Desktop and Documents folders with your File Provider app. Check whether a person opts in to sync these folders using `replicatedKnownFolders`. Sync the folders using `claimKnownFolders(_:localizedReason:completionHandler:)`, or stop syncing using `releaseKnownFolders(_:localizedReason:completionHandler:)` if the person opts out. Provide the system with information about which folders you support syncing through `supportedKnownFolders`, and share the locations of the folders by adopting `NSFileProviderKnownFolderSupporting`.

- Cache files on external disks. Confirm whether a volume is eligible for storing a domain using `checkDomainsCanBeStoredOnVolume(at:)`, and create a domain on that volume using the new `init(displayName:userInfo:volumeURL:)` initializer. Store data about the current sync state using `stateDirectoryURL()`, and determine whether to connect to a domain created on another device using `shouldConnectExternalDomain(completionHandler:)`.

- Install the File Provider logging profile to log helpful information for debugging and troubleshooting. Download the `.mobileconfig` file at Profiles and Logs.

## March 2024

- Improve error handling with new underlying error codes for `NSFileProviderError.Code.providerNotFound`. `NSFileProviderError.Code.providerDomainTemporarilyUnavailable` indicates that the system is unable to service requests for this domain temporarily, and you can try again later. `NSFileProviderError.Code.providerDomainNotFound` indicates that there isn’t a registered domain for the corresponding identifier. `NSFileProviderError.Code.applicationExtensionNotFound` indicates that there isn’t an app extension within the app bundle.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/financekit

- Updates
- FinanceKit updates

Article

# FinanceKit updates

Learn more about changes to FinanceKit.

## Overview

Browse notable changes in FinanceKit.

## June 2024

- Use the FinanceKit API to get access to on device financial data.

- Call `TransactionPicker()` with FinanceKitUI to display an interface with searchable user transactions.

- Query individual account balances and transactions with `AccountQuery` or track them overtime with `accountHistory()`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/foundation

- Updates
- Foundation updates

Article

# Foundation updates

Learn about important changes to Foundation.

## Overview

Browse notable changes in Foundation.

## June 2025

- Post and observe concurrency-safe notifications with new features in `NotificationCenter` that support Swift-friendly “message” types. Use `NotificationCenter.MainActorMessage` for notification messages bound to the `MainActor` and `NotificationCenter.AsyncMessage` for messages that are `Sendable`. Add an observer to one of these notification message types with the various `addObserver(of:for:using:)` methods in `NotificationCenter`. Many standard notifications in Foundation, UIKit, and AppKit now offer a message-based API, associating the message with an existing `Notification.Name`. You can also associate a message with a new name for Swift-only notifications.

- Simplify usage of `UndoManager` on the main actor, now that the undo manager is marked with `@MainActor`. The undo manager also adds a `setActionName(_:)` method that takes a `LocalizedStringResource`. Use this with the App Intents framework, which introduces a new `UndoableIntent`.

- Access your app, app extension, or framework’s bundle with the `#bundle` macro. Using the macro is more performant and convenient than using `.self` or a bundle identifier, particularly when loading localized strings with initializers that take a `bundle:` parameter. The macro back-deploys, so you can use it with projects whose deployment targets specify earlier versions of the operating system.

- Get UTF-8 and UTF-16 views of an `AttributedString` with the `utf8` and `utf16` methods of `AttributedStringProtocol`.

- Access multiple ranges of an `AttributedString` with the new `DiscontiguousAttributedSubstring` type. You can get this type from an attributed string with either a `RangeSet` of indices, or with the new `AttributedTextSelection` type.

## June 2024

### Predicates

- Use `Regex` regular expressions in predicates to perform pattern matching. You can use either the Swift regex domain specific language or traditional regex literals.

- Use the new `#Expression` macro when you want behavior similar to `#Predicate` but you need to return a type other than `Bool`.

- Create compound predicates by writing a `Predicate` that evaluates another `Predicate`.

### Calendars

- Perform `Calendar` searches by calling `dates(byMatching:startingAt:in:matchingPolicy:repeatedTimePolicy:direction:)` with `DateComponent` values specifying what to search for, and receiving a `Sequence` of matching dates. You can also repeatedly add `DateComponent` values to a date with `dates(byAdding:startingAt:in:wrappingComponents:)` and receive a sequence. To add `Calendar.Component` values instead, use `dates(byAdding:value:startingAt:in:wrappingComponents:)`.

### Format styles

- Use the `DiscreteFormatStyle` protocol to format values that constantly change, but don’t necessarily change the formatted output on every update, such as time displays that truncate the seconds field. The following format style types conform to the new protocol: `Duration.UnitsFormatStyle`, `Duration.TimeFormatStyle`, `Date.FormatStyle`, `Date.FormatStyle.Attributed`, `Date.VerbatimFormatStyle`, `Date.VerbatimFormatStyle.Attributed`, `Date.ISO8601FormatStyle`, `Duration.UnitsFormatStyle.Attributed`, and `Duration.TimeFormatStyle.Attributed`.

- Set new configuration options on `FormatStyle` to omit specific symbols from the output and suppress grouping of large time values (for example, in order to produce `10000:00` rather than `10,000:00`).

- Use the `notation` modifier on currency format styles to specify a notation such as `compactName`, similar to how `notation` already works on numeric format styles.

### Undo manager

- Provide custom information for undo actions by setting user info on `UndoManager`. The info can include things like a timestamp of the action’s creation or an icon that complements the action name.

- Reveal the size of an undo manager’s current undo or redo stack with the properties `undoCount` and `redoCount`.

### Key-Value observing

- Add a collection of shared observers to `Observable` objects that you can then add to multiple instance of the observable.

- Observables now use ARC-style weak references to their observers, preventing crashes when observers deallocate without properly removing themselves.

### Collections

- You can initialize an `IndexSet` from a Swift `RangeSet`, and vice versa.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/gamecontroller

- Updates
- Game Controller updates

Article

# Game Controller updates

Learn about important changes to Game Controller.

## Overview

Browse notable changes in Game Controller.

## June 2025

- Add support for spatial game controllers. To determine if a controller is a spatial game controller, check whether the product category is `GCProductCategorySpatialController`.

- Add support for a physical stylus with a `GCStylus` object.

- Add `NSAccessoryTrackingUsageDescription` to your information property list if your app requires access to accessory-tracking data for a spatial game controller or stylus.

- Add `GCSupportedGameControllers` to your information property list — with a value of `SpatialGamepad` — if your app supports spatial game controllers.

## June 2024

### visionOS

- For UIKit apps, add a user interaction that determines whether the system delivers game controller events through the Game Controller framework instead of the `UIResponder` chain. To receive events through the Game Controller framework, add a `GCEventInteraction` object to one or more views and set the `handledEventTypes` property to the types of events you want to handle.

## June 2023

- Use the classes that conform to the `GCDevicePhysicalInput` protocol to poll for game controller input in your game loop. For more information, see Handling input events.

- Add support for arcade sticks. To determine if a controller is an arcade stick, check whether the product category is `GCProductCategoryArcadeStick`.

- Add `GCRequiresControllerUserInteraction` to your information property list if your app requires a game controller on visionOS or to recommend a game controller on iOS.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/gamekit

- Updates
- GameKit updates

Article

# GameKit updates

Learn about important changes to GameKit.

## Overview

Browse notable changes in GameKit.

## June 2025

- Use a GameKit Configuration file in Xcode to configure Game Activities and Challenges.

- Use `GKGameActivity` to present players with ways to engage each other in your game.

- Configure challenges in Xcode or App Store Connect and use `GKChallengeDefinition` to retrieve the metadata you define.

## June 2024

### Dashboard

- Create a `GKGameCenterViewController` object using the `init(leaderboardSetID:)` initializer to display a set of leaderboards in the dashboard.

- Use the `init(player:)` initializer to display a player’s profile in the dashboard.

### Voice chat

- Use SharePlay to allow voice chat in your real-time games instead of `GKVoiceChat` which is deprecated. When you present a `GKMatchmakerViewController` object, it automatically shows a SharePlay button on iOS. To implement a custom SharePlay experience, see `GKMatchmaker`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/groupactivities

- Updates
- Group Activities updates

Article

# Group Activities updates

Learn about important changes to Group Activities.

## Overview

Browse notable changes in Group Activities.

## June 2025

- Create shared experiences for people wearing Apple Vision Pro in the same room, starting with visionOS 3. Existing SharePlay apps typically support sharing with people who are nearby but you can adopt the latest API like `ParticipantState.pose` and `isNearbyWithLocalParticipant` to create the best experience.

- Specify which scene to associate with your app’s group activity in visionOS using the `groupActivityAssociation(_:)` SwiftUI view modifier or the `GroupActivityAssociationInteraction` UIKit interaction.

## June 2024

- Customize the placement of spatial Personas in a shared activity using the `SpatialTemplate` and `SpatialTemplateElement` protocols.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/healthkit

- Updates
- HealthKit updates

Article

# HealthKit updates

Learn about important changes to HealthKit.

## Overview

Browse notable changes in HealthKit.

## June 2025

- Start workout sessions on iOS using `HKLiveWorkoutBuilder`.

- Query medications that a person has added to the Health app, using `HKUserAnnotatedMedicationQueryDescriptor` and the times they’ve logged that medication using `HKMedicationDoseEventType`.

## September 2024

- Apple Watch Series 10 supports the Shallow Depth and Pressure capability. Use `underwaterDepth` and `waterTemperature` to read depth and temperature data from shallow dives.

## June 2024

### General

- Create HealthKit apps for VisionOS.

- Associate perceived and estimated exertion values with workouts. Use `workoutEffortScore` and `estimatedWorkoutEffortScore` to read and write exertion data. Use `relateWorkoutEffortSample(_:with:activity:completion:)` to associate exertion data with a workout, and `HKWorkoutEffortRelationshipQuery` to query for associated exertion data.

- Access water temperature data from swimming workouts. Any Apple Watch Ultra records `waterTemperature` samples during swimming workouts.

- Read and write mental well-being samples using the `HKStateOfMind`, `HKPHQ9Assessment`, and `HKGAD7Assessment` data types.

- Track menstrual flow and intermenstrual bleeding during pregnancy using the `bleedingDuringPregnancy` and `bleedingAfterPregnancy` data types.

### June 2023

- Now available in iPadOS. Health data automatically synchronizes between a person’s iPhone, iPad, and Apple Watch.

- Create custom, interval-based workouts. You can use either distance or time for the intervals, and sync the intervals to a group, such as a workout class.

- Mirror workout sessions in your iOS app. This includes the ability to control the workout session from the iOS app, and the ability to send data between the iOS and watchOS apps during an active workout session.

- Access batches of higher-rate motion data from Apple Watch. New Core Motion APIs provide 800 Hz accelerometer data and 200 Hz device motion data. Use this data to analyze someone’s motion after performing an action, like swinging a golf club.

- Measure time spent outdoors and average light intensity with new data types.

- Track cycling with new data types for tracking someone’s power, speed, cadence, and functional threshold power.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/hypervisor

- Updates
- Hypervisor updates

Article

# Hypervisor updates

Learn about important changes to Hypervisor.

## Overview

Browse notable changes in Hypervisor.

## June 2025

- Support configuration of the intermediate physical address (IPA) memory granularity of a virtual machine (VM). This capability enables more efficient use of memory and allows for granularity sizes down to 4 KB, which is useful for certain specialized device drivers.

## June 2024

- Build your own VM solutions with added support for nested virtualization in Apple silicon chips, and enable a Hypervisor to run inside another VM. Nested virtualization capabilities on a Mac with Apple silicon use a new exception level (EL), EL2, which the framework enables though several new methods, including `hv_vm_config_set_el2_enabled(_:_:)`, and a number of enumeration constants that describe ARM system registers.

- Add support for virtualized ARM Generic Interrupt Controller (GIC) devices and provide an efficient mechanism to manage interrupt delivery to a virtual machine. Providing a GIC device reduces the custom code you need to write to emulate an interrupt controller.

- Add support for GIC hypervisor control system registers that GIC devices provide for nested virtualization support. Support for these registers allows hypervisors running in a virtual machine to inject interrupts to their guests.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/journalingsuggestions

- Updates
- Journaling Suggestions updates

Article

# Journaling Suggestions updates

Learn about important changes in Journaling Suggestions.

## Overview

Browse notable changes in Journaling Suggestions.

## June 2025

### iPadOS support

- Journaling Suggestions supports iPadOS. Suggestions that the system generates on a person’s iPhone sync over iCloud to their iPad.

### System notifications

- Register for system Journaling Suggestion notifications, which prompt users to reflect on recent moments. Refer to the notification schedule a person picks in Settings using `JournalingSuggestionsConfiguration`. When a person taps a notification, the system launches `JournalingSuggestionsPicker` for your app when you implement `JournalingSuggestionPresentationToken`.

### Event posters

- Receive suggestions of the `JournalingSuggestion.EventPoster` type for planned or attended events in Apple Invites.

### Location and workouts

- Distinguish work-related location suggestions using the `isWorkLocation` property, and receive information about the location from MapKit with `mapKitItemIdentifier`.

- Refer to the name of a particular workout suggestion with `localizedName`.

## June 2024

### General

- Support for landscape mode in your app.

### Motion activity

- Capture someone’s run session as well as their mixed running and walking activity sessions with `MovementType`.

### Media playback

- Describe media content a person listened to. The system provides an instance of this structure to your app when a person chooses a media suggestion in the `JournalingSuggestionsPicker`.

- Collect asset content that includes other media playback sessions from other music or podcast Apps.

### State of Mind

- Suggest content to people that ask them to describe their state of mind. The system provides an instance of this structure to your app when a person chooses a state of mind suggestion in the `JournalingSuggestionsPicker`.

### Reflection

- Use reflection prompts in your app with `Reflection`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/lightweightcoderequirements

- Updates
- LightweightCodeRequirements updates

Article

# LightweightCodeRequirements updates

Learn about important changes to LightweightCodeRequirements.

## Overview

Browse notable changes in LightweightCodeRequirements.

## June 2024

### General

- Use fields on `ValidationResult` to find out whether a code file has a valid signature, and whether the signature satisfies your lightweight code requirement.

- Combine multiple `EntitlementsQuery` constraints using the `anyOf` and `allOf` operators.

- Use the `Equatable` protocol to compare instances of `LaunchCodeRequirement`, `ProcessCodeRequirement`, and `OnDiskCodeRequirement`.

- Use `SecCodeCheckValidityWithOnDiskRequirement(code:flags:requirement:)` to test a `SecCode` instance using an on-disk code requirement.

- Use `SecCodeCheckValidityWithProcessRequirement(code:flags:requirement:)` to test a `SecCode` instance using a process code requirement.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/livecommunicationkit

- Updates
- LiveCommunicationKit updates

Article

# LiveCommunicationKit updates

Learn about important changes to LiveCommunicationKit.

## Overview

Browse notable changes in LiveCommunicationKit.

## June 2025

- Configure a conversation to include an option to use the system’s translation capabilities with a `SetTranslatingAction`.

- Prepare your app to be a default dialer app and initiate conversations with `DialRequest` and `TelephonyManager`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/mapkit

- Updates
- MapKit updates

Article

# MapKit updates

Learn about important changes to MapKit.

## Overview

Browse notable changes in MapKit.

## June 2025

- Find information about a place using `MKGeocodingRequest` and `MKReverseGeocodingRequest`.

- Get address information to use in displays, such as place cards and annotations you create using an MKMapItem, by using `MKAddress` with Search and reverse geocoding.

- Obtain formatted address strings for a place’s full address, city, or region using `MKAddressRepresentations`.

- Request cycling directions and ETAs using the `cycling` transport type.

## June 2024

- Obtain a place identifier to track a specific location, such as a business, park, physical feature, or landmark, over its lifetime.

- Show detailed information about a point of interest across MapKit, MapKit for SwiftUI, and MapKit JS.

- Filter location results using criteria such as neighborhoods, postal codes, and municipalities.

- Use pagination to obtain significantly more results over a successive set of calls when using the Apple Maps Server API.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/mapkitjs

- Updates
- MapKitJS updates

Article

# MapKitJS updates

Learn about important changes to MapKitJS.

## Overview

Browse notable changes in MapKit JS.

## June 2025

- Render Look Around views and Look Around previews that allow someone to see a street-level view of a place by using `mapkit.LookAround` and `mapkit.LookAroundPreview`.

- Request cycling directions and ETAs using the `Cycling` transport type.

## June 2024

- Obtain a place identifier to track a specific location, such as a business, park, physical feature, or landmark, over its lifetime.

- Show detailed information about a point of interest across MapKit, MapKit for SwiftUI, and MapKit JS.

- Filter location results using criteria such as neighborhoods, postal codes, and municipalities.

- Use pagination to obtain significantly more results over a successive set of calls when using the Apple Maps Server API.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/matter

- Updates
- Matter updates

Article

# Matter updates

Learn about important changes to Matter.

## Overview

Browse notable changes in Matter.

## June 2024

- Control more Matter device types, such as robot vacuums.

- Obtain the names of clusters and attributes by ID.

- Request logs for devices that support the Diagnostic Logs cluster.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/network

- Updates
- Network updates

Article

# Network updates

Learn about important changes to Network.

## Overview

Browse notable changes in Network.

## June 2024

- Add the `NSLocalNetworkUsageDescription` key to your app’s information property list to get permission to connect to services on the local network, including Bonjour services. For the key’s value, provide a string that explains why your app uses local network services.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/passkit

- Updates
- PassKit updates

Article

# PassKit updates

Learn more about changes to PassKit.

## Overview

Browse notable changes to PassKit (Apple Pay and Wallet).

## June 2024

- Use `merchantCategoryCode` to add an optional Merchant Category Code (MCC) to your payment transactions. Add this property to the `PKPaymentRequest` object to categorize the type of goods or services provided by the merchant.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/phase

- Updates
- PHASE updates

Article

# PHASE updates

Learn about important changes to PHASE.

## Overview

Browse notable changes in PHASE.

## June 2024

### AirPods head tracking

- Adjust the `PHASEListener` orientation to match someone’s head pose provided via compatible AirPods by setting the new `automaticHeadTrackingFlags` property to `orientation`. To observe this property, the system requires your app to have the `com.apple.developer.coremotion.head-pose` entitlement.

### Personalized spatial audio profile

- Tailor `PHASESource` output according to a person’s personalized spatial audio profile that they configure in Settings by adding the `com.apple.developer.spatial-audio.profile-access` entitlement to your app.

### Spatial audio toggle in Control Center

- Instruct PHASE to ignore the new system spatial audio toggle in Control Center by adding the `AVGameBypassSystemSpatialAudio` key to your app’s `Info.plist`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/photokit

- Updates
- PhotoKit updates

Article

# PhotoKit updates

Learn about important changes to PhotoKit and PhotosUI.

## Overview

Browse notable changes in PhotoKit.

## June 2024

### Spatial media

Integrate spatial media from someone’s Photos library into your app using PhotoKit and PhotosUI:

- Access a spatial media smart album by specifying the new `PHAssetCollectionSubtype.smartAlbumSpatial` value when fetching asset collections.

- Fetch and recognize spatial media assets by adding the new `PHAssetMediaSubtype` option `spatialMedia` to the fetch options predicate.

- Offer spatial media items in a `PhotosPicker` by setting the new `spatialMedia` option on the picker configuration’s filter.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/proximityreader

- Updates
- ProximityReader updates

Article

# ProximityReader updates

Learn about important changes to ProximityReader.

## Overview

Browse notable changes in ProximityReader.

## June 2024

- Display instructions to merchants on how to use Tap to Pay on iPhone using `ProximityReaderDiscovery`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/realitykit

- Updates
- RealityKit updates

Article

# RealityKit updates

Learn about important changes in RealityKit.

## Overview

Browse notable changes in RealityKit.

## June 2025

### General

- Create hover effect groups to indicate entities that need to highlight together using `HoverEffectComponent.GroupID`.

- Present popovers from volumes using `PresentationComponent`.

- Manually create instances of entities using `MeshInstancesComponent`.

- Animate entities implicitly using `animate(_:body:completion:)`.

- Create and modify attachments in a more streamlined fashion using `ViewAttachmentComponent`.

- Make entities render behind real-world objects based on depth using `EnvironmentBlendingComponent`.

- Implement post-processing effects using `RealityViewPostProcessEffect` and `PostProcessEffectContext`.

- Attach models together using `attach(_:to:)`.

- `TextureResource` now supports AVIF textures and entities you load from USDZ files that contain AVIF textures using `init(named:in:)` so they render correctly.

- Load entities from Data objects using `init(from:configurations:)`.

### Image presentation

- Generate spatial scenes using `ImagePresentationComponent.Spatial3DImage` and present them (along with 2D images and spatial photos) using `ImagePresentationComponent`.

- Receive notifications related to presenting images using `ImagePresentationEvents`.

- Use `Model3DAsset` with `Model3D` to play animations in Model3D Views.

### ARKit integration

- Receive updates about ARKit anchors directly in RealityKit using `AnchorStateEvents` and `Scene.AnchoringTrackingState`.

### SwiftUI integration

- Use SwiftUI implicit animations using the `Animation` modifier with RealityKit entities and components.

- Keep SwiftUI state in sync with RealityKit state using `Entity.Observable`.

- Present USD variants in `Model3D` using `Entity.ConfigurationCatalog`.

- Specify the frame sizing and alignment option for RealityView using `RealityViewLayoutOption`.

### Video presentation

- Play spatial video, 180°, 360°, wide-FOV APMP video, and Apple Immersive Video in `VideoPlayerComponent`.

- Retrieve the loading status when playing video using `VideoPlayerComponent` with `currentRenderingStatus`.

- Receive notifications when a video stops playing due to a comfort violation using `VideoPlayerEvents.VideoComfortMitigationDidOccur`.

### Gestures and entity interaction

- Implement six degree of freedom (6DOF) gestures for manipulating entities using `ManipulationComponent`.

- Leverage `GestureComponent` to support gestures on individual entities.

## June 2024

### General

- Add artistic lights and shadows to your visionOS app with `PointLightComponent`, `DirectionalLightComponent`, `SpotLightComponent`, and `DynamicLightShadowComponent`.

- Manage spatial tracking in your app with the `SpatialTrackingSession`.

- Use `LowLevelMesh` to efficiently bring your mesh data to RealityKit, including custom vertex attributes, formats, and layouts.

- Use an `AnimationLibraryComponent` to store associated animations with an entity that plays the animations.

- Create an `IKComponent` to animate a skeletal model with an inverse kinematics `IKComponent.Solver`.

- Use an `AudioLibraryComponent` to store associated audio with an entity that plays the audio.

- Stream generated audio in real time with `AudioGeneratorController`.

- Manage the meshes on your blend shapes with `BlendShapeWeightsComponent`.

- Create more engaging sound effects by configuring rolloff and reverb with the `SpatialAudioComponent`.

- Customize hover effects when using `HoverEffectComponent`, such as spotlight styles, highlight styles, or shader-backed hover effects for additional control over hover behaviors.

### Models and materials

- Optimize material initialization with a `CustomMaterial.Program` to compile backing shaders.

- Use `init(from:)` to efficiently update custom texture data in RealityKit, including custom pixel formats, texture types, swizzle, and texture usage.

- Create cube texture resources with `init(cubeFromEquirectangular:named:quality:faceSize:options:)` or `init(cubeFromImage:named:options:)`.

- Access additional texture resource properties: `arrayLength`, `depth`, `pixelFormat`, and `textureType`.

- Add a clearcoat to your custom materials with `clearcoatNormal`.

### Physics and simulations

- Apply force effects on rigid bodies with the `ForceEffect`.

- Create simulations such as hinge and slider joints with `PhysicsJoint`.

### Immersive environments

- Anchor dockable videos by attaching a `DockingRegionComponent` to your entity.

- Peer into other immersive worlds with a `PortalComponent`, and allow objects from that world to enter yours with `PortalCrossingComponent`.

- Further control the lighting in your environment with `EnvironmentLightingConfigurationComponent`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/safariservices

- Updates
- SafariServices updates

Article

# SafariServices updates

Learn about important changes in SafariServices.

## Overview

Browse notable changes in Safari Services.

## June 2025

### Safari settings export browsing data UI

- Web browsers can present the Export Browsing Data sheet from Safari’s settings using `SFSafariSettings` and its `openExportBrowsingDataSettings(completionHandler:)` method.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/screencapturekit

- Updates
- ScreenCaptureKit updates

Article

# ScreenCaptureKit updates

Learn about important changes to ScreenCaptureKit.

## Overview

Browse notable changes in ScreenCaptureKit.

## June 2024

### AppKit

- Share an app window with a remote viewer on demand with `requestSharingOfWindow(_ window: NSWindow, completionHandler: @escaping ((any Error)?)`. This method enables an app to share a window in response to a specific action, such as when a person clicks play in a document window, and streamlines a previously multistep window-sharing process.

- Share a preview of a window with a remote viewer on demand with `requestSharingOfWindow(usingPreview image: NSImage, title: String, completionHandler: @escaping ((any Error)?)`, which causes the framework to call a delegate method to provide the window if there’s a valid sharing session and a person confirms the offer to share.

### SwiftUI

- Create new, sharable windows using the async function `openWindow(id: String, sharingBehavior: SharingBehavior)`. This method gives presenting apps a way to share just the window they want recipients to see, even if that window takes over the entire screen and doesn’t allow access to the window picker, streamlining a previously multistep window-sharing process.

### ScreenCaptureKit

- Capture screenshots across multiple displays.

- Capture HDR content by adopting the `captureDynamicRange` property in `SCStreamConfiguration`, which allows clients to choose between ` SCCaptureModeSDR`, `SCCaptureModeHDRLocalDisplay`, and `SCCaptureModeHDRCanonicalDisplay` modes. Or use `SCStreamConfigurationPreset` to simplify the selection of properties needed for capture HDR.

- Capture microphone audio by streaming output with the `SCStreamOutputTypeMicrophone` type to a sample handler queue that the framework processes and returns audio samples in buffers to the client via the stream’s `didOutputSampleBuffer` delegate method.

- Record a stream’s screen, audio, and microphone output to a file using the `outputURL` property of `SCRecordingOutput`, which enables you to specify where the framework saves a recording file. Properties available in `SCRecordingOutputConfiguration` allow you to select the characteristics of the recording by choosing the file and codec types for the recording. The `SCRecordingOutputConfiguration` class methods enable you to enumerate the available codecs and file types ScreenCaptureKit supports.

- Start and stop recordings with two new methods on `SCStream` using `addRecordingOutput` and `removeRecordingOutput`.

- Respond to events occur during the process of recording to a file with `SCRecordingOutputDelegate`.

## June 2023

- Use the new sharing picker: `SCContentSharingPicker`.

- Access new properties of `AVCaptureDevice` for status on effects relevant to screen capture.

- Take screenshots with `SCStream`.

- Deprecated `CGStream`. Use `SCStreamConfiguration` instead.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/security

- Updates
- Security updates

Article

# Security updates

Learn about important changes to Security.

## Overview

Browse notable changes in Security.

## June 2024

- Prepare to handle errors in your app’s file access actions if your app doesn’t adopt the App Sandbox Entitlement and tries to access files in another app’s App Sandbox container. The exception to this occurs when the person using your app permits access those files.

## June 2023

- Define launch constraints to limit which apps and processes can launch your macOS apps and helper tools. For more information, see Defining launch environment and library constraints.

- Define library constraints to limit which plug-ins and dynamic libraries your macOS process can load.

- App Sandbox now associates your macOS app with its sandbox container using its code signature. The operating system asks the person using your app to grant permission if it tries to access a sandbox container associated with a different app. For more information, see Accessing files from the macOS App Sandbox.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/sensorkit

- Updates
- SensorKit updates

Article

# SensorKit updates

Learn about important changes to SensorKit.

## Overview

Browse notable changes in SensorKit.

## March 2024

### Sensors

- Use the `electrocardiogram` property to collect electrocardiogram (ECG) data samples, and the `pedometerData` class to get the data.

- Use the `photoplethysmogram` property to collect photoplethysmogram (PPG) data samples, and the `SRPhotoplethysmogramOpticalSample` and `SRPhotoplethysmogramSample` classes to get the data.

## June 2023

### Sensors

- Use the `faceMetrics` property to analyze a person’s facial expressions, and the `SRFaceMetrics` class to get the data.

- Use the `heartRate` property to collect a person’s heart rate from devices, and the `CMHighFrequencyHeartRateData` class to get the data.

- Use the `odometer` property to analyze movements during workouts, and the `CMOdometerData` class to get the data.

- Use the `siriSpeechMetrics` property to collect data about a person’s voice — such as tenor, pitch, and cadence — and the `SRSpeechMetrics` class to get the data. People who previously authorized speech metric data collection need to reauthorize before data collection can continue.

- Use the `wristTemperature` property to collect sequential wrist temperatures while a person is sleeping, and the `SRWristTemperature` class to get the data.

### Configuration

- To opt out of collecting data for user activity from sensors in your app, set the `SRResearchDataGeneration` key to `NO`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/shazamkit

- Updates
- ShazamKit updates

Article

# ShazamKit updates

Learn about important changes in ShazamKit.

## Overview

Browse notable changes in ShazamKit.

## June 2024

- Use `SHManagedSession` across threads since it now conforms to `Sendable`.

- Use the new `dataRepresentation` property in the `SHCustomCatalog` class to get the contents of a catalog.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/sirikit

- Updates
- SiriKit updates

Article

# SiriKit updates

Learn about important changes in SiriKit.

## Overview

Browse notable changes in SiriKit.

## June 2024

### System integration

- Standard intents and custom intents you create with SiriKit are automatically available to enhanced action capabilities of Siri, powered by Apple Intelligence.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/storekit

- Updates
- StoreKit updates

Article

# StoreKit updates

Learn about important changes in StoreKit.

## Overview

Browse notable changes in StoreKit.

## June 2024

### Views

- Build an in-app store with `SubscriptionStoreView` to customize the layout and appearance of subscription store views.

- Create flexible and adjustable custom control styles to use with subscription store views. Compose your custom styles using standard components with the new `SubscriptionStoreButton` and `SubscriptionStorePicker` views.

- Group subscription options into tabs or navigation destinations and create vertically compact layouts using new picker styles, which can save space for taller marketing content. Choose the placement of subscription store controls with the `subscriptionStoreControlStyle(_:placement:)` view modifier.

- Test your StoreKit view’s promotional icons, automatic subscription policies, and the subscription group display name with StoreKit Testing in Xcode.

### Win-back offers

- Configure win-back offers in the StoreKit configuration file for previously subscribed customers who canceled their subscription, and test the offers with StoreKit Testing in Xcode.

### Mac App Store offer codes

- Set up Mac App Store offer codes in the StoreKit configuration file, and test the offer code redemption sheet API using StoreKit Testing in Xcode. Offer codes for macOS are available for testing in macOS apps, including Mac Catalyst and compatible iOS apps running on macOS.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/swift

- Updates
- Swift updates

Article

# Swift updates

Learn about important changes to Swift.

## Overview

Browse notable changes in Swift. For information about Swift language changes, refer to The Swift Programming Language.

## June 2024

### Swift standard library

- Operate on noncontiguous ranges in collections using `RangeSet` and `DiscontiguousSlice`.

- Control which executor runs a task using `TaskExecutor`.

- Validate that C strings contain well-formed Unicode text when converting to them to `String` with `init(validatingCString:)` and `init(validating:as:)`.

- Preserve more information about thrown errors from `AsyncSequence` and `AsyncIteratorProtocol` using their `Failure` associated type.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/swiftcharts

- Updates
- Swift Charts updates

Article

# Swift Charts updates

Learn about important changes to Swift Charts.

## Overview

Browse notable changes in Swift Charts.

## June 2025

- Visualize data in 3D with `Chart3D`, and render bivariate functions using `SurfacePlot`. Use plot types such as `PointMark`, `RectangleMark`, and `RuleMark` that now conform to `Chart3DContent`.

## June 2024

- Plot large collections of data with greater efficiency using new plot types such as `LinePlot`, `AreaPlot`, `BarPlot`, and others that conform to `VectorizedChartContent`.

- Graph mathematical functions by passing an equation to a closure when you initialize a `LinePlot` or `AreaPlot`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/swiftdata

- Updates
- SwiftData updates

Article

# SwiftData updates

Learn about important changes to SwiftData.

## Overview

Browse notable changes in SwiftData.

## June 2025

- Increase the flexibility of your models by adopting inheritance through the `Model()` macro.

- Gain added flexibility in accessing and sorting transaction history using `sortBy` in the `HistoryDescriptor`.

## June 2024

### Macros

- Improve performance of sorts and predicate-based fetches by using the `Index(_:)` macro to define individual and compound indexes.

- Define a unique constraint that includes one or more model attributes using the `Unique(_:)` macro, enabling SwiftData to regard tuples of attributes as unique.

- Specify `nil` as a relationship’s `inverse` to create a unidirectional relationship.

### Persistent history

- Fetch historical changes for one or more persistent models using the model context’s `fetchHistory(_:)` method.

- Delete stale model history from a persistent store by calling the context’s `deleteHistory(_:)` method.

- Provide an alternate change tracking strategy for your custom persistent store by adopting the `HistoryProviding` protocol.

### Custom persistent stores

- Adopt the `DataStore` protocol (and related protocols) to provide custom storage for your app’s persistent models.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/symbols

- Updates
- Symbols updates

Article

# Symbols updates

Learn about important changes to Symbols.

## Overview

Browse notable changes in Symbols.

## June 2024

- Make symbols even more expressive with new animations. Find new ways to respond to people’s input, convey status changes, and signal ongoing activity with `WiggleSymbolEffect`, `RotateSymbolEffect`, and `BreatheSymbolEffect`.

- Allow symbols to more intelligently transition between related variants with `magic(fallback:)`. Slashes can now draw on and off, and badges can appear and disappear, or be replaced independently of the base symbol.

- Use `repeat(_:)` for new playback options for repeating animations. Apply a delay between repetitions, and use new, continuous repeat behavior with `continuous` to produce smoother animations when repeating indefinitely.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/tipkit

- Updates
- TipKit updates

Article

# TipKit updates

Learn about important changes in TipKit.

## Overview

Browse notable changes in TipKit.

## June 2024

### General

- Synchronize tips, rules, parameters, and events across people’s devices with the new CloudKit configuration using the `Tips.ConfigurationOption`.

- Invalidate tips after they display for a specified duration using the new `MaxDisplayDuration` property.

- Customize the layout and style of your tips by creating a custom `TipViewStyle`.

- Display your tips sequentially or in a specific order with a `TipSequence` object.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/threadnetwork

- Updates
- ThreadNetwork updates

Article

# ThreadNetwork updates

Learn about important changes in ThreadNetwork.

## Overview

Browse notable changes in ThreadNetwork.

## June 2025

### General

- Learn how to get started with Thread development, testing, and certification. For more information, see Getting started with ThreadNetwork.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/uikit

- Updates
- UIKit updates

Article

# UIKit updates

Learn about important changes to UIKit.

## Overview

Browse notable changes in UIKit.

## June 2025

### General

- Provide seamless immersive visuals by using `UIBackgroundExtensionView` to extend a view’s content under sidebars and inspectors.

- Apply Liquid Glass effects to views using `UIGlassEffect`.

- Organize views together for morph animations in `UIGlassContainerEffect`.

- Add or adjust effects at the edge of a scroll view with `UIScrollEdgeEffect`.

- Apply Liquid Glass effects to buttons with `glass()` and `prominentGlass()`.

- UIKit now supports Swift Observable objects. Use observable objects in `layoutSubviews()`; then UIKit automatically invalidates and updates the UI when those objects change.

- Add a badge to a `UIBarButtonItem` with `badge`.

- Notification payloads are now strongly typed: `NotificationCenter.MessageIdentifier`.

### Menu bar in iPadOS

- Swipe from the top to reveal an iPad app’s full menu. Menus on iPad support images, submenus, inline sections, checkmarks, and more.

- Configure main menus with `UIMainMenuSystem`.

### High dynamic range (HDR)

- `UIColorPickerViewController` supports picking HDR colors, with a maximum supported exposure value.

- Observe `UITraitHDRHeadroomUsageLimit` to automatically adjust HDR usage when a view with HDR content is not in focus.

## June 2024

### General

- Leverage automatic trait usage tracking inside key update methods such as `layoutSubviews()`, eliminating the need for manual trait change registration and invalidation.

- Add repeat, wiggle, breathe, and rotate effects to SF Symbols.

- Take advantage of enhancements to `UIListContentConfiguration`, which now automatically updates to match the style of the containing list by using the new `UIListEnvironment` trait from the trait collection, removing the need to instantiate a configuration for a specific list style yourself.

- Opt out or restrict collaboration on certain types of data through the share sheet using `UIActivityCollaborationMode`.

- Select a specific week of the year in `UICalendarView` using the new `UICalendarSelectionWeekOfYear` selection option.

- Observe, participate in, and affect the UI update process using `UIUpdateLink`.

### Navigation

- Showcase your app and its unique identity with a new, customizable launch design for document-based apps. In UIKit, define `launchOptions` on your `UIDocumentViewController`.

- Make your app’s navigation more immersive by adopting the new tab bar on iPad. If your app presents a rich hierarchy of tab items, set the `mode` to `UITabBarController.Mode.tabSidebar` to automatically switch between the tab bar and sidebar representations. In SwiftUI, use `sidebarAdaptable`.

- Transition between views in a way that feels fluid and consistent using a systemwide zoom transition. In UIKit, configure your view controller’s `preferredTransition` to `zoom(options:sourceViewProvider:)`. In SwiftUI, use `zoom(sourceID:in:)`.

### Framework interoperability

- Reuse existing UIKit gesture recognizer code in SwiftUI. In SwiftUI, create UIKit gesture recognizers using `UIGestureRecognizerRepresentable`. In UIKit, refer to SwiftUI gestures by name using `name`.

### visionOS

- Support more varieties of list layouts by configuring whether section headers stretch to fill the entire width of the list or shrink to tightly hug their content. For collection views, use `contentHuggingElements` on `UICollectionLayoutListConfiguration`. For table views, use `contentHuggingElements` on `UITableView`.

- Animate SF Symbols on visionOS using the symbol effects API and `UIImageView`.

- Apply hierarchical vibrant text color to labels using `UIColor.Prominence`.

- Specify an action to perform without shifting the focus away from the keyboard using `keyboardAction`.

- Push a new scene in place of an existing scene using `UIWindowScenePushPlacement`. The new scene appears in the same position as the original scene, hiding it. Closing the new scene makes the original scene reappear.

### tvOS

- Create a unifying color theme in your app by specifying an accent color in your app’s asset catalog, which is now supported in tvOS.

## June 2023

### General

- Preview your views and view controllers alongside your code using the new `#Preview` Swift macro.

- Take advantage of a new view controller appearance callback, `viewIsAppearing(_:)`, to run code that depends on the view’s initial geometry. The system calls this method when both the view and view controller have an up-to-date trait collection, and after the superview adds the view to the hierarchy and lays it out. This method deploys .

- Display and manage empty state consistently in your app with `UIContentUnavailableConfiguration`, which provides new system standard styles and layouts for common empty states. Help people understand why no content is present, and when possible, provide guidance on how to add content.

- Create a powerful text experience in your app. Define richer interactions by changing the default tap or menu behavior when interacting with a text item. If you implement a custom UI for displaying text, support the redesigned text cursor by adopting the new text selection UI. Mark up text fields with additional text content types to help people fill out forms even faster. For more information, see WWDC23 session 10058: What’s new with text and text interactions.

- Let people drop supported files and content onto your app icon on the Home Screen to open them in your app. To make sure your app is properly configured, verify that your `Info.plist` file specifies the file types your app supports using `CFBundleDocumentTypes`.

### Accessibility and internationalization

- Simplify how you maintain your accessibility code with block-based setters for accessibility attributes. Make sure people receive the most important information first by specifying a default, low, or high priority for announcements. Enhance custom accessibility elements with the new toggle and zoom accessibility traits.

- Create a great text experience for international users by testing your UI in all languages. Adopt text styles to take advantage of enhancements to the font system, like improved wrapping and hyphenation for Chinese, German, Japanese, and Korean, as well as enhancements for variable line heights that improve legibility in several languages, including Arabic, Hindi, Thai, and Vietnamese. Access localized variants of symbol images by specifying a locale.

### iPadOS

- Help people customize their Stage Manager configuration by including a larger target area for dragging windows. Leverage new resizing behavior for split view controllers to get the most out of your UI in Stage Manager.

- Support scrolling of your scroll view content with hardware keyboard shortcuts. This behavior is enabled by default, which you can override using `allowsKeyboardScrolling`.

- Simplify document management in your document-centric apps. Set your `UIDocument` subclass as the rename delegate of a navigation item to handle file renaming automatically. Build your content view controller from `UIDocumentViewController`, which provides a system default experience for managing documents: automatically configuring the title menu, sharing, drag and drop, key commands, and more. For more information, see WWDC23 session 10056: Build better document-centric apps.

- Enhance the Apple Pencil experience in your iPadOS app. Give your app a sense of depth by using `UIHoverGestureRecognizer` to draw a preview of the stroke. Support the beautiful new inks in PencilKit, including monoline, fountain pen, watercolor, and crayon.

### Views and controls

- Animate symbol images with new symbol effects, including bounce, pulse, variable color, scale, appear, disappear, and replace.

- Build even more performant apps with flexible layouts using collection views. Apply diffable data source snapshots and perform batch updates with even better performance. Use the `uniformAcrossSiblings(estimate:)` dimension for compositional layouts to specify uniform size across sibling items, with smaller items increasing in size to match their largest sibling.

- Simplify spring animations by providing duration and bounce parameters for the new view animation method, `animate(springDuration:bounce:initialSpringVelocity:delay:options:animations:completion:)`.

- Represent fractional progress through a page of content with page controls.

- Display and manipulate high dynamic range (HDR) images.

- Display your menu as a palette with `displayAsPalette` for it to appear as a row of menu elements for choosing from a collection of items.

- Take advantage of the `UIStatusBarStyle.default` status bar style, which now automatically chooses a light or dark appearance that maintains contrast with the content underneath it.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/usernotifications

- Updates
- User Notifications updates

Article

# User Notifications updates

Learn about important changes in User Notifications.

## Overview

Browse notable changes in User Notifications.

## June 2024

### General

- Use an offline queue store to store multiple notifications per bundle ID when a device is inactive.

- Enable multiple pushes on the server side using the `apns-collapse-id` header field.

- Use broadcast capabilities to send Live Activity updates to people that subscribe to your channel.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/videosubscriberaccount

- Updates
- Video Subscriber Account updates

Article

# Video Subscriber Account updates

Learn about important changes in Video Subscriber Account.

## Overview

Browse notable changes in Video Subscriber Account.

## June 2025

### Automatic Sign-In

- Implement single sign-on for media-streaming apps by managing a sign-in token on a person’s Apple Account. For more information, see Signing people in to their media accounts automatically.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/virtualization

- Updates
- Virtualization updates

Article

# Virtualization updates

Learn about important changes to Virtualization.

## Overview

Browse notable changes in Virtualization.

## June 2025

- Take advantage of more efficient storage utilization in virtual machine (VM) images using the Apple Sparse Image Format (ASIF). Its space-saving allocation results in a smaller disk footprint and optimized transfer for VM disk images with `VZDiskImageStorageDeviceAttachment`.

- Support vmnet custom network topologies to enable VM-to-VM communications based on a logical network with customized configuration.

- Easily discover a VM’s on-process `queue` using this new property on `VZVirtualMachine`.

- Access rights-protected content in VMs and add support for DRM content in macOS VMs.

## June 2024

- Adopt nested VMs to run Linux VMs in virtualized Linux VM hosts.

- Allow emulated USB Mass Storage devices to attach to and detach from a running VM using Extensible Host Controller Interface (XHCI) controller hot-plug capabilities.

- Access iCloud from macOS 15 VMs.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/vision

- Updates
- Vision updates

Article

# Vision updates

Learn about important changes in Vision.

## Overview

Browse notable changes in Vision.

## June 2025

- Use `DetectLensSmudgeRequest` and `SmudgeObservation` to detect a smudge with a confidence level in an image or video frame capture.

- Use `RecognizeDocumentsRequest` and `DocumentObservation` to scan a document and recieve detailed information about its structure and content.

## June 2024

- Use the new Swift-only API that follows best design practices in Swift and leverages modern language features like Swift concurrency for optimal performance.

- Analyze an image for aesthetically pleasing attributes by using `CalculateImageAestheticsScoresRequest` and provides a score through `ImageAestheticsScoresObservation`. The score indicates whether an image contains memorable or exciting content.

- Use `DetectHumanBodyPoseRequest` to detect hands along side the 2D body joint skeleton.

- Use `DetectHumanBodyPoseRequest.Revision.revision2` to improve 2D human body pose detection.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/watchos

- Updates
- watchOS updates

Article

# watchOS updates

Learn about important changes to watchOS.

## Overview

Browse notable changes in watchOS apps.

## September 2024

### Watch sizes

- Apple Watch Series 10 are larger and have a different aspect ratio than previous watches. The watch is 1mm larger than the Series 9 (42mm and 46mm), but the screen gains more width than height. Use `scenePadding(_:)` to align text with the text margins, and `ignoresSafeArea(_:edges:)` to extend content beyond the watch’s safe area.

### Shallow dives

- Apple Watch Series 10 supports the Shallow Depth and Pressure capability. Use `CMWaterSubmersionManager` to start a shallow dive session, and `underwaterDepth` and `waterTemperature` to read depth and temperature samples from HealthKit.

## June 2024

### Water temperature

- Access water temperature data from swimming workouts. Apple Watch Ultra records `waterTemperature` samples during swimming workouts.

### Double tap

- Specify which control responds to the double tap gesture using the `handGestureShortcut(_:isEnabled:)` view modifier, passing `primaryAction` as the parameter. Double tap can interact with any buttonlike controls, such as buttons or toggles.

### Creating workouts

- Create custom pool swimming workouts with the `HKWorkoutActivityType.swimming` activity.

- Set a distance-with-time goal for custom swimming workouts with the `WorkoutGoal.poolSwimDistanceWithTime(_:_:)` goal.

- Provide a custom name to a workout step using the `WorkoutStep` structure’s `displayName`.

- Preview workouts on Apple Watch using the `workoutPreview(_:isPresented:)` view modifier.

- Set average power goals for cycling and running with `PowerThresholdAlert` and `PowerRangeAlert`.

- Set pace goals for indoor running with the `SpeedThresholdAlert` and `SpeedRangeAlert` targets.

## September 2023

- When someone performs a Double Tap gesture while viewing a notification on Apple Watch Series 9 or Apple Watch Ultra 2, the system invokes the first nondestructive action. A nondestructive action doesn’t include the `destructive` option, and won’t delete user data or change the app irrevocably.

## June 2023

- Use the new watchOS user interface design to simplify navigation, better use the Digital Crown, and enrich the app experience. For more information, see Designing for watchOS and Creating an intuitive and effective UI in watchOS 10.

- Update your WidgetKit-based complications to take advantage of the Smart Stack on Apple Watch. People can scroll down to see relevant widgets directly on the watch face using the Digital Crown. For more information, see Increasing the visibility of widgets in Smart Stacks.

- Use curved text along the bevel or around the corners in WidgetKit-based complications.

- Add state preservation and restoration to watchOS apps. For more information, see Preserving your app’s UI across launches.

- Use WorkoutKit to create goal, pacer, multisport, and fully custom interval workouts. Display a preview of the workout that shows the workout details, and sync workouts with a paired Apple Watch. For more information, see WorkoutKit.

- Access batches of high-frequency accelerometer and device motion data during workouts. Use this data to analyze motion — such as a golf or baseball swing — after the action occurs. For more information, see Core Motion.

- Use Core Motion’s water submersion manager to monitor shallow dives on Apple Watch Ultra. For more information, see Core Motion.

- Support Bluetooth cycling sensors. People can pair power, cadence, and speed sensors to Apple Watch to enhance their cycling workouts. You can access this data using HealthKit for live and historical workouts.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/weatherkit

- Updates
- WeatherKit updates

Article

# WeatherKit updates

Learn about important changes to WeatherKit.

## Overview

Browse notable changes in WeatherKit.

## June 2024

- Benefit from efficient transfers with FlatBuffers.

- Obtain hourly, daily, and monthly weather statistics for a particular location based on over 50 years of historical weather data.

- Obtain a daily summary of high temperature, low temperature, precipitation amount, and snowfall amount for a specific day since August 2021.

- Get a list of upcoming significant weather changes for the following elements: high temperature, low temperature, day precipitation amount, and night precipitation amount.

- Access a new property for the current weather: `cloudCoverByAltitude`.

- Access new elements for the current day’s weather:

- `highTemperatureTime` and `lowTemperatureTime`

- `minimumHumidity` and `maximumHumidity`

- `minimumVisibility` and `maximumVisibility`

- `highWindSpeed`

- `precipitationAmountByType`

- `daytimeForecast`, `overnightForecast`, and `restOfDayForecast`
- Get forecasts for part of the day with `DayPartForecast`.

- Get hourly cloud cover by altitude with `CloudCoverByAltitude`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/widgetkit

- Updates
- WidgetKit updates

Article

# WidgetKit updates

Learn about important changes in WidgetKit.

## Overview

Browse notable changes in WidgetKit.

## June 2025

### General

- Support Liquid Glass by using the `WidgetAccentedRenderingMode`.

- Use WidgetKit push notifications to request timeline reloads from the system by registering a `WidgetPushHandler`.

- Update your `WidgetFamily.systemSmall` widget to make sure it appears correctly in CarPlay.

- Create controls that use `ControlWidgetButton` to execute an action and `ControlWidgetToggle` to toggle some state in your app in watchOS and macOS.

### Vision Pro

- Widgets are available on Apple Vision Pro. Support `elevated` and `recessed` mounting styles, choose `glass` or `paper` textures, and specify layouts for each `LevelOfDetail` to show more ore less information based on a person’s proximity.

### Apple Watch

- Offer a relevance-based watchOS widget that uses a `RelevanceConfiguration`.

- Let people configure your watchOS widget by offering a widget that uses `AppIntentConfiguration`.

## June 2024

### General

- Controls allow people to customize and configure Control Center, their Lock Screen, and the Action button with actions from your apps. Take advantage of `ControlWidgetButton` to execute an action and `ControlWidgetToggle` to toggle some state in your app.

- Accent views of widgets on iOS and iPadOS using `widgetAccentable(_:)`.

### Apple Watch

- Create interactive widgets on watchOS using a `Button` or `Toggle` to perform actions without launching your app.

- Use an `AccessoryWidgetGroup` container to provide up to three content views, optionally interactive, in a watchOS widget. Style `AccessoryWidgetGroup` content views using `circular` or `roundedSquare`.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/workoutkit

- Updates
- WorkoutKit updates

Article

# WorkoutKit updates

Learn about important changes to WorkoutKit.

## Overview

Browse notable changes in WorkoutKit.

## June 2024

### Custom swim workouts

- Create custom pool swimming workouts with the `HKWorkoutActivityType.swimming` activity.

- Set a distance-with-time goal for custom swimming workouts with the `WorkoutGoal.poolSwimDistanceWithTime(_:_:)` goal.

### General

- Provide a custom name to a workout step using the `WorkoutStep` structure’s `displayName`.

- Preview workouts on Apple Watch using the `workoutPreview(_:isPresented:)` view modifier.

- Set average power goals for cycling and running with `PowerThresholdAlert` and `PowerRangeAlert`.

- Set pace goals for indoor running with the `SpeedThresholdAlert` and `SpeedRangeAlert` targets.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/xcode

- Updates
- Xcode updates

Article

# Xcode updates

Learn about important changes to Xcode.

## Overview

Browse notable changes in Xcode.

## June 2025

The latest version of Xcode includes the following new features.

### Optimizations

- Download components, such as Metal toolchains and Simulator runtimes, only when Xcode detects that you need them. For more information, see Downloading and installing additional Xcode components.

- Download smaller Simulator runtimes that no longer contain Intel-based Mac support by default.

### Workspace and editing

- In the source editor, add as many tabs as you want, and pin files to a tab.

- Find clusters of words across files in your project using the Multiple Words search option in the Find navigator. Enter a set of words and Xcode finds the clusters in proximity to each other across your files, sorting the occurrences by relevance.

- Use Voice Control to instruct Xcode and write Swift code. Voice Control understands Swift syntax, adds spaces where needed, and enters expressions correctly.

- Use Icon Composer to create a single file representation of your app icon for iOS, iPadOS, macOS, and watchOS. Take full advantage of the new material and appearances on these platforms. For more information, see Creating your app icon using Icon Composer.

### Intelligence

- Use a coding assistant to explain, write, and fix Swift code for you from prompts and project files in Xcode. You can configure models in the Intelligence settings and switch between them in the coding assistant. For more information, see Writing code with intelligence in Xcode.

- Use the playground macro to quickly iterate on code snippets directly in Xcode and display the live execution results in a canvas tab. Ask the coding assistant to generate playgrounds for you about symbols in your project. For more information, see Running code snippets using the playground macro.

- In the source editor, use the Coding Tools popover for common actions to selected code, such as explain, document, and generate a preview or playground. Enter a prompt about the code in the text field.

- When using code completion in the source editor, click the disclosure triangle to select one of multiple signatures for a base method.

- For issues and warnings that appear in the Issue navigator and source editor, such as deprecation warnings, click the Generate button in the Fix-It popover to let the coding assistant fix it for you.

### String catalogs

- Add localized strings to string catalogs and access them in code using type-safe Swift symbols that also appear in code completion.

- Let Xcode use on-device models to generate comments for localized strings in your code that assist translators.

### Debugging and performance

- When debugging Swift concurrency code, step into or out of an `await` call to follow a task onto a new thread.

- Add a missing usage description key to your project directly from the debugger when your app stops abruptly because it accesses a private resource without the person’s permission. The debugger takes you to the Signing & Capabilities pane where you can edit all the usage description keys in one place.

- Use the SwiftUI template in Instruments to find long-running view body updates and other performance issues in your SwiftUI views. For more information, see Understanding and improving SwiftUI performance.

- Identify situations where your app causes a device to consume high amounts of energy with the Power Profiler instrument. For more information, see Measuring your app’s power use with Power Profiler.

- Discover and analyze situations where your app doesn’t use the processor at highest effectiveness with the CPU Counters instrument.

### Organizer

- Compare your apps metrics with recommended values in the Metrics Organizer. For more information, see Analyzing the performance of your shipping app.

- Prioritize performance work by identifying trending insights in the Metrics Organizer.

### Security

- Adopt Enhanced Security in your apps and extensions to take advantage of compiler and runtime capabilities that can help to address some security issues. For more information, see Enabling enhanced security for your app.

### Testing

- Use the improved UI automation recording feature to build UI tests for your app. For more information, see Recording UI automation for testing.

- Use Thread Performance Checker to detect situations where your tests use main-thread-only APIs on background threads or where your tests create background tasks that depend on tasks with lower quality of service.

## June 2024

Xcode 16 includes SDKs for iOS 18, iPadOS 18, macOS 15, tvOS 18, and watchOS 11, and the following new features.

### Source Editor

- Leverage the new predictive code completion engine, which predicts the code you need. Powered by a unique model specifically trained for Swift and Apple SDKs, code completion now takes context such as function names and comments into account to provide more thorough code suggestions.

- Match user input to the best action more accurately with Improved Quick Actions.

- Leverage the repeat command with Vim key bindings.

### Swift

- Enable strict concurrency in Swift 6 to check for the risk of data races at compile time.

### Testing

- Write your unit tests using Swift Testing and get richer output and more actionable test results. Take advantage of its new features, such as parameterized testing, to create more tests cases with less code, annotate tests, and modify runtime behaviors.

- Generate test plans in the Test Plan Editor based on the tags you define and attach to the test you write using Swift Testing.

- Gain insights into device and tag specific failure patterns in the tests results when testing across multiple configurations and run destinations. Xcode displays these insights in the Report navigator in Xcode under the Insights section of a Test Report.

- Export video, still frames, or screenshots from the details of a Test Report under the Reports navigator in Xcode.

### Previews

- Iterate designs quickly with the improved SwiftUI preview. Leverage new preview APIs for declaring state and reusing data across previews.

### Asset management

- Add new Dark and Tinted app icons for iOS.

### Devices and simulator

- Test FaceTime and SharePlay experiences for visionOS using the upgraded Xcode simulator.

### Performance and metrics

- Identify areas of launch time improvement. Discover where your iOS app spends its time at launch with the launch diagnostics that come with Xcode Organizer.

- Use signature trend insights to understand how the impact of disk usage issues changes over time for your iOS app.

- Surface runtime issues for launch time, hang rate, and disk usage with the Thread performance checker.

- Leverage the Flame Graph feature in Instruments to better visualize performance hotspots in your app.

### Debugging

- Reduce the size of your `.dSYM` bundles and allow for faster lookups by adapting the DWARF5 default symbol debugging format.

- Visualize a threads backtrace interactively in the source editor using the new Unified Backtrace view in Xcode Debugger. You can view the source code corresponding to each frame from the backtrace in a single editor tab, along with program counter annotations and data tips for local variables that have values available in each frame.

- Interactively debug crash logs in LLDB with or without the existence of a local copy of the corresponding Xcode project file and source code. You can supply Xcode with matching symbol-rich executables or dSYM files to create a readable version of the contents of the crash log. These files can then load into a crash debugging session using the “Load Symbols” contextual menu item in the debug navigator.

- Inspect properties and get a snapshot of your running app’s entity hierarchy with RealityKit debugger.

- Leverage the `@DebugDescription` macro to convert compatible Swift `debugDescription` properties into LLDB type summaries.

- Debug devices remotely from the command line in LLDB with the `device` command.

### Projects and workspaces

- Leverage the New Empty File feature from the Project Navigator’s context menu to quickly create a new Swift file without any confirmation dialogs.

- Leverage the Copy, Paste, and Duplicate feature from the Edit menu to create a new file from an existing file.

- Cut text from the Source Editor, and then use the New File from Clipboard command while holding the option key in the Project Navigator’s context menu to quickly extract part of a source file into a new file.

- Minimize project file changes and avoid conflicts with buildable folder references. Convert an existing group to a buildable folder with the Convert to Folder context menu item in the Project Navigator. Buildable folders only record the folder path into the project file without enumerating the contained files, minimizing diffs to the project when your team adds or removes files, and avoiding source control conflicts. To use a folder as an opaque copiable resource, the default behavior before Xcode 16, uncheck the Build Folder Contents option in the File Inspector.

- Create groups with associated folders by default when using the New Group and New Group from Selection commands in the Project Navigator. To create a group without a folder, hold the Option key in the context menu to reveal the New Group without Folder variant of the command.

### Xcode Cloud

- Define custom aliases to set up and manage centralized Xcode and macOS configurations, and apply them across multiple workflows.

- View coverage data from test runs in Xcode Cloud by opening the build report under the Reports navigator in Xcode and navigating to Coverage.

- Configure webhooks that connect Xcode Cloud to other services and tools.

### StoreKit testing in Xcode

- Configure app policies, such as user license agreements and localized privacy policies, to display in StoreKit views using the `StoreKit.configuration` file.

- Configure win-back offers in the `StoreKit.configuration` file to test win-back offers for autorenewable subscriptions.

### Localization

- Use new features in the string catalog, such as inline diagnostics and the ability to mark strings as not to be translated, and jump between source code and translations for improved localization workflows.

### Build system

- Discover improved parallelism, more detailed compile time error messages, and improved debugger performance with explicit modules.

- Enable low-overhead security-critical checks at runtime with the hardened C++ standard library.

### Documentation

- Create documentation links to on-page headings and topic sections.

- Combine overloaded methods by adding `--enable-experimental-overloaded-symbol-presentation` to “Other DocC Flags” ( `OTHER_DOCC_FLAGS`).

- Separate content using a horizontal rule by adding `---` or `***` in a line.

## June 2023

Xcode 15 includes SDKs for iOS 17, iPadOS 17, macOS 14, tvOS 17, and watchOS 10, and the following new features.

### Xcode IDE

- Install just the platforms you need. Platform runtimes are separated into individual installations. Select the platforms you develop for when you download Xcode from the developer website or when you launch Xcode for the first time. You can add or remove platform runtimes at any time. See Downloading and installing additional Xcode components.

- Access and configure capabilities granted for your team through App Store Connect right in your Xcode project settings. See Capabilities.

- Use the new Integrate menu to stage and commit source code repository changes, and to create and manage your Xcode Cloud workflows.

- Generate privacy reports for app archives based on privacy manifests in your app and third-party SDKs your app links to. See Describing data use in privacy manifests.

- Verify the code signature of XCFrameworks in your project. The Xcode build system fails with an error if the signature changes or is removed. See Verifying the origin of your XCFrameworks.

### Code

- Use code completion more effectively. Xcode uses more sources of input for code completion, prioritizes completions based on context, and improves the display of parameter options.

- View the expanded form of your Swift macros in the source editor, and set breakpoints in code that a macro generates. For more information about Swift macros, see Applying Macros.

- Create bookmarks for lines of code and saved queries. Create to-do lists by organizing bookmarks into groups, and mark items complete as you address them.

- View and stage changes in the gallery view in the source editor.

- Validate the ability to link with modules at build time. Module verification is enabled by default, but you can enable and disable verification by setting `Enable Module Verifier` in build settings. See Build settings reference.

- Use mergeable dynamic libraries to get app launch times similar to static linking in release builds, without losing dynamically linked build times in debug builds. See Configuring your project to use mergeable libraries.

### Interface

- Use the `#Preview` Swift macro to generate previews for all UI technologies, including SwiftUI, AppKit, UIKit, and WidgetKit.

- Choose between devices connected to your Mac or from Simulator runtimes when rendering previews. From the Preview canvas, choose the device or Simulator runtime from the popup menu.

- Interact with your macOS app’s interface in the Preview canvas — similar to how you can on other platforms — to test controls, logic, animations, and text input.

- Select entries from a widget’s timeline in the WidgetKit preview to view transition animations between those entries.

- Use a string catalog to localize and translate all your app’s text in a visual editor right in Xcode. Host translations, configure pluralization messages for different regions and locales, and change how text appears on different devices, all in one place. See Localizing and varying text with a string catalog.

- Automatically generate symbols for assets in your asset catalogs so you don’t need to reference those assets by string names.

### Documentation

- Preview your docs in real time. Access the new Documentation Preview assistant from the assistant jump bar.

- Get better help quickly. Quick Help offers a new visual style, support for images, and dynamic font size adjustments based on your editor font.

- Produce richer documentation. DocC now supports videos, more layout configuration options, and theming.

- Use DocC to document Swift extensions.

### Tuning and debugging

- Locate the most relevant `os_log` for debugging with the new structured debug console. The console provides insight into the origin of logs and lets you filter by metadata in addition to log messages. Jump right to your source code from individual log messages. Metadata and source code information for `os_log` messages is available for devices and Simulator runtimes running macOS 13.3 and later, iOS 17 and later, iPadOS 17 and later, watchOS 10 and later, and tvOS 17 and later.

- Diagnose testing issues more quickly and easily. Test reports include new insights that help you correlate failures between tests and configurations, so you can identify common underlying issues. Reports also include videos that help you inspect and diagnose issues with your view hierarchy.

- Xcode uses a new device connectivity stack to target devices running iOS 17 and later, iPadOS 17 and later, tvOS 17 and later, and Apple Watch devices running watchOS 8.7.1 and later when paired with an iPhone running iOS 17 and later.

- Manage devices that the new connectivity stack supports, including Apple Watch, in Xcode’s Devices and Simulators window.

- Manage and interact with devices that the new connectivity stack supports from your shell scripts with `devicectl`. For information on `devicectl`, run `xcrun devicectl help`.

- Connect and communicate wirelessly between a Mac running Xcode or Instruments and Apple Watch Series 6 and later when using the new device connectivity stack. The initial pairing process and some other tools, such as Console and Accessibility Inspector, still require the watch’s companion phone with a wired connection to a Mac.

- Xcode 15 no longer supports developing on Apple Watch (1st generation), Apple Watch Series 1, and Apple Watch Series 2 that are paired to iPhones running iOS 17 and later.

### Distribution and continuous integration

- Use streamlined options in the Xcode Organizer window to distribute your app using recommended settings. Choose from several preconfigured methods of distribution or create a custom configuration for your needs. See Distributing your app for beta testing and releases.

- Notarize macOS apps in Xcode Cloud. See Creating a workflow that builds your app for distribution.

- Add text files to your Xcode project to provide notes to beta testers about what to test through Xcode Cloud. See Including notes for testers with a beta release of your app.

- Provide feedback on issues you encounter when building with Xcode Cloud. The system prepopulates the feedback form with build-specific context and attachments Apple can use to triage a bug. See Reporting feedback for Xcode Cloud.

- Xcode Server is no longer available as a part of Xcode. Use Xcode Cloud instead.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/xpc

- Updates
- XPC updates

Article

# XPC updates

Learn about important changes to XPC.

## Overview

Browse notable changes in XPC.

## March 2024

### Security

- Test whether the peer executable that communicates with your app over an XPC connection has an expected entitlement by calling `xpc_connection_set_peer_entitlement_exists_requirement(_:_:)`, and whether it has a specific value for an entitlement by calling `xpc_connection_set_peer_entitlement_matches_value_requirement(_:_:_:)`.

- Test whether the peer executable that communicates with your app over an XPC connection is an Apple platform binary with a given signing identifier by calling `xpc_connection_set_peer_platform_identity_requirement(_:_:)`.

- Test whether your Apple Developer team signed the peer executable that communicates with your app over an XPC connection by calling `xpc_connection_set_peer_team_identity_requirement(_:_:)`.

- Test whether the peer executable that communicates with your app over an XPC connection satisfies a lightweight code requirement by calling `xpc_connection_set_peer_lightweight_code_requirement(_:_:)`.

## June 2023

- Create XPC services using native Swift syntax. Use `XPCListener` to create an XPC server that listens for messages from other processes. Use `XPCSession` to create clients that connect to servers and exchange messages.

- For C and Objective-C projects, use the corresponding `xpc_listener_t` and `xpc_session_t` APIs.

- In Xcode, use the updated XPC services target template to choose whether you want to use the high-level `NSXPCConnection` or the low-level `libXPC` APIs.

## See Also

### Technology updates

Accelerate updates

Learn about important changes to Accelerate.

Accessibility updates

Learn about important changes to Accessibility.

ActivityKit updates

Learn about important changes in ActivityKit.

AdAttributionKit Updates

Learn about important changes to AdAttributionKit.

App Clips updates

Learn about important changes in App Clips.

App Intents updates

Learn about important changes in App Intents.

AppKit updates

Learn about important changes to AppKit.

Apple Intelligence updates

Learn about important changes to Apple Intelligence.

AppleMapsServerAPI Updates

Learn about important changes to AppleMapsServerAPI.

Apple Pencil updates

Learn about important changes to Apple Pencil.

ARKit updates

Learn about important changes to ARKit.

Audio Toolbox updates

Learn about important changes to Audio Toolbox.

AuthenticationServices updates

Learn about important changes to AuthenticationServices.

AVFAudio updates

Learn about important changes to AVFAudio.

AVFoundation updates

Learn about important changes to AVFoundation.

---

# https://developer.apple.com/documentation/updates/wwdc2025)



---

# https://developer.apple.com/documentation/updates/wwdc2024)



---

# https://developer.apple.com/documentation/updates/wwdc2023)



---

# https://developer.apple.com/documentation/updates/wwdc2022)



---

# https://developer.apple.com/documentation/updates/wwdc2021)



---

# https://developer.apple.com/documentation/updates/bundleresources)



---

# https://developer.apple.com/documentation/updates/browserenginekit)



---

# https://developer.apple.com/documentation/updates/callkit)



---

# https://developer.apple.com/documentation/updates/contactsui)



---

# https://developer.apple.com/documentation/updates/corelocation)



---

# https://developer.apple.com/documentation/updates/coremidi)



---

# https://developer.apple.com/documentation/updates/coreml)



---

# https://developer.apple.com/documentation/updates/coremotion)



---

# https://developer.apple.com/documentation/updates/corespotlight)



---

# https://developer.apple.com/documentation/updates/datadetection)



---

# https://developer.apple.com/documentation/updates/defaultapps)



---

# https://developer.apple.com/documentation/updates/dockkit)



---

# https://developer.apple.com/documentation/updates/fileprovider)



---

# https://developer.apple.com/documentation/updates/financekit)



---

# https://developer.apple.com/documentation/updates/foundation)



---

# https://developer.apple.com/documentation/updates/gamecontroller)



---

# https://developer.apple.com/documentation/updates/gamekit)



---

# https://developer.apple.com/documentation/updates/groupactivities)



---

# https://developer.apple.com/documentation/updates/healthkit)



---

# https://developer.apple.com/documentation/updates/hypervisor)



---

# https://developer.apple.com/documentation/updates/journalingsuggestions)



---

# https://developer.apple.com/documentation/updates/lightweightcoderequirements)



---

# https://developer.apple.com/documentation/updates/livecommunicationkit)



---

# https://developer.apple.com/documentation/updates/mapkit)



---

# https://developer.apple.com/documentation/updates/mapkitjs)



---

# https://developer.apple.com/documentation/updates/matter)



---

# https://developer.apple.com/documentation/updates/network)



---

# https://developer.apple.com/documentation/updates/passkit)



---

# https://developer.apple.com/documentation/updates/phase)



---

# https://developer.apple.com/documentation/updates/photokit)



---

# https://developer.apple.com/documentation/updates/proximityreader)



---

# https://developer.apple.com/documentation/updates/realitykit)



---

# https://developer.apple.com/documentation/updates/safariservices)



---

# https://developer.apple.com/documentation/updates/screencapturekit)



---

# https://developer.apple.com/documentation/updates/security)



---

# https://developer.apple.com/documentation/updates/sensorkit)



---

# https://developer.apple.com/documentation/updates/shazamkit)



---

# https://developer.apple.com/documentation/updates/sirikit)



---

# https://developer.apple.com/documentation/updates/storekit)



---

# https://developer.apple.com/documentation/updates/swift)



---

# https://developer.apple.com/documentation/updates/swiftcharts)



---

# https://developer.apple.com/documentation/updates/swiftdata)



---

# https://developer.apple.com/documentation/updates/swiftui)



---

# https://developer.apple.com/documentation/updates/symbols)



---

# https://developer.apple.com/documentation/updates/tipkit)



---

# https://developer.apple.com/documentation/updates/threadnetwork)



---

# https://developer.apple.com/documentation/updates/uikit)



---

# https://developer.apple.com/documentation/updates/usernotifications)



---

# https://developer.apple.com/documentation/updates/videosubscriberaccount)



---

# https://developer.apple.com/documentation/updates/virtualization)



---

# https://developer.apple.com/documentation/updates/vision)



---

# https://developer.apple.com/documentation/updates/watchos)



---

# https://developer.apple.com/documentation/updates/weatherkit)



---

# https://developer.apple.com/documentation/updates/widgetkit)



---

# https://developer.apple.com/documentation/updates/workoutkit)



---

# https://developer.apple.com/documentation/updates/xcode)



---

# https://developer.apple.com/documentation/updates/xpc)



---

