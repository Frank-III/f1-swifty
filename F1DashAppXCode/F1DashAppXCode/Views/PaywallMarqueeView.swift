import SwiftUI
import Glur
import RevenueCat

// MARK: - PaywallCardModel
struct PaywallCardModel: Identifiable, Hashable {
    let id: String = UUID().uuidString
    let image: String
    let title: String
    let subtitle: String
    let icon: String
    
    static let allItems: [PaywallCardModel] = [
        PaywallCardModel(image: "F1Car3D", title: "Real-time Telemetry", subtitle: "Live race data and performance metrics", icon: "speedometer"),
        PaywallCardModel(image: "Helmet3D", title: "Driver Analytics", subtitle: "In-depth driver performance insights", icon: "eye.fill"),
        PaywallCardModel(image: "Tropy3D", title: "Championship Data", subtitle: "Complete season statistics", icon: "trophy.fill"),
        PaywallCardModel(image: "CheckFlag3D", title: "Race Results", subtitle: "Detailed finish line analysis", icon: "flag.checkered"),
        PaywallCardModel(image: "Track3D", title: "Circuit Analysis", subtitle: "Track conditions and lap times", icon: "map.fill"),
        PaywallCardModel(image: "Radio3D", title: "Team Radio", subtitle: "Live team communications", icon: "radio.fill"),
        PaywallCardModel(image: "TV3D", title: "Broadcast Quality", subtitle: "HD video streams and replays", icon: "tv.fill"),
        PaywallCardModel(image: "WeatherSensor3D", title: "Weather Data", subtitle: "Real-time track conditions", icon: "cloud.rain.fill"),
        PaywallCardModel(image: "RaceCar3D", title: "Technical Data", subtitle: "Car setup and performance", icon: "wrench.and.screwdriver.fill")
    ]
}

// MARK: - TitleTextRenderer
struct TitleTextRenderer: TextRenderer, Animatable {
    var progress: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        let slices = layout.flatMap({ $0 }).flatMap({ $0 })
        
        for (index, slice) in slices.enumerated() {
            let sliceProgressIndex = CGFloat(slices.count) * progress
            let sliceProgress = max(min(sliceProgressIndex / CGFloat(index + 1), 1), 0)
            
            ctx.addFilter(.blur(radius: 5 - (5 * sliceProgress)))
            ctx.opacity = sliceProgress
            ctx.translateBy(x: 0, y: 5 - (5 * sliceProgress))
            ctx.draw(slice, options: .disablesSubpixelQuantization)
        }
    }
}

// MARK: - InfiniteScrollView
struct InfiniteScrollView<Content: View>: View {
    var spacing: CGFloat = 10
    @ViewBuilder var content: Content
    @State private var contentSize: CGSize = .zero
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            ScrollView(.horizontal) {
                HStack(spacing: spacing) {
                    Group(subviews: content) { collection in
                        HStack(spacing: spacing) {
                            ForEach(collection) { view in
                                view
                            }
                        }
                        .onGeometryChange(for: CGSize.self) {
                            $0.size
                        } action: { newValue in
                            contentSize = .init(width: newValue.width + spacing, height: newValue.height)
                        }
                        
                        let averageWidth = contentSize.width / CGFloat(collection.count)
                        let repeatingCount = contentSize.width > 0 ? Int((size.width / averageWidth).rounded()) + 1 : 1
                        
                        HStack(spacing: spacing) {
                            ForEach(0..<repeatingCount, id: \.self) { index in
                                let view = Array(collection)[index % collection.count]
                                view
                            }
                        }
                    }
                }
                #if os(iOS)
                .background(InfiniteScrollHelper(contentSize: $contentSize, declarationRate: .constant(.fast)))
                #endif
            }
        }
    }
}

#if os(iOS)
import UIKit

