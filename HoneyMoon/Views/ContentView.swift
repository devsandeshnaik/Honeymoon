//
//  ContentView.swift
//  HoneyMoon
//
//  Created by Sandesh on 24/02/21.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @State private var showBookingAlert: Bool = false
    @State private var showGuide: Bool = false
    @State private var showInfo: Bool = false
    @State private var lastCardIndex: Int = 1
    @State private var cardRemovalTransition = AnyTransition.trailingBottom
    
    @GestureState private var dragState = DragState.inactive
    private var dragAreaThreshold: CGFloat = 65.0
    
    // MARK: - Drag stats
    enum DragState {
        case inactive
        case pressing
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch  self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
        
        var isDragging: Bool {
            switch  self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
            }
        }
        
        var isPressing: Bool {
            switch self {
            case .pressing, .dragging:
                return true
            case .inactive:
                return false
            }
        }
    }
    
    // MARK: - CardViews
    @State var cardViews: [CardView] = {
        var honeymoonViews = [CardView]()
        for index in 0 ..< 2 {
            honeymoonViews.append(CardView(honeymoon: honeymoonData[index]))
        }
        return honeymoonViews
    }()
    
    
    // MARK: - Move card
    private func moveCards() {
        cardViews.removeFirst()
        self.lastCardIndex += 1
        let honeymoon = honeymoonData[lastCardIndex % honeymoonData.count]
        let newCard = CardView(honeymoon: honeymoon)
        cardViews.append(newCard)
    }
    // MARK: - TopCard
    private func isTopCard(cardView: CardView) -> Bool {
        guard  let index = cardViews.firstIndex(where: {$0.id == cardView.id}) else {
            return false
        }
        return index == 0
    }
    var body: some View {
        VStack {
            // MARK: - Header
            HeaderView(showGuideView: $showGuide, showInfoView: $showInfo)
                .opacity(dragState.isDragging ? 0.0 : 1.0)
                .animation(.default)
            
            Spacer()
            
            // MARK: - Cards
            ZStack {
                ForEach(cardViews) { cardView in
                    cardView
                        .zIndex(self.isTopCard(cardView: cardView) ? 1 : 0)
                        .overlay(
                            ZStack {
                                Image(systemName: "x.circle")
                                    .modifier(SymbolModifier())
                                    .opacity(showCancel(cardView: cardView))
                                
                                Image(systemName: "heart.circle")
                                    .modifier(SymbolModifier())
                                    .opacity(showHeart(cardView: cardView))
                                
                                    
                            }
                        )
                        .padding()
                        .offset(x: self.isTopCard(cardView: cardView) ? dragState.translation.width : 0
                                , y: self.isTopCard(cardView: cardView) ? dragState.translation.height : 0)
                        .scaleEffect( isTopCard(cardView: cardView) && dragState.isDragging ? 0.85 : 1.0)
                        .rotationEffect(Angle(degrees: isTopCard(cardView: cardView) ? Double(dragState.translation.width / 12) : 0))
                        .animation(.interpolatingSpring(stiffness: 120, damping: 120))
                        .gesture(LongPressGesture(minimumDuration: 0.01)
                                    .sequenced(before: DragGesture())
                                    .updating(self.$dragState, body: { (value, state, transaction) in
                                        switch value {
                                        case .first(true):
                                            state = .pressing
                                        case .second(true, let drag):
                                            state = .dragging(translation: drag?.translation ?? .zero)
                                        default :
                                            break
                                        }
                                    })
                                    .onChanged({(value) in
                                        guard case .second(true, let drag?) = value else {
                                            return
                                        }
                                        
                                        if drag.translation.width < -dragAreaThreshold {
                                            cardRemovalTransition = .leadingBottom
                                        }
                                        
                                        if drag.translation.width > dragAreaThreshold {
                                            cardRemovalTransition = .trailingBottom
                                        }
                                    })
                                    .onEnded({(value) in
                                        guard case .second(true, let drag?) = value else {
                                            return
                                        }
                                        
                                        if drag.translation.width < -dragAreaThreshold || drag.translation.width > dragAreaThreshold {
                                            playSound(sound: "sound-rise", type: "mp3")
                                            moveCards()
                                        }
                                    })
                        ).transition(cardRemovalTransition)
                }
            }
            
            
            Spacer()
            
            // MARK: - Footer
            FooterView(showBookingAlert: $showBookingAlert)
                .opacity(dragState.isDragging ? 0.0 : 1.0)
                .animation(.default)
        }
        .alert(isPresented: $showBookingAlert) {
            Alert(title: Text("Success".uppercased()),
                  message: Text("Wishing a lovely and most precious of the times together for the amazing couple"),
                  dismissButton: .default(Text("Happy Honeymoon!")))
        }
    }
    
    func showCancel(cardView: CardView) -> Double {
        return (dragState.translation.width < -self.dragAreaThreshold && isTopCard(cardView: cardView)) ? 1 : 0
    }
    
    func showHeart(cardView: CardView) -> Double {
        return (dragState.translation.width > self.dragAreaThreshold && isTopCard(cardView: cardView)) ? 1 : 0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
