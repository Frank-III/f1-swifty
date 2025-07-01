iOS 26 SDK Requirements
<!-- IMPORTANT: This project now requires iOS 26 SDK and targets iOS 26+ exclusively. We fully embrace and utilize the latest SwiftUI APIs introduced in June 2025. -->

Available iOS 26 SwiftUI APIs
Feel free to use any of these new APIs throughout the codebase:

Liquid Glass Effects
glassEffect(_:in:isEnabled:) - Apply Liquid Glass effects to views
buttonStyle(.glass) - Apply Liquid Glass styling to buttons
ToolbarSpacer - Create visual breaks in toolbars with Liquid Glass
Enhanced Scrolling
scrollEdgeEffectStyle(_:for:) - Configure scroll edge effects
backgroundExtensionEffect() - Duplicate, mirror, and blur views around edges
Tab Bar Enhancements
tabBarMinimizeBehavior(_:) - Control tab bar minimization behavior
Search role for tabs with search field replacing tab bar
TabViewBottomAccessoryPlacement - Adjust accessory view content based on placement
Web Integration
WebView and WebPage - Full control over browsing experience
Drag and Drop
draggable(_:_:) - Drag multiple items
dragContainer(for:id:in:selection:_:) - Container for draggable views
Animation
@Animatable macro - SwiftUI synthesizes custom animatable data properties
UI Components
Slider with automatic tick marks when using step parameter
windowResizeAnchor(_:) - Set window anchor point for resizing
Text Enhancements
TextEditor now supports AttributedString
AttributedTextSelection - Handle text selection with attributed text
AttributedTextFormattingDefinition - Define text styling in specific contexts
FindContext - Create find navigator in text editing views
Accessibility
AssistiveAccess - Support Assistive Access in iOS scenes
HDR Support
Color.ResolvedHDR - RGBA values with HDR headroom information
UIKit Integration
UIHostingSceneDelegate - Host and present SwiftUI scenes in UIKit
NSGestureRecognizerRepresentable - Incorporate gesture recognizers from AppKit
Immersive Spaces (if applicable)
manipulable(coordinateSpace:operations:inertia:isEnabled:onChanged:) - Hand gesture manipulation
SurfaceSnappingInfo - Snap volumes and windows to surfaces
RemoteImmersiveSpace - Render stereo content from Mac to Apple Vision Pro
SpatialContainer - 3D layout container
Depth-based modifiers: aspectRatio3D(_:contentMode:), rotation3DLayout(_:), depthAlignment(_:)
Usage Guidelines
Leverage these new APIs to enhance the user experience
Replace legacy implementations with iOS 26 APIs where appropriate
Take advantage of Liquid Glass effects for modern UI aesthetics
Use the enhanced text and drag-and-drop capabilities for better interactions
