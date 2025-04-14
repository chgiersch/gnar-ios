//
//  ScoreRepository.swift
//  GNAR
//
//  Created by Chris Giersch on 4/9/25.
//


// ScoreRepository.swift

import CoreData

final class ScoreRepository {
    private let contexts: CoreDataContexts

    var viewContext: NSManagedObjectContext {
        contexts.viewContext
    }

    init(contexts: CoreDataContexts) {
        self.contexts = contexts
    }

    func fetchScores(for session: GameSession) async throws -> [Score] {
        let request: NSFetchRequest<Score> = Score.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Score.gameSession), session)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Score.timestamp, ascending: false)]
        request.returnsObjectsAsFaults = false

        return try await contexts.viewContext.perform {
            try self.contexts.viewContext.fetch(request)
        }
    }

    func deleteScore(_ score: Score) throws {
        contexts.viewContext.delete(score)
        try contexts.viewContext.save()
    }

    func addScore(_ score: Score, to session: GameSession) throws {
        session.addToScores(score)
        try contexts.viewContext.save()
    }
}
