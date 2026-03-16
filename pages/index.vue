<template>
  <div class="customer-container">
    <header>
      <h1>QuickStore</h1>
      <p>Delivering to Namilyango</p>
    </header>

    <main>
      <h2>Available Groceries</h2>
      <div class="product-grid">
        <div v-for="product in products" :key="product.id" class="product-card">
          <h3>{{ product.name }}</h3>
          <p>{{ product.price }} UGX</p>
          <button @click="addToCart(product)">Add to Cart</button>
        </div>
      </div>
      
      <div class="cart-summary">
        <h3>Cart Total: {{ totalCharge }} UGX</h3>
        <button @click="navigateToCheckout">Checkout with MoMo</button>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
const { cart, addToCart, totalCharge } = useCart()
const supabase = useSupabaseClient()

// Fetch products from Supabase
const { data: products } = await useAsyncData('products', async () => {
  const { data } = await supabase.from('products').select('*').eq('supplier_active', true)
  return data
})

const navigateToCheckout = () => {
  navigateTo('/checkout')
}
</script>