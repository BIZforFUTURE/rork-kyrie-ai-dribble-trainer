package com.rork.kyrieai.data

import android.app.Activity
import android.app.Application
import android.util.Log
import com.android.billingclient.api.AcknowledgePurchaseParams
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.PendingPurchasesParams
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryPurchasesParams
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * Wraps Google Play Billing for Kyrie AI Pro subscriptions.
 *
 * Product IDs below must match the subscription products created in the Google
 * Play Console (Monetize ▸ Subscriptions). Each is a subscription with a single
 * base plan and a 3-day free trial offer.
 */
class BillingManager(
    private val app: Application,
    private val onPremiumChanged: (Boolean) -> Unit,
) : PurchasesUpdatedListener, BillingClientStateListener {

    companion object {
        const val YEARLY_ID = "kyrie_pro_yearly"
        const val MONTHLY_ID = "kyrie_pro_monthly"
        private val SUB_IDS = listOf(YEARLY_ID, MONTHLY_ID)
        private const val TAG = "BillingManager"
    }

    private val _products = MutableStateFlow<Map<String, ProductDetails>>(emptyMap())
    val products: StateFlow<Map<String, ProductDetails>> = _products.asStateFlow()

    /** User-facing status/error message from the last billing action, or null. */
    private val _status = MutableStateFlow<String?>(null)
    val status: StateFlow<String?> = _status.asStateFlow()

    private val client: BillingClient = BillingClient.newBuilder(app)
        .setListener(this)
        .enablePendingPurchases(
            PendingPurchasesParams.newBuilder().enableOneTimeProducts().build(),
        )
        .build()

    fun start() {
        if (client.connectionState == BillingClient.ConnectionState.CONNECTED) return
        runCatching { client.startConnection(this) }
            .onFailure { Log.w(TAG, "Failed to start billing connection", it) }
    }

    override fun onBillingSetupFinished(result: BillingResult) {
        if (result.responseCode == BillingClient.BillingResponseCode.OK) {
            queryProducts()
            queryPurchases()
        } else {
            Log.w(TAG, "Billing setup failed: ${result.debugMessage}")
        }
    }

    override fun onBillingServiceDisconnected() {
        // Play will reconnect on the next call to start().
    }

    private fun queryProducts() {
        val productList = SUB_IDS.map { id ->
            QueryProductDetailsParams.Product.newBuilder()
                .setProductId(id)
                .setProductType(BillingClient.ProductType.SUBS)
                .build()
        }
        val params = QueryProductDetailsParams.newBuilder().setProductList(productList).build()
        client.queryProductDetailsAsync(params) { result, details ->
            if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                _products.value = details.associateBy { it.productId }
            } else {
                Log.w(TAG, "Query products failed: ${result.debugMessage}")
            }
        }
    }

    /** Re-checks entitlements with Play. Also used for "Restore purchases". */
    fun queryPurchases() {
        val params = QueryPurchasesParams.newBuilder()
            .setProductType(BillingClient.ProductType.SUBS)
            .build()
        client.queryPurchasesAsync(params) { result, purchases ->
            if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                val active = purchases.any { it.purchaseState == Purchase.PurchaseState.PURCHASED }
                onPremiumChanged(active)
                purchases.forEach { acknowledge(it) }
            }
        }
    }

    /** Formatted price (e.g. "$39.99") for a product, if Play returned it. */
    fun formattedPrice(productId: String): String? {
        val offer = _products.value[productId]?.subscriptionOfferDetails?.lastOrNull() ?: return null
        return offer.pricingPhases.pricingPhaseList
            .lastOrNull { it.priceAmountMicros > 0 }
            ?.formattedPrice
    }

    fun purchase(activity: Activity, productId: String) {
        val details = _products.value[productId]
        if (details == null) {
            _status.value = "This plan isn't available yet. Please try again in a moment."
            return
        }
        val offerToken = details.subscriptionOfferDetails?.firstOrNull()?.offerToken
        if (offerToken == null) {
            _status.value = "This plan isn't available yet. Please try again in a moment."
            return
        }
        val productParams = listOf(
            BillingFlowParams.ProductDetailsParams.newBuilder()
                .setProductDetails(details)
                .setOfferToken(offerToken)
                .build(),
        )
        val flowParams = BillingFlowParams.newBuilder()
            .setProductDetailsParamsList(productParams)
            .build()
        client.launchBillingFlow(activity, flowParams)
    }

    fun clearStatus() {
        _status.value = null
    }

    override fun onPurchasesUpdated(result: BillingResult, purchases: MutableList<Purchase>?) {
        when (result.responseCode) {
            BillingClient.BillingResponseCode.OK -> purchases?.forEach { handlePurchase(it) }
            BillingClient.BillingResponseCode.USER_CANCELED -> Unit
            BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED -> {
                onPremiumChanged(true)
                queryPurchases()
            }
            else -> _status.value = "Purchase couldn't be completed. Please try again."
        }
    }

    private fun handlePurchase(purchase: Purchase) {
        if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
            onPremiumChanged(true)
            acknowledge(purchase)
        }
    }

    private fun acknowledge(purchase: Purchase) {
        if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED && !purchase.isAcknowledged) {
            val params = AcknowledgePurchaseParams.newBuilder()
                .setPurchaseToken(purchase.purchaseToken)
                .build()
            client.acknowledgePurchase(params) { }
        }
    }
}
