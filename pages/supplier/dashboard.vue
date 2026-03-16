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
        <span class="ml-2 bg-red-500 text-white text-xs px-2 py-1 rounded-full animate-pulse">
          New
        </span>
      </h2>
      
      <div v-for="order in activeOrders" :key="order.id" class="bg-white rounded-xl shadow-md border-l-4 border-orange-500 mb-4 overflow-hidden">
        <div class="p-4">
          <div class="flex justify-between mb-2">
            <span class="font-bold text-gray-800">Order #{{ order.id.slice(0,5) }}</span>
            <span class="text-green-600 font-bold underline">{{ order.total_payout }} UGX</span>
          </div>
          
          <ul class="text-sm text-gray-600 mb-4 space-y-1 border-y py-2 border-gray-100">
            <li v-for="item in order.items" :key="item.name">
              {{ item.quantity }}x {{ item.name }}
            </li>
          </ul>

          <div class="flex gap-2 mt-4">
            <button v-if="order.status === 'Received'" 
                    @click="updateStatus(order.id, 'Preparing')"
                    class="flex-1 bg-blue-600 text-white py-3 rounded-lg font-semibold active:scale-95 transition-transform">
              Accept & Pack
            </button>
            
            <button v-if="order.status === 'Preparing'" 
                    @click="updateStatus(order.id, 'Out for Delivery')"
                    class="flex-1 bg-orange-500 text-white py-3 rounded-lg font-semibold active:scale-95 transition-transform">
              Hand to Boda [Out for Delivery]
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
            <p class="text-xs text-gray-500">{{ product.price }} UGX / {{ product.unit }}</p>
          </div>
          <label class="relative inline-flex items-center cursor-pointer">
            <input type="checkbox" v-model="product.in_stock" class="sr-only peer">
            <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-green-600"></div>
          </label>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
// Mock data representing the "Single Opaque Entity" model [cite: 11]
const activeOrders = ref([
  {
    id: 'QS-9921',
    status: 'Received',
    total_payout: '34,000', // Groceries + Delivery Fee [cite: 24]
    items: [{ name: 'Tomatoes (Small Basin)', quantity: 1 }, { name: 'Beef (1kg)', quantity: 2 }]
  }
]);

const products = ref([
  { id: 1, name: 'Tomatoes', price: '2,000', unit: 'Heap', in_stock: true },
  { id: 2, name: 'Onions', price: '1,500', unit: 'Heap', in_stock: false },
]);

const updateStatus = (id, newStatus) => {
  const order = activeOrders.value.find(o => o.id === id);
  if (order) order.status = newStatus;
  // Logic to trigger Firebase Cloud Messaging notification [cite: 63]
};
const isModalOpen = ref(false);
const selectedOrder = ref(null);

const openOrder = (order) => {
  selectedOrder.value = order;
  isModalOpen.value = true;
};
</script>
<OrderDetailsModal 
  :is-open="isModalOpen" 
  :order="selectedOrder" 
  @close="isModalOpen = false"
  @refresh="fetchOrders"
/>