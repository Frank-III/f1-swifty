//
//  UniversalOverlay.swift
//  F1DashAppXCode
//
//  Universal overlay system for smooth floating views and PiP functionality
//  Based on Balaji Venkatesh's UniversalOverlay pattern
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Extensions
extension View {
    @ViewBuilder
    func universalOverlay<Content: View>(
        animation: Animation = .snappy,
        show: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self
            .modifier(UniversalOverlayModifier(animation: animation, show: show, viewContent: content))
    }
}

/// Root View Wrapper
struct RootView<Content: View>: View {
    var content: Content
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var properties = UniversalOverlayProperties()
    var body: some View {
        content
            .environment(properties)
            #if os(iOS)
            .onAppear {
                if let windowScene = (UIApplication.shared.connectedScenes.first as? UIWindowScene), properties.uiWindow == nil {
                    let window = PassThroughWindow(windowScene: windowScene)
                    window.isHidden = false
                    window.isUserInteractionEnabled = true
                    /// Setting Up SwiftUI Based RootView Controller
                    let rootViewController = UIHostingController(rootView: UniversalOverlayViews().environment(properties))
                    rootViewController.view.backgroundColor = .clear
                    window.rootViewController = rootViewController
                    
                    properties.uiWindow = window
                }
            }
            #endif
    }
}

/// Shared Universal Overlay Properties
@Observable
class UniversalOverlayProperties {
    var window: AnyObject? = nil
    var views: [OverlayView] = []
    
    struct OverlayView: Identifiable {
        var id: String = UUID().uuidString
        var view: AnyView
    }
    
    #if os(iOS)
    var uiWindow: UIWindow? {
        get { window as? UIWindow }
        set { window = newValue }
    }
    #endif
}

fileprivate struct UniversalOverlayModifier<ViewContent: View>: ViewModifier {
    var animation: Animation
    @Binding var show: Bool
    @ViewBuilder var viewContent: ViewContent
    /// Local View Properties
    @Environment(UniversalOverlayProperties.self) private var properties
    @State private var viewID: String?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: show, initial: true) { oldValue, newValue in
                if newValue {
                    addView()
                } else {
                    removeView()
                }
            }
    }
    
    private func addView() {
        #if os(iOS)
        if properties.uiWindow != nil && viewID == nil {
            viewID = UUID().uuidString
            guard let viewID else { return }
            
            withAnimation(animation) {
                properties.views.append(.init(id: viewID, view: .init(viewContent)))
            }
        }
        #else
        // On non-iOS platforms, just add the view without window check
        if viewID == nil {
            viewID = UUID().uuidString
            guard let viewID else { return }
            
            withAnimation(animation) {
                properties.views.append(.init(id: viewID, view: .init(viewContent)))
            }
        }
        #endif
    }
    
    private func removeView() {
        if let viewID {
            withAnimation(animation) {
                properties.views.removeAll(where: { $0.id == viewID })
            }
            
            self.viewID = nil
        }
    }
}

fileprivate struct UniversalOverlayViews: View {
    @Environment(UniversalOverlayProperties.self) private var properties
    var body: some View {
        ZStack {
            ForEach(properties.views) {
                $0.view
            }
        }
    }
}

#if os(iOS)
fileprivate class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event),
                let rootView = rootViewController?.view
        else { return nil }
        
        if #available(iOS 18, *) {
            for subview in rootView.subviews.reversed() {
                /// Finding if any of rootview's is receving hit test
                let pointInSubView = subview.convert(point, from: rootView)
                if subview.hitTest(pointInSubView, with: event) != nil {
                    return hitView
                }
            }
            
            return nil
        } else {
            return hitView == rootView ? nil : hitView
        }
    }
}
#endif

extension CGSize {
    static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
        return .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}

#Preview {
    RootView {
        VStack {
            Text("Universal Overlay Demo")
                .font(.title)
            
            Button("Test Overlay") {
                // Demo button - actual implementation in views that use this
            }
        }
    }
}