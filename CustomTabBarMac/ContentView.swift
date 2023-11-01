//
//  ContentView.swift
//  CustomTabBarMac
//
//  Created by shiyanjun on 2023/11/1.
//

import SwiftUI

struct ContentView: View {
    @State private var currentTab: Tab = .today
    @Environment(\.colorScheme) var scheme
    @State private var isDark: Bool = true
    @State private var hoverTab: Tab?
    @State private var isHovering = false
    @State private var onAppeared: Bool = false
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            HStack(spacing: 0) {
                let isLarge = size.width > (screenFrame.width * 0.5)
                
                ViewThatFits {
                    SideBar(size)
                    
                    ScrollView(showsIndicators: false) {
                        SideBar(size)
                    }
                    //.scrollIndicators(.hidden)
                }
                .background(scheme == .dark ? .black : .white)
                .clipShape(.rect(cornerRadius: isLarge ? 12 : 50, style: .continuous))
                .padding(15)
                .animation(onAppeared ? .snappy(duration: 0.28) : .none, value: isLarge)
                .task {
                    guard !onAppeared else { return }
                    try? await Task.sleep(for: .seconds(0.1))
                    onAppeared = true
                }
                
                CustomTabView(selection: $currentTab) {
                    /// Replace With Your Tab View's
                    ForEach(Tab.allCases, id: \.rawValue) { tab in
                        Text(tab.rawValue + " View")
                            .tag(tab)
                    }
                }
            }
            .frame(width: size.width, height: size.height, alignment: .leading)
        }
        .background(Color("BG"))
        .preferredColorScheme(isDark ? .dark : .light)
    }
    
    @ViewBuilder
    func SideBar(_ size: CGSize) -> some View {
        let isLarge = size.width > (screenFrame.width * 0.5)
        
        /// Displaying Names if the screen is large
        VStack(alignment: isLarge ? .leading : .center, spacing: 0) {
            
            HStack(spacing: isLarge ? 10 : 0) {
                Image(systemName: "envelope.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(.blue.gradient, in: .circle)
                
                if isLarge {
                    Text("Mail")
                        .fontWeight(.medium)
                }
            }
            .padding(.bottom, 12)
            
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                Button {
                    currentTab = tab
                } label: {
                    HStack(spacing: isLarge ? 8 : 0) {
                        Image(systemName: tab.sfSymbol)
                            .font(.title2)
                            .fontWeight(currentTab == tab ? .semibold : .regular)
                            .foregroundStyle(currentTab == tab ? Color.primary : .gray)
                            .frame(width: 30, height: 30)
                        
                        if isLarge {
                            Text(tab.rawValue)
                                .frame(width: 55, alignment: .leading)
                        }
                    }
                    .contentShape(.rect)
                }
                .padding(.vertical, 7)
                .onHover { hovering in
                    if hovering {
                        hoverTab = tab
                    } else if hoverTab == tab {
                        hoverTab = nil
                    }
                }
                .scaleEffect(hoverTab == tab ? 1.1 : 1)
                /**
                 .onContinuousHover(perform: { phase in
                 hoverTab = (phase == tab ? 1.1 : 1)
                 })
                 */
            }
            
            Spacer(minLength: 0)
            
            /// Dark Mode Button
            Button {
                isDark.toggle()
            } label: {
                HStack(spacing: isLarge ? 6 : 0) {
                    if #available(macOS 14, *) {
                        Image(systemName: !isDark ? "moon" : "sun.min")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(width: 30, height: 30)
                            .contentTransition(.symbolEffect(.replace))
                    } else {
                        Image(systemName: !isDark ? "moon" : "sun.min")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(width: 30, height: 30)
                    }
                    
                    if isLarge {
                        Text(isDark ? "Light" : "Dark")
                    }
                }
                .contentShape(.rect)
                .foregroundStyle(Color.primary)
            }
        }
        .animation(.snappy(duration: 0.28), value: currentTab)
        .animation(.snappy(duration: 0.28), value: hoverTab)
        .buttonStyle(.plain)
        .padding(15)
    }
    
    var screenFrame: CGRect {
        return NSScreen.main?.visibleFrame ?? .zero
    }
}

struct ContentView_previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
