package com.scanflow.app

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.os.Bundle
import android.view.View
import android.view.animation.OvershootInterpolator
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Install the splash screen with animation
        val splashScreen = installSplashScreen()
        
        // Keep splash screen visible while loading
        var keepSplashScreen = true
        splashScreen.setKeepOnScreenCondition { keepSplashScreen }
        
        // Animate the splash screen icon
        splashScreen.setOnExitAnimationListener { splashScreenView ->
            // Create scale animation
            val scaleX = ObjectAnimator.ofFloat(
                splashScreenView.iconView,
                View.SCALE_X,
                1f,
                0.8f,
                1.1f,
                1f
            )
            val scaleY = ObjectAnimator.ofFloat(
                splashScreenView.iconView,
                View.SCALE_Y,
                1f,
                0.8f,
                1.1f,
                1f
            )
            
            // Create fade animation
            val alpha = ObjectAnimator.ofFloat(
                splashScreenView.view,
                View.ALPHA,
                1f,
                0f
            )
            
            // Combine animations
            val animatorSet = AnimatorSet()
            animatorSet.duration = 500
            animatorSet.interpolator = OvershootInterpolator()
            animatorSet.playTogether(scaleX, scaleY)
            animatorSet.play(alpha).after(300)
            
            animatorSet.start()
            
            // Remove splash screen after animation
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                splashScreenView.remove()
            }, 500)
        }
        
        super.onCreate(savedInstanceState)
        
        // Allow splash screen to dismiss after a short delay
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            keepSplashScreen = false
        }, 1000)
    }
}