<template>
  <div class="min-h-screen bg-gray-50 p-4 font-sans">
    <header class="mb-6">
      <h1 class="text-3xl font-black text-green-700">QuickStore</h1>
      <p class="text-gray-600 font-medium">Delivering to Namilyango</p>
    </header>

    <main>
      <div class="mb-8 p-4 bg-white border-l-4 border-blue-500 shadow-sm rounded-lg">
        <h2 class="text-sm font-bold text-gray-500 uppercase tracking-wider mb-2">System Status</h2>
        <div v-if="error" class="text-red-600 font-medium">Database Error: {{ error }}</div>
        <div v-else-if="orders.length === 0" class="text-blue-600 animate-pulse">Connecting to Supabase...</div>
        <div v-else class="text-green-600 font-bold">Live: Connected to {{ orders.length }} pending orders.</div>
      </div>

      <h2 class="text-xl font-bold mb-4">Available Groceries</h2>
      <div class="grid grid-cols-2 gap-4 mb-8">
        <div v-for="product in products" :key="product.id" class="bg-white p-4 rounded-xl shadow-sm border border-gray-100">
          <h3 class="font-bold text-gray-800">{{ product.name }}</h3>
          <p class="text-green-600 font-medium mb-3">{{ product.price.toLocaleString() }} UGX</p>
          <button @click="addToCart(product)" class="w-full bg-blue-600 text-white py-2 rounded-lg font-semibold active:scale-95 transition-transform">
            Add to Cart
          </button>
        </div>
      </div>
      
      <div class="bg-white p-4 rounded-xl shadow-md border border-green-100">
        <h3 class="text-lg font-bold text-gray-800 mb-3">Cart Total: {{ totalCharge.toLocaleString() }} UGX</h3>
        <button @click="navigateToCheckout" class="w-full bg-green-600 text-white py-3 rounded-lg font-bold shadow-lg shadow-green-200 active:scale-95 transition-transform">
          Checkout with MoMo
        </button>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

// --- 1. SUPPLIER LOGIC (Supabase Database Connection) ---
const orders = ref([])
const error = ref(null)
const supabase = useSupabaseClient()

onMounted(async () => {
  try {
    const { data, err } = await supabase.from('orders').select('*')
    if (err) throw err
    orders.value = data || []
  } catch (e) {
    error.value = e.message
  }
})

// --- 2. CUSTOMER LOGIC (Mock Storefront Variables to pass compilation) ---
const products = ref([
  { id: 1, name: 'Matooke (Bunch)', price: 25000 },
  { id: 2, name: 'Tomatoes (Basin)', price: 5000 }
])
const totalCharge = ref(0)

const addToCart = (product) => {
  totalCharge.value += product.price
}

const navigateToCheckout = () => {
  alert('Redirecting to MTN MoMo Gateway...')
}
</script>
