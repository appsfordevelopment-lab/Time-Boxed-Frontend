import SwiftData
import SwiftUI

class NFCBlockingStrategy: BlockingStrategy {
  static var id: String = "NFCBlockingStrategy"

  var name: String = "NFC Tags"
  var description: String =
    "Block and unblock profiles by using the exact same NFC tag"
  var iconType: String = "wave.3.right.circle.fill"
  var color: Color = .yellow

  var hidden: Bool = false

  var onSessionCreation: ((SessionStatus) -> Void)?
  var onErrorMessage: ((String) -> Void)?

  private let nfcScanner: NFCScannerUtil = NFCScannerUtil()
  private let appBlocker: AppBlockerUtil = AppBlockerUtil()

  func getIdentifier() -> String {
    return NFCBlockingStrategy.id
  }

  func startBlocking(
    context: ModelContext,
    profile: BlockedProfiles,
    forceStart: Bool?
  ) -> (any View)? {
    nfcScanner.onTagScanned = { tag in
      let tagId = tag.url ?? tag.id

      Task {
        let valid = await AuthenticationManager.shared.isNFCTagValidForUnlock(tagId: tagId)
        await MainActor.run {
          guard valid else {
            self.onErrorMessage?(
              "This NFC tag is not registered. Only NFC tags added to your account can lock or unblock."
            )
            return
          }
          self.appBlocker.activateRestrictions(for: BlockedProfiles.getSnapshot(for: profile))
          let activeSession =
            BlockedProfileSession
            .createSession(
              in: context,
              withTag: tagId,
              withProfile: profile,
              forceStart: forceStart ?? false
            )
          self.onSessionCreation?(.started(activeSession))
        }
      }
    }

    nfcScanner.scan(profileName: profile.name)

    return nil
  }

  func stopBlocking(
    context: ModelContext,
    session: BlockedProfileSession
  ) -> (any View)? {
    nfcScanner.onTagScanned = { tag in
      let tagId = tag.url ?? tag.id

      Task {
        let valid = await AuthenticationManager.shared.isNFCTagValidForUnlock(tagId: tagId)
        await MainActor.run {
          guard valid else {
            self.onErrorMessage?(
              "This NFC tag is not registered. Only NFC tags added to your account can lock or unblock."
            )
            return
          }
          if let physicalUnblockNFCTagId = session.blockedProfile.physicalUnblockNFCTagId {
            if physicalUnblockNFCTagId != tagId {
              self.onErrorMessage?(
                "This NFC tag is not allowed to unblock this profile. Physical unblock setting is on for this profile"
              )
              return
            }
          } else if !session.forceStarted && session.tag != tagId {
            self.onErrorMessage?(
              "You must scan the original tag to stop focus"
            )
            return
          }
          session.endSession()
          try? context.save()
          self.appBlocker.deactivateRestrictions()
          self.onSessionCreation?(.ended(session.blockedProfile))
        }
      }
    }

    nfcScanner.scan(profileName: session.blockedProfile.name)

    return nil
  }
}
