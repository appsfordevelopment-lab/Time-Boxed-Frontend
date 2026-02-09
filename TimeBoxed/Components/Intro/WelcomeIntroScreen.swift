import SwiftUI

struct WelcomeIntroScreen: View {
  @State private var showContent: Bool = false
  let onContinueWithEmail: () -> Void
  let onSkipBrick: () -> Void

  var body: some View {
    ZStack {
      // Background image
      AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1543297088-974cee3f2156?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjB8fHBob25lJTIwbGFwdG9wfGVufDB8fDB8fHww")) { phase in
        switch phase {
        case .empty:
          // Placeholder gradient while loading
          LinearGradient(
            gradient: Gradient(colors: [
              Color(red: 0.15, green: 0.12, blue: 0.10),
              Color(red: 0.20, green: 0.17, blue: 0.14)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        case .success(let image):
          image
            .resizable()
            .scaledToFill()
        case .failure:
          // Fallback gradient if image fails to load
          LinearGradient(
            gradient: Gradient(colors: [
              Color(red: 0.15, green: 0.12, blue: 0.10),
              Color(red: 0.20, green: 0.17, blue: 0.14)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        @unknown default:
          LinearGradient(
            gradient: Gradient(colors: [
              Color(red: 0.15, green: 0.12, blue: 0.10),
              Color(red: 0.20, green: 0.17, blue: 0.14)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .clipped()
      .ignoresSafeArea(.all)

      VStack(spacing: 0) {
        Spacer()

        // Title section
        VStack(alignment: .leading, spacing: 12) {
          Text("Your time is yours.")
            .font(.system(size: 35,  ))
            .foregroundColor(.white)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : -20)

          Text("Get back to moving.")
            .font(.system(size: 35, ))
            .foregroundColor(.white)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : -20)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 60)

        // Buttons
        VStack(spacing: 16) {
          // Continue with email button
          Button(action: onContinueWithEmail) {
            Text("Continue ")
              .font(.system(size: 20, weight: .semibold))
              .foregroundColor(.black)
              .frame(maxWidth: 350)
              .frame(height: 56)
              .background(
                RoundedRectangle(cornerRadius: 28)
                  .fill(Color(white: 0.95))
              )
          }
          .opacity(showContent ? 1 : 0)
          .offset(y: showContent ? 0 : 20)

          // I don't have a Brick button
          Button(action: onSkipBrick) {
            Text("I don't have a Time Boxed")
              .font(.system(size: 20, weight: .semibold))
              .foregroundColor(.white)
              .frame(maxWidth: 350)
              .frame(height: 56)
              .background(
                RoundedRectangle(cornerRadius: 28)
                  .fill(Color.clear)
                  .overlay(
                    RoundedRectangle(cornerRadius: 28)
                      .stroke(Color(white: 0.3), lineWidth: 1)
                  )
              )
          }
          .opacity(showContent ? 1 : 0)
          .offset(y: showContent ? 0 : 20)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)

        // Legal disclaimer
        VStack(spacing: 4) {
          HStack(spacing: 4) {
            Text("By continuing, you agree to our")
              .font(.system(size: 12))
              .foregroundColor(Color(white: 1))

            Link("Terms", destination: URL(string: "https://timeboxed.app/terms")!)
              .font(.system(size: 12, weight: .medium))
              .foregroundColor(Color(red: 0.85, green: 0.55, blue: 0.25))
              .underline()

            Text("and")
              .font(.system(size: 12))
              .foregroundColor(Color(white: 0.5))

            Link("Privacy Policy", destination: URL(string: "https://timeboxed.app/privacy")!)
              .font(.system(size: 12, weight: .medium))
              .foregroundColor(Color(red: 0.85, green: 0.55, blue: 0.25))
              .underline()
          }
        }
        .padding(.bottom, 40)
        .opacity(showContent ? 1 : 0)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .onAppear {
      withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
        showContent = true
      }
    }
  }
}

#Preview {
  WelcomeIntroScreen(
    onContinueWithEmail: { print("Continue with email") },
    onSkipBrick: { print("Skip Brick") }
  )
}