fileprivate struct InfiniteScrollHelper: UIViewRepresentable {
    @Binding var contentSize: CGSize
    @Binding var declarationRate: UIScrollView.DecelerationRate
    
    func makeCoordinator() -> Coordinator {
        Coordinator(declarationRate: declarationRate, contentSize: contentSize)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        DispatchQueue.main.async {
            if let scrollView = view.scrollView {
                context.coordinator.defaultDelegate = scrollView.delegate
                scrollView.decelerationRate = declarationRate
                scrollView.delegate = context.coordinator
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.declarationRate = declarationRate
        context.coordinator.contentSize = contentSize
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var declarationRate: UIScrollView.DecelerationRate
        var contentSize: CGSize
        
        init(declarationRate: UIScrollView.DecelerationRate, contentSize: CGSize) {
            self.declarationRate = declarationRate
            self.contentSize = contentSize
        }
        
        weak var defaultDelegate: UIScrollViewDelegate?
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            scrollView.decelerationRate = declarationRate
            
            let minX = scrollView.contentOffset.x
            
            if minX > contentSize.width {
                scrollView.contentOffset.x -= contentSize.width
            }
            
            if minX < 0 {
                scrollView.contentOffset.x += contentSize.width
            }
            
            defaultDelegate?.scrollViewDidScroll?(scrollView)
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            defaultDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            defaultDelegate?.scrollViewDidEndDecelerating?(scrollView)
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            defaultDelegate?.scrollViewWillBeginDragging?(scrollView)
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            defaultDelegate?.scrollViewWillEndDragging?(
                scrollView,
                withVelocity: velocity,
                targetContentOffset: targetContentOffset
            )
        }
    }
}

extension UIView {
    var scrollView: UIScrollView? {
        if let superview, superview is UIScrollView {
            return superview as? UIScrollView
        }
        
        return superview?.scrollView
    }
}
#endif

// MARK: - Main PaywallMarqueeView
struct PaywallMarqueeView: View {
    @Environment(PremiumStore.self) private var premiumStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var activeCard: PaywallCardModel? = PaywallCardModel.allItems.first
    @State private var scrollPosition: ScrollPosition = .init()
    @State private var currentScrollOffset: CGFloat = 0
    @State private var timer = Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()
    @State private var initialAnimation: Bool = false
    @State private var titleProgress: CGFloat = 0
    @State private var scrollPhase: ScrollPhase = .idle
    @State private var showSubscriptionOptions: Bool = false
    @State private var selectedPlan: String? = nil
    @State private var showRestoreButton: Bool = false
    @State private var purchaseAlert: PurchaseAlert?
    @State private var dragOffset: CGSize = .zero
    
    struct PurchaseAlert: Identifiable {
        let id = UUID()
        let title: String
        let message: String
        let isSuccess: Bool
    }
    
    var body: some View {
        ZStack {
            // Background layer with full screen coverage
            AmbientBackground()
                .animation(.easeInOut(duration: 1), value: activeCard)
                .ignoresSafeArea()
            
            // Content layer
            VStack(spacing: 40) {
                InfiniteScrollView {
                    ForEach(PaywallCardModel.allItems) { card in
                        CarouselCardView(card)
                    }
                }
                .scrollIndicators(.hidden)
                .scrollPosition($scrollPosition)
                .scrollClipDisabled()
                .containerRelativeFrame(.vertical) { value, _ in
                    value * 0.45
                }
                .onScrollPhaseChange { oldPhase, newPhase in
                    scrollPhase = newPhase
                }
                .onScrollGeometryChange(for: CGFloat.self) {
                    $0.contentOffset.x + $0.contentInsets.leading
                } action: { oldValue, newValue in
                    currentScrollOffset = newValue
                    
                    if scrollPhase != .decelerating || scrollPhase != .animating {
                        let activeIndex = Int((currentScrollOffset / 220).rounded()) % PaywallCardModel.allItems.count
                        activeCard = PaywallCardModel.allItems[activeIndex]
                    }
                }
                .visualEffect { [initialAnimation] content, proxy in
                    content
                        .offset(y: !initialAnimation ? -(proxy.size.height + 200) : 0)
                }

                VStack(spacing: 20) {
                    ZStack {
                        // Title section that rotates when showing options
                        VStack(spacing: 4) {
                            Text("Welcome to")
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.secondary)
                                .blurOpacityEffect(initialAnimation)
                            
                            Text("F1 Dash Premium")
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)
                                .textRenderer(TitleTextRenderer(progress: titleProgress))
                                .padding(.bottom, 12)
                            
                            Text("Experience real-time telemetry data and\nadvanced analytics for Formula 1 racing.\nUnlock premium features with F1 Dash+.")
                                .font(.callout)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white.secondary)
                                .blurOpacityEffect(initialAnimation)
                        }
                        .rotation3DEffect(
                            .degrees(showSubscriptionOptions ? -90 : 0),
                            axis: (x: 1.0, y: 0.0, z: 0.0),
                            anchor: .top,
                            anchorZ: 0,
                            perspective: 1.0
                        )
                        .opacity(showSubscriptionOptions ? 0 : 1)
                        
                        // Subscription options that rotate in
                        if showSubscriptionOptions {
                            HStack(spacing: 12) {
                                // Monthly
                                SubscriptionOptionButton(
                                    symbol: "heart.fill",
                                    title: "Monthly",
                                    subtitle: "Support us",
                                    price: premiumStore.monthlyPackage?.localizedPriceString ?? "$0.99",
                                    selected: selectedPlan == "monthly",
                                    color: Color.pink
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedPlan = "monthly"
                                    }
                                }
                                .disabled(premiumStore.monthlyPackage == nil)
                                .opacity(premiumStore.monthlyPackage == nil ? 0.6 : 1)
                                
                                // Annual
                                SubscriptionOptionButton(
                                    symbol: "cup.and.saucer.fill",
                                    title: "Annual",
                                    subtitle: "Buy us coffee",
                                    price: premiumStore.annualPackage?.localizedPriceString ?? "$2.99",
                                    selected: selectedPlan == "annual",
                                    color: Color.orange
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedPlan = "annual"
                                    }
                                }
                                .disabled(premiumStore.annualPackage == nil)
                                .opacity(premiumStore.annualPackage == nil ? 0.6 : 1)
                                
                                // Lifetime
                                SubscriptionOptionButton(
                                    symbol: "bolt.fill",
                                    title: "Lifetime",
                                    subtitle: "Full throttle",
                                    price: premiumStore.lifetimePackage?.localizedPriceString ?? "$4.99",
                                    selected: selectedPlan == "lifetime",
                                    color: Color.purple
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedPlan = "lifetime"
                                    }
                                }
                                .disabled(premiumStore.lifetimePackage == nil)
                                .opacity(premiumStore.lifetimePackage == nil ? 0.6 : 1)
                            }
                            .padding(.horizontal, 20)
                            .rotation3DEffect(
                                .degrees(showSubscriptionOptions ? 0 : 90),
                                axis: (x: 1.0, y: 0.0, z: 0.0),
                                anchor: .bottom,
                                anchorZ: 0,
                                perspective: 1.0
                            )
                        }
                    }
                    .animation(.easeInOut(duration: 0.6), value: showSubscriptionOptions)
                    
                    // Action button
                    Button {
                        if showSubscriptionOptions && selectedPlan != nil {
                            // Process purchase
                            Task {
                                await processPurchase()
                            }
                        } else {
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                                showSubscriptionOptions = true
                                showRestoreButton = true
                            }
                        }
                    } label: {
                        ZStack {
                            // Glow effect background
                            if showSubscriptionOptions && selectedPlan != nil {
                                Capsule()
                                    .fill(Color.white.opacity(0.3))
                                    .blur(radius: 10)
                                    .frame(width: 180, height: 60)
                            }
                            
                            if premiumStore.isPurchasing || premiumStore.isRestoring {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                                    .frame(width: 20, height: 20)
                                    .padding(.horizontal, 35)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(Color.white)
                                    )
                            } else {
                                Text(showSubscriptionOptions ? "Subscribe" : "Get Premium")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 25)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(
                                                showSubscriptionOptions && selectedPlan != nil 
                                                ? Color.white 
                                                : Color.white.opacity(0.9)
                                            )
                                    )
                                    .scaleEffect(showSubscriptionOptions && selectedPlan != nil ? 1.05 : 1.0)
                            }
                        }
                    }
                    .disabled(showSubscriptionOptions && selectedPlan == nil || premiumStore.isPurchasing || premiumStore.isRestoring)
                    .blurOpacityEffect(initialAnimation)
                    
                    // Restore purchases button
                    if showRestoreButton && !premiumStore.isPurchasing {
                        Button {
                            Task {
                                await restorePurchases()
                            }
                        } label: {
                            Text("Restore Purchases")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .buttonStyle(.plain)
                        .disabled(premiumStore.isRestoring)
                    }
                }
            }
            .safeAreaPadding(15)
        }
        .onReceive(timer) { _ in
            currentScrollOffset += 0.35
            scrollPosition.scrollTo(x: currentScrollOffset)
        }
        .task {
            try? await Task.sleep(for: .seconds(0.35))
            
            withAnimation(.smooth(duration: 0.75, extraBounce: 0)) {
                initialAnimation = true
            }
            
            withAnimation(.smooth(duration: 2.5, extraBounce: 0).delay(0.3)) {
                titleProgress = 1
            }
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white.opacity(0.6), .white.opacity(0.2))
                        .background(Circle().fill(.ultraThinMaterial))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding()
            }
        }
        .offset(y: dragOffset.height)
        .opacity(1.0 - (dragOffset.height / 500))
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height > 0 {
                        dragOffset = value.translation
                    }
                }
                .onEnded { value in
                    if value.translation.height > 150 {
                        // Dismiss if dragged down more than 150 points
                        dismiss()
                    } else {
                        // Snap back to original position
                        withAnimation(.spring()) {
                            dragOffset = .zero
                        }
                    }
                }
        )
        .alert(item: $purchaseAlert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK")) {
                    if alert.isSuccess {
                        // Dismiss paywall on successful purchase
                        dismiss()
                    }
                }
            )
        }
        .onAppear {
            // Load products if not already loaded
            if !premiumStore.hasLoadedProducts {
                Task {
                    await premiumStore.loadProducts()
                }
            }
        }
    }
    
    // MARK: - Purchase Methods
    
    private func processPurchase() async {
        guard let selectedPlan else { return }
        
        do {
            try await premiumStore.purchase(selectedPlan)
            
            // Show success alert
            purchaseAlert = PurchaseAlert(
                title: "Purchase Successful!",
                message: "Thank you for supporting F1 Dash. Enjoy your premium features!",
                isSuccess: true
            )
            
            // Stop the timer
            timer.upstream.connect().cancel()
            
            // Haptic feedback on iOS
            #if os(iOS)
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            #endif
        } catch {
            // Show error alert
            purchaseAlert = PurchaseAlert(
                title: "Purchase Failed",
                message: error.localizedDescription,
                isSuccess: false
            )
        }
    }
    
    private func restorePurchases() async {
        do {
            try await premiumStore.restorePurchases()
            
            // Show success alert
            purchaseAlert = PurchaseAlert(
                title: "Restore Successful!",
                message: "Your purchases have been restored.",
                isSuccess: true
            )
        } catch {
            // Show error alert
            purchaseAlert = PurchaseAlert(
                title: "Restore Failed",
                message: error.localizedDescription,
                isSuccess: false
            )
        }
    }
    
    @ViewBuilder
    private func AmbientBackground() -> some View {
        GeometryReader {
            let size = $0.size
            
            ZStack {
                ForEach(PaywallCardModel.allItems) { card in
                    Image(card.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                        .frame(width: size.width, height: size.height)
                        .opacity(activeCard?.id == card.id ? 1 : 0)
                }
                
                Rectangle()
                    .fill(.black.opacity(0.45))
                    .ignoresSafeArea()
            }
            .compositingGroup()
            .blur(radius: 90, opaque: true)
            .ignoresSafeArea()
        }
    }
}

