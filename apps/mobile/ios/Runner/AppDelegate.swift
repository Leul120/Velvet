import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var blurView: UIVisualEffectView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenCaptureChanged),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
    // Best-effort: hide content in app switcher snapshots.
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(willResignActive),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  @objc private func screenCaptureChanged() {
    if UIScreen.main.isCaptured {
      showPrivacyBlur()
    } else if UIApplication.shared.applicationState == .active {
      hidePrivacyBlur()
    }
  }

  @objc private func willResignActive() {
    showPrivacyBlur()
  }

  @objc private func didBecomeActive() {
    if !UIScreen.main.isCaptured {
      hidePrivacyBlur()
    }
  }

  private func showPrivacyBlur() {
    guard blurView == nil, let window = keyWindow else { return }
    let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    blur.frame = window.bounds
    blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    window.addSubview(blur)
    blurView = blur
  }

  private func hidePrivacyBlur() {
    blurView?.removeFromSuperview()
    blurView = nil
  }

  private var keyWindow: UIWindow? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
  }
}
