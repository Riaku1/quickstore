<template>
  <div v-if="isOpen" class="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
    <div class="bg-white w-full max-w-lg rounded-t-2xl sm:rounded-2xl shadow-2xl overflow-hidden animate-in slide-in-from-bottom duration-300">
      
      <div class="p-4 border-b flex justify-between items-center bg-gray-50">
        <h3 class="text-xl font-bold text-gray-900">Order #{{ order.id.slice(0,5) }}</h3>
        <button @click="$emit('close')" class="p-2 hover:bg-gray-200 rounded-full transition-colors">
          <XIcon class="w-6 h-6 text-gray-500" />
        </button>
      </div>

      <div class="p-6 space-y-6 max-h-[80vh] overflow-y-auto">
        <div class="bg-blue-50 p-4 rounded-xl border border-blue-100">
          <p class="text-xs text-blue-600 font-bold uppercase tracking-wider mb-1">Delivery Location</p>
          <p class="text-gray-900 font-medium mb-3">{{ order.delivery_address }}</p>
          <div class="flex items-center gap-2">
            <PhoneIcon class="w-4 h-4 text-blue-600" />
            <a :href="`tel:${order.customer_phone}`" class="text-blue-700 font-bold underline">
              {{ order.customer_phone }}
            </a>
          </div>
        </div>

        <div>
          <h4 class="font-bold text-gray-800 mb-3 flex items-center gap-2">
            <ShoppingBagIcon class="w-5 h-5 text-green-600" />
            Order Items
          </h4>
          <div class="space-y-3">
            <div v-for="item in order.order_items" :key="item.id" class="flex justify-between items-center py-2 border-b border-gray-100">
              <div>
                <p class="font-medium">{{ item.products.name }}</p>
                <p class="text-sm text-gray-500">Qty: {{ item.quantity }}</p>
              </div>
              <p class="font-semibold">{{ (item.price_at_purchase * item.quantity).toLocaleString() }} UGX</p>
            </div>
          </div>
        </div>

        <div class="pt-4 border-t border-dashed border-gray-300">
          <div class="flex justify-between text-gray-600 mb-1">
            <span>Items Subtotal</span>
            <span>{{ order.item_total_ugx.toLocaleString() }} UGX</span>
          </div>
          <div class="flex justify-between text-gray-600 mb-3">
            <span>Boda Delivery Fee</span>
            <span>{{ order.delivery_fee_ugx.toLocaleString() }} UGX</span>
          </div>
          <div class="flex justify-between items-center bg-green-100 p-3 rounded-lg">
            <span class="font-bold text-green-800">Total Payout</span>
            <span class="text-xl font-black text-green-900">{{ order.total_payout_ugx.toLocaleString() }} UGX</span>
          </div>
        </div>
      </div>

      <div class="p-4 bg-gray-50 border-t">
        <button v-if="order.status === 'Received'" 
                @click="updateStatus('Preparing')"
                class="w-full bg-blue-600 text-white py-4 rounded-xl font-bold shadow-lg shadow-blue-200 active:scale-95 transition-all">
          Accept Order & Start Packing
        </button>
        
        <button v-if="order.status === 'Preparing'" 
                @click="updateStatus('Out for Delivery')"
                class="w-full bg-orange-600 text-white py-4 rounded-xl font-bold shadow-lg shadow-orange-200 active:scale-95 transition-all flex items-center justify-center gap-2">
          <TruckIcon class="w-5 h-5" />
          Hand to Boda (Out for Delivery)
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { XIcon, PhoneIcon, ShoppingBagIcon, TruckIcon } from 'lucide-vue-next';

const props = defineProps({
  isOpen: Boolean,
  order: Object
});

const emit = defineEmits(['close', 'refresh']);
const supabase = useSupabaseClient();

const updateStatus = async (newStatus) => {
  const { error } = await supabase
    .from('orders')
    .update({ status: newStatus })
    .eq('id', props.order.id);

  if (!error) {
    emit('refresh');
    if (newStatus === 'Out for Delivery') {
      emit('close');
    }
  }
};
</script>