// MARK: - Supporting Views
@ViewBuilder
private func CarouselCardView(_ card: PaywallCardModel) -> some View {
    EnhancedCardView(card: card)
        .frame(width: 220)
        .scrollTransition(.interactive.threshold(.centered), axis: .horizontal) { content, phase in
            content
                .offset(y: phase == .identity ? -10 : 0)
                .rotationEffect(.degrees(phase.value * 5), anchor: .bottom)
        }
}

struct EnhancedCardView: View {
    let card: PaywallCardModel
    @State private var isHovered: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Ambient gradient background based on image color
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                getAccentColor(for: card.image).opacity(0.3),
                                getAccentColor(for: card.image).opacity(0.15),
                                Color.black.opacity(0.95)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ))

                
                VStack(spacing: 0) {
                    // Top section with centered image and pattern
                    ZStack {
                        // Background pattern in grid
                        GeometryReader { geo in
                            let columns = 3
                            let rows = 3
                            let spacing = geo.size.width / CGFloat(columns + 1)
                            let verticalSpacing = geo.size.height / CGFloat(rows + 1)
                            
                            ForEach(0..<rows, id: \.self) { row in
                                ForEach(0..<columns, id: \.self) { col in
                                    Image(systemName: getPatternSymbol(for: card.image))
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray.opacity(isHovered ? 0.21: 0.18))
                                        .position(
                                            x: spacing * CGFloat(col + 1),
                                            y: verticalSpacing * CGFloat(row + 1)
                                        )
                                        .rotationEffect(.degrees(15))
                                }
                            }
                        }
                        
                        VStack {
                            Spacer()
                            
                            Image(card.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 90, height: 90)
                                .scaleEffect(isHovered ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: isHovered)
                                .shadow(color: getAccentColor(for: card.image).opacity(0.6), radius: isHovered ? 25 : 15)
                                .shadow(color: getAccentColor(for: card.image).opacity(0.3), radius: isHovered ? 40 : 25)
                            
                            Spacer()
                        }
                    }
                    .frame(height: geometry.size.height * 0.7)
                    
                    // Bottom text section with glur
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: card.icon)
                                .font(.title3)
                                .foregroundColor(getAccentColor(for: card.image))
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(card.title)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(card.subtitle)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(2)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: geometry.size.height * 0.3)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay {
                // Hover glow effect
                if isHovered {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            getAccentColor(for: card.image).opacity(0.6),
                            lineWidth: 2
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(getAccentColor(for: card.image).opacity(0.1))
                        )
                        .blur(radius: 4)
                }
            }
            .shadow(color: .black.opacity(0.4), radius: 10, x: 1, y: 0)
            .shadow(color: isHovered ? getAccentColor(for: card.image).opacity(0.3) : .clear, radius: 15, x: 0, y: 0)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.3)) {
                    isHovered = hovering
                }
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovered = false
                    }
                }
            }
        }
    }
    
    private func getAccentColor(for imageName: String) -> Color {
        switch imageName {
        case "F1Car3D":
            return Color(red: 0.9, green: 0.1, blue: 0.1) // Red
        case "Helmet3D":
            return Color(red: 0.2, green: 0.6, blue: 0.9) // Blue
        case "Tropy3D":
            return Color(red: 0.9, green: 0.7, blue: 0.1) // Gold
        case "CheckFlag3D":
            return Color.white // White
        case "Track3D":
            return Color(red: 0.1, green: 0.8, blue: 0.3) // Green
        case "Radio3D":
            return Color(red: 0.6, green: 0.3, blue: 0.9) // Purple
        case "TV3D":
            return Color(red: 0.1, green: 0.7, blue: 0.9) // Cyan
        case "WeatherSensor3D":
            return Color(red: 0.5, green: 0.8, blue: 0.9) // Light Blue
        case "RaceCar3D":
            return Color(red: 0.9, green: 0.4, blue: 0.1) // Orange
        default:
            return Color.white
        }
    }
    
    private func getPatternSymbol(for imageName: String) -> String {
        switch imageName {
        case "F1Car3D":
            return "speedometer" // Speed gauges
        case "Helmet3D":
            return "shield.lefthalf.filled" // Shield/protection symbols
        case "Tropy3D":
            return "star.fill" // Stars for victory
        case "CheckFlag3D":
            return "flag.fill" // Flag symbols
        case "Track3D":
            return "location.fill" // Location pins
        case "Radio3D":
            return "antenna.radiowaves.left.and.right" // Radio waves
        case "TV3D":
            return "play.rectangle.fill" // Play/video symbols
        case "WeatherSensor3D":
            return "cloud.fill" // Cloud symbols
        case "RaceCar3D":
            return "gear" // Gear/mechanical symbols
        default:
            return "circle.fill"
        }
    }
}

// MARK: - Subscription Option Button
struct SubscriptionOptionButton: View {
    let symbol: String
    let title: String
    let subtitle: String
    let price: String
    let selected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // Background circle with gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(selected ? 0.3 : 0.15),
                                    color.opacity(selected ? 0.2 : 0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    // Icon
                    Image(systemName: symbol)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(selected ? color : color.opacity(0.7))
                        .scaleEffect(selected ? 1.1 : 1.0)
                }
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(price)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(selected ? color : .white)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(selected ? 0.12 : 0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                selected ? color.opacity(0.5) : Color.white.opacity(0.1),
                                lineWidth: selected ? 2 : 1
                            )
                    )
            )
            .shadow(color: selected ? color.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .scaleEffect(selected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: selected)
    }
}

extension View {
    func blurOpacityEffect(_ show: Bool) -> some View {
        self
            .blur(radius: show ? 0 : 2)
            .opacity(show ? 1 : 0)
            .scaleEffect(show ? 1 : 0.9)
    }
}


#Preview {
    PaywallMarqueeView()
        .environment(PremiumStore())
}
