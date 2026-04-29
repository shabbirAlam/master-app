//
//  AIViewModel.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 29/04/26.
//

import Combine
import Foundation
import FoundationModels

@available(iOS 26.0, *)
final class AIViewModel: ObservableObject {
    let session = LanguageModelSession()
    
}

@available(iOS 26.0, *)
extension AIViewModel {
    // helper methods goes here
    func generateResponse(for query: String) async {
        do {
            let response = try await session.respond(to: query)
            print(response.content)
        } catch {
            print(error.localizedDescription)
        }
    }
}
