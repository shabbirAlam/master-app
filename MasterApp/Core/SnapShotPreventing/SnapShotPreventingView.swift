//
//  SnapShotPreventingView.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 11/03/26.
//

import SwiftUI

struct SnapShotPreventingView <Content: View> : View {
    var content: Content
    let pub = NotificationCenter.default
        .publisher(for: UIApplication.userDidTakeScreenshotNotification)
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    @State private var hostingController: UIHostingController <Content>?
    
    var body: some View {
        _SnapShotPreventingView(hostingController: $hostingController)
            .overlay {
                GeometryReader {
                    let size = $0.size
                    Color.clear.preference(key: SizeKey.self, value: size)
                        .onPreferenceChange(SizeKey.self, perform: { value in
                            if value != .zero {
                                if hostingController == nil {
                                    hostingController = UIHostingController(rootView: content)
                                    hostingController?.view.backgroundColor = .clear
                                    hostingController?.view.tag = 1009
                                    hostingController?.view.frame = .init(origin: .zero, size: value)
                                } else {
                                    hostingController?.view.frame = .init(origin: .zero, size: value)
                                }
                            }
                        })
                }
                
            }
            .onReceive(pub)  { output in
                print("Admin policy doesn't allow to take screenshot")
            }
        
    }
}

fileprivate struct _SnapShotPreventingView <Content: View>: UIViewRepresentable {
    typealias UIViewType = UIView
    @Binding var hostingController: UIHostingController <Content>?
    
    func makeUIView(context: Context) -> UIView {
        let secureTxtField = UITextField()
        secureTxtField.isSecureTextEntry = true
        if let textLayoutView = secureTxtField.subviews.last {
            textLayoutView.backgroundColor = .clear
        }
        if let textLayoutView = secureTxtField.subviews.first {
            return textLayoutView
        }
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let hostingController, !uiView.subviews.contains(where: {$0.tag == 1009}) {
            uiView.addSubview(hostingController.view)
        }
    }
    
}

fileprivate struct SizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension View {
    @ViewBuilder
    func secure(ignoreSafeArea: Bool = true) -> some View {
        if ignoreSafeArea {
            SnapShotPreventingView {
                self
            }
            .ignoresSafeArea()
        } else {
            SnapShotPreventingView {
                self
            }
        }
    }
}
