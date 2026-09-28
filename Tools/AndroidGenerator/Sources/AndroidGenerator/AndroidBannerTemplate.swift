import Foundation

enum AndroidBannerTemplate {
    static func application(packageName: String) -> String {
        AndroidAudioTemplate.application(packageName: packageName)
            .replacingOccurrences(
                of: "        ConcordAudioManager.initialize(this)\n",
                with: "        ConcordAudioManager.initialize(this)\n        ConcordBannerManager.initialize(this)\n"
            )
            .replacingOccurrences(
                of: "        ConcordNative.setPlatformEnvironment()\n",
                with: "        ConcordNative.setPlatformEnvironment()\n        ConcordNative.setBannerEnvironment()\n"
            )
    }

    static func concordNative(packageName: String) -> String {
        AndroidRendererTemplate.concordNative(packageName: packageName)
            .replacingOccurrences(
                of: "    external fun start()\n",
                with: "    external fun setBannerEnvironment()\n    external fun bannerDidDismiss()\n    external fun start()\n"
            )
    }

    static func bannerManager(packageName: String) -> String {
        """
package \(packageName)

import android.app.Activity
import android.app.Application
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView

/** Native transient bottom banner used by ConcordPlatform. */
object ConcordBannerManager : Application.ActivityLifecycleCallbacks {
    private var application: Application? = null
    private var currentActivity: Activity? = null
    private var overlay: FrameLayout? = null
    private var generation = 0
    private val handler = Handler(Looper.getMainLooper())

    @JvmStatic
    fun initialize(context: Context) {
        val app = context.applicationContext as? Application ?: return
        if (application === app) return
        application?.unregisterActivityLifecycleCallbacks(this)
        application = app
        app.registerActivityLifecycleCallbacks(this)
    }

    @JvmStatic fun canDisplayBanner(): Boolean = currentActivity != null

    @JvmStatic
    fun banner(text: String): Boolean {
        val activity = currentActivity ?: return false
        if (text.isBlank()) return false
        activity.runOnUiThread {
            dismissCurrent()
            generation += 1
            val token = generation
            val root = activity.window.decorView as? ViewGroup ?: run {
                ConcordNative.bannerDidDismiss()
                return@runOnUiThread
            }

            val shield = FrameLayout(activity).apply {
                setBackgroundColor(Color.TRANSPARENT)
                isClickable = true
                isFocusable = true
                setOnClickListener { dismissAnimated() }
            }
            val density = activity.resources.displayMetrics.density
            val bannerView = TextView(activity).apply {
                this.text = text
                setTextColor(Color.WHITE)
                textSize = 16f
                gravity = Gravity.CENTER
                setPadding((18 * density).toInt(), (12 * density).toInt(), (18 * density).toInt(), (12 * density).toInt())
                background = GradientDrawable().apply {
                    cornerRadius = 10 * density
                    setColor(Color.rgb(55, 55, 58))
                }
                alpha = 0f
                translationY = 80 * density
            }
            val params = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
            ).apply {
                leftMargin = (20 * density).toInt()
                rightMargin = (20 * density).toInt()
                bottomMargin = (24 * density).toInt()
            }
            shield.addView(bannerView, params)
            root.addView(shield, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
            overlay = shield
            bannerView.animate().alpha(1f).translationY(0f).setDuration(250).start()
            handler.postDelayed({ if (generation == token) dismissAnimated() }, 3500)
        }
        return true
    }

    private fun dismissAnimated() {
        val current = overlay ?: return
        generation += 1
        current.animate()
            .alpha(0f)
            .translationY(60f * current.resources.displayMetrics.density)
            .setDuration(200)
            .withEndAction {
                (current.parent as? ViewGroup)?.removeView(current)
                if (overlay === current) overlay = null
                ConcordNative.bannerDidDismiss()
            }
            .start()
    }

    private fun dismissCurrent() {
        generation += 1
        val current = overlay ?: return
        current.animate().cancel()
        (current.parent as? ViewGroup)?.removeView(current)
        overlay = null
    }

    override fun onActivityCreated(activity: Activity, state: Bundle?) { currentActivity = activity }
    override fun onActivityStarted(activity: Activity) { currentActivity = activity }
    override fun onActivityResumed(activity: Activity) { currentActivity = activity }
    override fun onActivityPaused(activity: Activity) = Unit
    override fun onActivityStopped(activity: Activity) = Unit
    override fun onActivitySaveInstanceState(activity: Activity, state: Bundle) = Unit
    override fun onActivityDestroyed(activity: Activity) {
        if (currentActivity === activity) currentActivity = null
    }
}
"""
    }

