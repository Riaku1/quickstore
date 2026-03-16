<template>
  <div class="min-h-screen bg-gray-50 p-4 font-sans">
    <header class="mb-6 flex justify-between items-center">
      <h1 class="text-2xl font-bold text-green-700">QuickStore Vendor</h1>
      <div class="bg-white px-4 py-2 rounded-lg shadow-sm border border-gray-200">
        <span class="text-xs text-gray-500 uppercase block">Status</span>
        <span class="text-sm font-semibold text-green-600">● Accepting Orders</span>
      </div>
    </header>

    <section class="mb-8">
      <h2 class="text-lg font-semibold mb-4 flex items-center">
        Incoming Orders 
        <span v-if="activeOrders.length > 0" class="ml-2 bg-red-500 text-white text-xs px-2 py-1 rounded-full animate-pulse">
          {{ activeOrders.length }} New
        </span>
      </h2>
      
      <div v-if="activeOrders.length === 0" class="text-gray-500 italic p-4 bg-white rounded-xl shadow-sm">
        No pending orders right now.
      </div>

      <div v-else v-for="order in activeOrders" :key="order.id" class="bg-white rounded-xl shadow-md border-l-4 border-orange-500 mb-4 overflow-hidden">
        <div class="p-4">
          <div class="flex justify-between mb-2">
            <span class="font-bold text-gray-800">Order #{{ order.id.slice(0,5) }}</span>
            <span class="text-green-600 font-bold underline">{{ order.total_payout_ugx?.toLocaleString() }} UGX</span>
          </div>
          
          <ul class="text-sm text-gray-600 mb-4 space-y-1 border-y py-2 border-gray-100">
            <li v-for="item in order.order_items" :key="item.id">
              {{ item.quantity }}x {{ item.products?.name }}
            </li>
          </ul>

          <div class="flex mt-4">
            <button @click="openOrder(order)"
                    class="w-full bg-blue-50 text-blue-700 py-3 rounded-lg font-semibold border border-blue-200 active:scale-95 transition-transform">
              Review & Process Order
            </button>
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-lg font-semibold">Stock Management</h2>
        <button class="text-blue-600 text-sm font-medium">+ Add Item</button>
      </div>
      <div class="bg-white rounded-xl shadow-sm border border-gray-100 divide-y divide-gray-100">
        <div v-for="product in products" :key="product.id" class="p-4 flex items-center justify-between">
          <div>
            <p class="font-medium text-gray-800">{{ product.name }}</p>
            <p class="text-xs text-gray-500">{{ product.price_ugx?.toLocaleString() }} UGX / {{ product.unit }}</p>
          </div>
          <label class="relative inline-flex items-center cursor-pointer">
            <input type="checkbox" v-model="product.in_stock" @change="toggleStock(product)" class="sr-only peer">
            <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-green-600"></div>
          </label>
        </div>
      </div>
    </section>

    <OrderDetailsModal 
      :is-open="isModalOpen" 
      :order="selectedOrder" 
      @close="isModalOpen = false"
      @refresh="fetchOrders"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';

// State Variables
const activeOrders = ref([]);
const products = ref([]);
const isModalOpen = ref(false);
const selectedOrder = ref(null);

const supabase = useSupabaseClient();

// Data Fetching Logic (Runs on client to prevent SSR crashes)
const fetchOrders = async () => {
  const { data, error } = await supabase
    .from('orders')
    .select('*, order_items(*, products(name))')
    .in('status', ['Received', 'Preparing']) // Only show active orders
    .order('created_at', { ascending: false });
  
  if (!error) activeOrders.value = data || [];
};

const fetchProducts = async () => {
  const { data, error } = await supabase
    .from('products')
    .select('*')
    .order('name');
    
  if (!error) products.value = data || [];
};

// Lifecycle Hook
onMounted(() => {
  fetchOrders();
  fetchProducts();
});

// UI Actions
const openOrder = (order) => {
  selectedOrder.value = order;
  isModalOpen.value = true;
};

const toggleStock = async (product) => {
  await supabase
    .from('products')
    .update({ in_stock: product.in_stock })
    .eq('id', product.id);
};
</script>
