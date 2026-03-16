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

<script setup>
import { ref, onMounted } from 'vue'

// 1. Initialize variables as empty/null
const orders = ref([])
const error = ref(null)

// 2. ONLY run the database call after the component mounts on the client
onMounted(async () => {
  const supabase = useSupabaseClient()
  
  try {
    const { data, err } = await supabase.from('orders').select('*')
    if (err) throw err
    orders.value = data
  } catch (e) {
    error.value = e.message
  }
})
</script>

<template>
  <div>
    <div v-if="orders.length === 0">Loading orders...</div>
    <div v-else>
      </div>
  </div>
</template>