    static func swiftPlatformSupport(packageName: String) -> String {
        let javaPackagePath = packageName.replacingOccurrences(of: ".", with: "/")
        let jniPackageName = packageName.replacingOccurrences(of: ".", with: "_")
        return AndroidAudioTemplate.swiftPlatformSupport(packageName: packageName) + """


nonisolated(unsafe) private var concordAndroidBannerJNIEnvironment: UnsafeMutablePointer<JNIEnv?>?
nonisolated(unsafe) private var concordAndroidBannerCompletion: ConcordBannerCompletion?

@_cdecl("Java_\(jniPackageName)_ConcordNative_setBannerEnvironment")
public func concordAndroidSetBannerEnvironment(
    environment: UnsafeMutablePointer<JNIEnv?>,
    receiver: jobject
) {
    concordAndroidBannerJNIEnvironment = environment
}

@_cdecl("Java_\(jniPackageName)_ConcordNative_bannerDidDismiss")
public func concordAndroidBannerDidDismiss(
    environment: UnsafeMutablePointer<JNIEnv?>,
    receiver: jobject
) {
    let completion = concordAndroidBannerCompletion
    concordAndroidBannerCompletion = nil
    completion?()
}

extension ConcordAndroidPlatform: ConcordPlatformBannerSupport {
    var canDisplayBanner: Bool {
        callBannerBoolean(method: "canDisplayBanner", strings: [])
    }

    @discardableResult
    func banner(_ text: String, completion: @escaping ConcordBannerCompletion) -> Bool {
        let previous = concordAndroidBannerCompletion
        concordAndroidBannerCompletion = nil
        previous?()

        concordAndroidBannerCompletion = completion
        let started = callBannerBoolean(method: "banner", strings: [text])
        if !started { concordAndroidBannerCompletion = nil }
        return started
    }

    private func callBannerBoolean(method: String, strings: [String]) -> Bool {
        guard let environment = concordAndroidBannerJNIEnvironment,
              let functions = environment.pointee?.pointee else { return false }
        let className = "\(javaPackagePath)/ConcordBannerManager"
        let clazz = className.withCString { functions.FindClass(environment, $0) }
        guard let clazz else { return false }
        defer { functions.DeleteLocalRef(environment, clazz) }

        let signature = "(" + String(repeating: "Ljava/lang/String;", count: strings.count) + ")Z"
        let methodID = method.withCString { methodName in
            signature.withCString { methodSignature in
                functions.GetStaticMethodID(environment, clazz, methodName, methodSignature)
            }
        }
        guard let methodID else { return false }

        let localStrings: [jstring] = strings.map { value in
            value.withCString { functions.NewStringUTF(environment, $0)! }
        }
        defer { for value in localStrings { functions.DeleteLocalRef(environment, value) } }
        var arguments = localStrings.map { value -> jvalue in
            var argument = jvalue(); argument.l = value; return argument
        }
        let result: jboolean = arguments.withUnsafeMutableBufferPointer { buffer in
            functions.CallStaticBooleanMethodA(environment, clazz, methodID, buffer.baseAddress)
        }
        return result != 0
    }
}
"""
    }
}
