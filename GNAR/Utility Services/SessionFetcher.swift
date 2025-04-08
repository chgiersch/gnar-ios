//
//  SessionFetcher.swift
//  GNAR
//
//  Created by Chris Giersch on 4/7/25.
//


import Foundation
import CoreData

protocol SessionFetching {
    func fetchPreviews(context: NSManagedObjectContext) async throws -> [GameSessionPreview]
}

class DefaultSessionFetcher: SessionFetching {
    func fetchPreviews(context: NSManagedObjectContext) async throws -> [GameSessionPreview] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = NSFetchRequest<GameSession>(entityName: "GameSession")
            request.resultType = .managedObjectResultType
            request.fetchLimit = 20
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
            request.returnsObjectsAsFaults = false
            request.relationshipKeyPathsForPrefetching = ["players"]
            
            let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request) { result in
                guard let sessions = result.finalResult else {
                    continuation.resume(returning: [])
                    return
                }

                let previews = sessions.compactMap { GameSessionPreview(from: $0) }
                continuation.resume(returning: previews)
            }

            do {
                try context.execute(asyncRequest)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
