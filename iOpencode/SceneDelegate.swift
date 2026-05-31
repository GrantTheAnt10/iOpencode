import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("[SceneDelegate] willConnectTo called")
        guard let windowScene = (scene as? UIWindowScene) else {
            print("[SceneDelegate] ERROR: could not cast to UIWindowScene")
            return
        }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        print("[SceneDelegate] window made key and visible")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("[SceneDelegate] sceneDidBecomeActive")
    }
}